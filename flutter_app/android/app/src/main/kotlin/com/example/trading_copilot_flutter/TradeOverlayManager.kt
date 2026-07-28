package com.example.trading_copilot_flutter

import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.*
import android.widget.*

/**
 * TradeOverlayManager
 *
 * Creates and manages a system overlay window (TYPE_APPLICATION_OVERLAY) that
 * appears on top of trading apps when the user's gates are incomplete.
 *
 * Requires SYSTEM_ALERT_WINDOW permission ("Display over other apps").
 */
class TradeOverlayManager(private val context: Context) {

    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private var overlayView: View? = null
    private val handler = Handler(Looper.getMainLooper())

    fun show(
        appName: String,
        readinessScore: Int,
        incompleteGates: List<String>,
        isLocked: Boolean,
    ) {
        if (!Settings.canDrawOverlays(context)) return
        if (overlayView != null) return // already visible

        handler.post {
            val view = buildOverlayView(appName, readinessScore, incompleteGates, isLocked)
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                else
                    @Suppress("DEPRECATION")
                    WindowManager.LayoutParams.TYPE_SYSTEM_ALERT,
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.TRANSLUCENT
            )
            try {
                windowManager.addView(view, params)
                overlayView = view
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    fun hide() {
        handler.post {
            overlayView?.let {
                try { windowManager.removeView(it) } catch (_: Exception) {}
                overlayView = null
            }
        }
    }

    private fun buildOverlayView(
        appName: String,
        readinessScore: Int,
        incompleteGates: List<String>,
        isLocked: Boolean,
    ): View {
        val layout = FrameLayout(context)

        // ── Semi-transparent dark backdrop ──
        val backdrop = View(context).apply {
            setBackgroundColor(Color.argb(180, 5, 5, 8))
        }
        layout.addView(backdrop, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        ))

        // ── Card container ──
        val card = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(24), dp(28), dp(24), dp(28))
            background = cardBackground()
        }
        val cardParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            gravity = Gravity.CENTER_VERTICAL
            setMargins(dp(24), 0, dp(24), 0)
        }
        layout.addView(card, cardParams)

        // ── App detected label ──
        card.addView(TextView(context).apply {
            text = "$appName detected"
            textSize = 11f
            setTextColor(Color.argb(150, 255, 255, 255))
            letterSpacing = 0.12f
            setPadding(0, 0, 0, dp(8))
        })

        if (isLocked) {
            // ── Lock state ──
            card.addView(TextView(context).apply {
                text = "Account Locked"
                textSize = 22f
                setTextColor(Color.rgb(255, 123, 114))
                typeface = android.graphics.Typeface.DEFAULT_BOLD
                setPadding(0, 0, 0, dp(8))
            })
            card.addView(TextView(context).apply {
                text = "Your account is locked after consecutive losses. Come back tomorrow."
                textSize = 14f
                setTextColor(Color.argb(180, 255, 255, 255))
                setLineSpacing(0f, 1.4f)
                setPadding(0, 0, 0, dp(20))
            })
        } else {
            // ── Readiness score ──
            val scoreColor = when {
                readinessScore >= 80 -> Color.rgb(61, 219, 154)  // green
                readinessScore >= 50 -> Color.rgb(249, 199, 79)  // amber
                else -> Color.rgb(255, 123, 114)                 // red
            }
            card.addView(TextView(context).apply {
                text = "Readiness: $readinessScore%"
                textSize = 22f
                setTextColor(scoreColor)
                typeface = android.graphics.Typeface.DEFAULT_BOLD
                setPadding(0, 0, 0, dp(6))
            })

            // ── Headline ──
            card.addView(TextView(context).apply {
                text = if (incompleteGates.isEmpty())
                    "Your checklist is complete."
                else
                    "Your pre-trade checklist is incomplete."
                textSize = 15f
                setTextColor(Color.WHITE)
                typeface = android.graphics.Typeface.DEFAULT_BOLD
                setPadding(0, 0, 0, dp(12))
            })

            // ── Incomplete gates list ──
            if (incompleteGates.isNotEmpty()) {
                val showGates = incompleteGates.take(4)
                showGates.forEach { gate ->
                    card.addView(TextView(context).apply {
                        text = "  ✗  $gate"
                        textSize = 13f
                        setTextColor(Color.argb(180, 255, 180, 150))
                        setPadding(0, dp(3), 0, dp(3))
                    })
                }
                if (incompleteGates.size > 4) {
                    card.addView(TextView(context).apply {
                        text = "  + ${incompleteGates.size - 4} more..."
                        textSize = 12f
                        setTextColor(Color.argb(120, 255, 255, 255))
                        setPadding(0, dp(3), 0, 0)
                    })
                }
                card.addView(View(context).apply { minimumHeight = dp(16) })
            }
        }

        // ── Divider ──
        card.addView(View(context).apply {
            minimumHeight = dp(1)
            setBackgroundColor(Color.argb(40, 255, 255, 255))
            minimumWidth = FrameLayout.LayoutParams.MATCH_PARENT
        })
        card.addView(View(context).apply { minimumHeight = dp(16) })

        // ── Buttons ──
        val buttonRow = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
        }

        // Skip (trade without checklist)
        val skipBtn = Button(context).apply {
            text = "Trade anyway"
            textSize = 13f
            setTextColor(Color.argb(150, 255, 100, 100))
            setBackgroundColor(Color.TRANSPARENT)
            setOnClickListener { hide() }
        }
        buttonRow.addView(skipBtn, LinearLayout.LayoutParams(0, FrameLayout.LayoutParams.WRAP_CONTENT, 1f))

        // Confirm with countdown
        val confirmBtn = Button(context)
        confirmBtn.text = if (isLocked) "OK" else "I've reviewed (3s)"
        confirmBtn.textSize = 13f
        confirmBtn.background = confirmButtonBackground()
        confirmBtn.isEnabled = false
        confirmBtn.setTextColor(Color.argb(150, 255, 255, 255))
        buttonRow.addView(confirmBtn, LinearLayout.LayoutParams(0, FrameLayout.LayoutParams.WRAP_CONTENT, 1f))
        card.addView(buttonRow)

        // ── Countdown to enable confirm ──
        var secondsLeft = if (isLocked) 0 else 3
        if (secondsLeft == 0) {
            confirmBtn.isEnabled = true
            confirmBtn.text = if (isLocked) "OK" else "I've reviewed"
            confirmBtn.setTextColor(Color.WHITE)
        } else {
            val ticker = object : Runnable {
                override fun run() {
                    if (secondsLeft > 0) {
                        secondsLeft--
                        confirmBtn.text = if (secondsLeft == 0) "I've reviewed ✓"
                            else "I've reviewed (${secondsLeft}s)"
                        if (secondsLeft == 0) {
                            confirmBtn.isEnabled = true
                            confirmBtn.setTextColor(Color.WHITE)
                        }
                        handler.postDelayed(this, 1000)
                    }
                }
            }
            handler.postDelayed(ticker, 1000)
        }

        confirmBtn.setOnClickListener { hide() }

        return layout
    }

    // ── Helpers ──

    private fun dp(value: Int): Int =
        (value * context.resources.displayMetrics.density + 0.5f).toInt()

    private fun cardBackground(): android.graphics.drawable.Drawable {
        return GradientDrawable().apply {
            setColor(Color.rgb(13, 13, 24))
            cornerRadius = dp(20).toFloat()
            setStroke(dp(1), Color.argb(60, 255, 255, 255))
        }
    }

    private fun confirmButtonBackground(): android.graphics.drawable.Drawable {
        return GradientDrawable().apply {
            setColor(Color.rgb(59, 130, 246))
            cornerRadius = dp(10).toFloat()
        }
    }
}
