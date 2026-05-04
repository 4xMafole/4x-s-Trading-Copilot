package com.example.trading_copilot_flutter

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import java.util.TimeZone
import kotlin.math.max
import kotlin.math.abs
import kotlin.math.roundToInt

class TradingStatusWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        updateAllWidgets(context)
    }

    companion object {
        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, TradingStatusWidgetProvider::class.java),
            )
            ids.forEach { id -> updateWidget(context, manager, id) }
        }

        private fun updateWidget(
            context: Context,
            manager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val views = RemoteViews(context.packageName, R.layout.trading_status_widget)
            try {
                val snap = buildSnapshot(context)

                views.setTextViewText(R.id.widgetSessionStatus, snap.sessionLabel)
                views.setTextViewText(R.id.widgetTradesRemaining, snap.tradesLabel)
                views.setTextViewText(R.id.widgetUpdated, snap.updatedLabel)
                views.setTextColor(R.id.widgetSessionStatus, snap.sessionColor)

                // Set PnL with tone-aware color (green/red/neutral).
                views.setTextViewText(R.id.widgetPnl, snap.pnlLabel)
                views.setTextColor(R.id.widgetPnl, snap.pnlColor)

                // Tint the trade-slot pill copy to match the dominant state.
                views.setTextColor(R.id.widgetTradesRemaining, snap.tradesColor)

                // Next-session hint
                if (snap.nextSessionLabel != null) {
                    views.setTextViewText(R.id.widgetNextSession, snap.nextSessionLabel)
                    views.setViewVisibility(R.id.widgetNextSession, View.VISIBLE)
                } else {
                    views.setViewVisibility(R.id.widgetNextSession, View.GONE)
                }

                // Badge
                views.setViewVisibility(
                    R.id.widgetBadgeActive,
                    if (snap.badge == Badge.ACTIVE) View.VISIBLE else View.GONE,
                )
                views.setViewVisibility(
                    R.id.widgetBadgeStandby,
                    if (snap.badge == Badge.STANDBY) View.VISIBLE else View.GONE,
                )
                views.setViewVisibility(
                    R.id.widgetBadgeLocked,
                    if (snap.badge == Badge.LOCKED) View.VISIBLE else View.GONE,
                )
                
                // Dynamic Accent Stripe
                views.setViewVisibility(
                    R.id.stripeActive,
                    if (snap.badge == Badge.ACTIVE) View.VISIBLE else View.GONE,
                )
                views.setViewVisibility(
                    R.id.stripeStandby,
                    if (snap.badge == Badge.STANDBY) View.VISIBLE else View.GONE,
                )
                views.setViewVisibility(
                    R.id.stripeLocked,
                    if (snap.badge == Badge.LOCKED) View.VISIBLE else View.GONE,
                )
                
            } catch (_: Exception) {
                // Never crash the app process from widget rendering.
            }

            val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            else PendingIntent.FLAG_UPDATE_CURRENT
            
            // Tap Root opens app
            val tapIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            views.setOnClickPendingIntent(
                R.id.widgetRoot,
                PendingIntent.getActivity(context, 0, tapIntent, pendingFlags),
            )
            
            // Tap Refresh force updates
            val refreshIntent = Intent(context, TradingStatusWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(appWidgetId))
            }
            views.setOnClickPendingIntent(
                R.id.widgetRefresh,
                PendingIntent.getBroadcast(context, appWidgetId + 999, refreshIntent, pendingFlags),
            )

            manager.updateAppWidget(appWidgetId, views)
        }

        // ── Data ─────────────────────────────────────────────────────────────

        private fun buildSnapshot(context: Context): Snapshot {
            val now = Calendar.getInstance(TimeZone.getTimeZone("Africa/Nairobi"))
            val todayKey = isoDate(now)

            var locked = false
            var todayTrades = 0
            var todayPnl = 0.0

            val raw = context
                .getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                .getString("flutter.widget_state", null)

            if (!raw.isNullOrEmpty()) {
                try {
                    val root = JSONObject(raw)
                    locked = root.optBoolean("lock", false)
                    todayTrades = root.optInt("trades", 0)
                    todayPnl = root.optDouble("pnl", 0.0)
                } catch (_: Exception) { }
            }

            val session = sessionAt(now)
            val remaining = if (locked) 0 else max(0, 2 - todayTrades)

            val badge = when {
                locked || remaining == 0 -> Badge.LOCKED
                session.tradable         -> Badge.ACTIVE
                else                     -> Badge.STANDBY
            }

            // Visual Trade Slots — premium glyphs with refined spacing.
            val tradesLabel: String
            val tradesColor: Int
            if (locked) {
                tradesLabel = "● ●   Plan locked"
                tradesColor = COLOR_RED
            } else {
                tradesLabel = when (remaining) {
                    2 -> "● ●   2 trades left"
                    1 -> "● ○   1 trade left"
                    else -> "○ ○   Plan complete"
                }
                tradesColor = when (remaining) {
                    2 -> COLOR_TEXT_PRIMARY
                    1 -> COLOR_AMBER
                    else -> COLOR_TEXT_TERTIARY
                }
            }

            // Formatted PnL — non-breaking spaces for premium typographic feel.
            val absPnl = abs(todayPnl).roundToInt()
            val pnlLabel = when {
                todayTrades == 0 -> "P/L  —"
                todayPnl >= 0 -> "P/L  +\$${absPnl}"
                else -> "P/L  −\$${absPnl}"
            }
            val pnlColor = when {
                todayTrades == 0 -> COLOR_TEXT_PRIMARY
                todayPnl > 0 -> COLOR_GREEN
                todayPnl < 0 -> COLOR_RED
                else -> COLOR_TEXT_PRIMARY
            }

            val nextSessionLabel = if (session.tradable) null else nextWindowHint(now)

            return Snapshot(
                sessionLabel     = session.label,
                sessionColor     = session.color,
                tradesLabel      = tradesLabel,
                tradesColor      = tradesColor,
                pnlLabel         = pnlLabel,
                pnlColor         = pnlColor,
                badge            = badge,
                nextSessionLabel = nextSessionLabel,
                updatedLabel     = "UPDATED  ${formatTime(now)}",
            )
        }

        // ── Session schedule ──────────────────────────────────────────────────
        // Boundary minutes (EAT): 540=09:00, 630=10:30, 780=13:00, 900=15:00,
        //   990=16:30, 1110=18:30, 1200=20:00
        // Tradable windows: Mid London 10:30-13:00, Late London 13:00-15:00,
        //   NY Open 16:30-18:30.

        private fun sessionAt(now: Calendar): Session {
            val t = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)
            val friday = now.get(Calendar.DAY_OF_WEEK) == Calendar.FRIDAY
            return when {
                t < 540  -> Session("Pre-London · Standby",      COLOR_NEUTRAL, false)
                t < 630  -> Session("Early London · Dead Zone",   COLOR_RED,     false)
                t < 780  -> Session("Mid London · Valid Window",  COLOR_GREEN,   true)
                t < 900  -> Session("Late London · Prime",        COLOR_GREEN,   true)
                t <= 990 -> Session("Blackout · No Execution",    COLOR_RED,     false)
                friday && t >= 1200 -> Session("Friday Kill-Switch", COLOR_RED,  false)
                t <= 1110 -> Session("NY Open · Prime",           COLOR_GREEN,   true)
                t <= 1200 -> Session("NY Mid · Caution",          COLOR_AMBER,   false)
                else      -> Session("NY Late · Standby",         COLOR_NEUTRAL, false)
            }
        }

        /** Returns "Opens in Xh Ym" countdown to next tradable window, or null if currently active. */
        private fun nextWindowHint(now: Calendar): String {
            val t = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)
            val friday = now.get(Calendar.DAY_OF_WEEK) == Calendar.FRIDAY
            
            // Determine next tradable window start (in minutes from midnight EAT)
            val nextMinute = when {
                t < 630  -> 630   // Mid London 10:30 (already in pre-window zone)
                t < 780  -> null  // Mid London is active 10:30-13:00
                t < 900  -> null  // Late London is active 13:00-15:00
                t <= 990 && !friday -> 990   // NY Open at 16:30 (after Blackout 15:00-16:30)
                friday   -> null             // Friday kill-switch: no more windows
                t <= 1110 -> null            // NY Open is active 16:30-18:30
                else      -> null            // Past all windows for today
            }
            
            if (nextMinute == null) return "No more windows today"
            
            // Calculate hours and minutes until nextMinute
            val minutesRemaining = nextMinute - t
            val hours = minutesRemaining / 60
            val minutes = minutesRemaining % 60
            
            return when {
                hours > 0 -> "Opens in ${hours}h ${minutes}m"
                else      -> "Opens in ${minutes}m"
            }
        }

        // ── Formatters ────────────────────────────────────────────────────────

        private fun isoDate(cal: Calendar): String =
            String.format(
                Locale.US, "%04d-%02d-%02d",
                cal.get(Calendar.YEAR),
                cal.get(Calendar.MONTH) + 1,
                cal.get(Calendar.DAY_OF_MONTH),
            )

        private fun formatTime(cal: Calendar): String {
            val f = SimpleDateFormat("HH:mm 'EAT'", Locale.US)
            f.timeZone = cal.timeZone
            return f.format(cal.time)
        }

        private val COLOR_GREEN          = Color.parseColor("#3DDB9A")
        private val COLOR_RED            = Color.parseColor("#FF7B72")
        private val COLOR_AMBER          = Color.parseColor("#F9C74F")
        private val COLOR_NEUTRAL        = Color.parseColor("#A7B4C6")
        private val COLOR_TEXT_PRIMARY   = Color.parseColor("#E6EEF8")
        private val COLOR_TEXT_TERTIARY  = Color.parseColor("#7A8DA8")
    }
}

private enum class Badge { ACTIVE, STANDBY, LOCKED }

private data class Session(val label: String, val color: Int, val tradable: Boolean)

private data class Snapshot(
    val sessionLabel: String,
    val sessionColor: Int,
    val tradesLabel: String,
    val tradesColor: Int,
    val pnlLabel: String,
    val pnlColor: Int,
    val badge: Badge,
    val nextSessionLabel: String?,
    val updatedLabel: String,
)