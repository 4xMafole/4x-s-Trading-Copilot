package com.example.trading_copilot_flutter

import android.content.Context
import android.graphics.*
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.TypedValue
import android.view.*
import android.widget.*

/**
 * TradeOverlayManager — redesigned to match the LocoTrader design system.
 * Dark navy card, blue accent, Inter-style type, brand logo, always-visible buttons.
 */
class TradeOverlayManager(private val context: Context) {

    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private var overlayView: View? = null
    private val handler = Handler(Looper.getMainLooper())

    // ── Design tokens ─────────────────────────────────────────────────────────
    private val colorBg        = Color.parseColor("#090912")
    private val colorCard      = Color.parseColor("#0D0D18")
    private val colorBorder    = Color.parseColor("#1A1A30")
    private val colorBlue      = Color.parseColor("#3B82F6")
    private val colorBlueLight = Color.parseColor("#60A5FA")
    private val colorGreen     = Color.parseColor("#3DDB9A")
    private val colorAmber     = Color.parseColor("#F9C74F")
    private val colorRed       = Color.parseColor("#FF7B72")
    private val colorText      = Color.parseColor("#F2F6FB")
    private val colorSub       = Color.parseColor("#9BA8BD")
    private val colorMuted     = Color.parseColor("#5C6B82")

    fun show(appName: String, readinessScore: Int, incompleteGates: List<String>, isLocked: Boolean) {
        if (!Settings.canDrawOverlays(context)) return
        if (overlayView != null) return
        handler.post {
            val view = buildOverlay(appName, readinessScore, incompleteGates, isLocked)
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                else @Suppress("DEPRECATION") WindowManager.LayoutParams.TYPE_SYSTEM_ALERT,
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.TRANSLUCENT
            )
            try { windowManager.addView(view, params); overlayView = view }
            catch (e: Exception) { e.printStackTrace() }
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

    // ── Build overlay ─────────────────────────────────────────────────────────

    private fun buildOverlay(
        appName: String,
        readinessScore: Int,
        incompleteGates: List<String>,
        isLocked: Boolean,
    ): View {
        val root = FrameLayout(context)

        // ── Backdrop (gradient from transparent top → dark bottom) ──
        val backdrop = View(context)
        backdrop.background = GradientDrawable(
            GradientDrawable.Orientation.TOP_BOTTOM,
            intArrayOf(Color.argb(120, 5, 5, 8), Color.argb(210, 5, 5, 8))
        )
        backdrop.setOnClickListener { /* consume touches */ }
        root.addView(backdrop, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        ))

        // ── Card wrapper (anchored near bottom) ──
        val cardOuter = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
        val cardOuterParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.WRAP_CONTENT
        ).apply { gravity = Gravity.BOTTOM }
        root.addView(cardOuter, cardOuterParams)

        // Blue accent stripe at top of card
        val accent = View(context)
        accent.background = GradientDrawable(
            GradientDrawable.Orientation.LEFT_RIGHT,
            intArrayOf(Color.TRANSPARENT, colorBlue, colorBlue, Color.TRANSPARENT)
        )
        cardOuter.addView(accent, LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT, dp(2)
        ))

        // Card body
        val card = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(20), dp(20), dp(20), dp(28))
            background = cardDrawable()
        }
        cardOuter.addView(card, LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ))

        // ── Card header: logo + app label ──
        val header = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(0, 0, 0, dp(16))
        }
        header.addView(LogoView(context, dp(20)), LinearLayout.LayoutParams(dp(20), dp(20)))
        header.addView(View(context).apply { minimumWidth = dp(8) }, LinearLayout.LayoutParams(dp(8), 1))
        header.addView(tv("LocoTrader", 13f, colorBlueLight, bold = true),
            LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
        header.addView(tv(appName.uppercase(), 10f, colorMuted, letterSpacing = 0.10f))
        card.addView(header)

        // ── Thin divider ──
        card.addView(divider(colorBorder), LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT, dp(1)
        ).also { it.bottomMargin = dp(16) })

        if (isLocked) {
            // ── Locked state ──
            card.addView(tv("🔒  Account Locked", 20f, colorRed, bold = true)
                .also { it.setPadding(0, 0, 0, dp(8)) })
            card.addView(tv("Your account is locked after consecutive losses.\nStep away and come back tomorrow.", 13f, colorSub))
        } else {
            // ── Score row ──
            val scoreColor = when {
                readinessScore >= 80 -> colorGreen
                readinessScore >= 50 -> colorAmber
                else -> colorRed
            }
            val scoreRow = LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                setPadding(0, 0, 0, dp(4))
            }
            scoreRow.addView(tv("$readinessScore%", 36f, scoreColor, bold = true))
            scoreRow.addView(View(context).apply { minimumWidth = dp(10) }, LinearLayout.LayoutParams(dp(10), 1))
            val scoreDesc = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
            scoreDesc.addView(tv("Readiness", 11f, colorMuted, letterSpacing = 0.08f))
            scoreDesc.addView(tv(
                if (incompleteGates.isEmpty()) "All clear ✓" else "Checklist incomplete",
                13f, if (incompleteGates.isEmpty()) colorGreen else colorText, bold = true
            ))
            scoreRow.addView(scoreDesc)
            card.addView(scoreRow)

            // ── Gate pills (max 3) ──
            if (incompleteGates.isNotEmpty()) {
                card.addView(View(context).also { it.minimumHeight = dp(12) })
                val showGates = incompleteGates.take(3)
                showGates.forEach { gate ->
                    val row = LinearLayout(context).apply {
                        orientation = LinearLayout.HORIZONTAL
                        gravity = Gravity.CENTER_VERTICAL
                        setPadding(0, dp(2), 0, dp(2))
                    }
                    row.addView(tv("✕", 11f, colorRed))
                    row.addView(View(context).also { it.minimumWidth = dp(8) }, LinearLayout.LayoutParams(dp(8), 1))
                    row.addView(tv(gate, 13f, Color.argb(200, 255, 200, 180)))
                    card.addView(row)
                }
                if (incompleteGates.size > 3) {
                    card.addView(View(context).also { it.minimumHeight = dp(4) })
                    card.addView(tv("+ ${incompleteGates.size - 3} more gates", 11f, colorMuted))
                }
            }
        }

        // ── Bottom buttons (always visible) ──
        card.addView(View(context).also { it.minimumHeight = dp(18) })
        card.addView(divider(colorBorder), LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT, dp(1)
        ).also { it.bottomMargin = dp(16) })

        val btnRow = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }

        // "Trade anyway" button
        val skipBtn = Button(context)
        skipBtn.text = "Trade anyway"
        skipBtn.textSize = 13f
        skipBtn.setTextColor(Color.argb(160, 255, 100, 100))
        skipBtn.background = null
        skipBtn.isAllCaps = false
        skipBtn.setOnClickListener { hide() }
        btnRow.addView(skipBtn, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))

        // "I've reviewed (3s)" button — enabled after countdown
        val confirmBtn = Button(context)
        confirmBtn.text = "I've reviewed (3s)"
        confirmBtn.textSize = 13f
        confirmBtn.isAllCaps = false
        confirmBtn.background = pillButton(colorBlue.also { _ -> }, enabled = false)
        confirmBtn.setTextColor(Color.argb(130, 255, 255, 255))
        confirmBtn.isEnabled = false
        btnRow.addView(confirmBtn, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
        card.addView(btnRow)

        // ── Countdown logic ──
        val totalSecs = if (isLocked) 0 else 3
        if (totalSecs == 0) {
            confirmBtn.isEnabled = true
            confirmBtn.text = if (isLocked) "OK" else "I've reviewed ✓"
            confirmBtn.background = pillButton(colorBlue, enabled = true)
            confirmBtn.setTextColor(Color.WHITE)
        } else {
            var left = totalSecs
            val ticker = object : Runnable {
                override fun run() {
                    if (overlayView == null) return
                    left--
                    if (left <= 0) {
                        confirmBtn.isEnabled = true
                        confirmBtn.text = "I've reviewed ✓"
                        confirmBtn.background = pillButton(colorBlue, enabled = true)
                        confirmBtn.setTextColor(Color.WHITE)
                    } else {
                        confirmBtn.text = "I've reviewed (${left}s)"
                        handler.postDelayed(this, 1000)
                    }
                }
            }
            handler.postDelayed(ticker, 1000)
        }
        confirmBtn.setOnClickListener { hide() }

        return root
    }

    // ── View helpers ──────────────────────────────────────────────────────────

    private fun tv(
        text: String,
        size: Float,
        color: Int,
        bold: Boolean = false,
        letterSpacing: Float = 0f,
    ) = TextView(context).apply {
        this.text = text
        textSize = size
        setTextColor(color)
        if (bold) typeface = Typeface.DEFAULT_BOLD
        if (letterSpacing != 0f) this.letterSpacing = letterSpacing
    }

    private fun divider(color: Int) = View(context).apply { setBackgroundColor(color) }

    private fun cardDrawable() = GradientDrawable().apply {
        setColor(colorCard)
        cornerRadii = floatArrayOf(dp(22f), dp(22f), dp(22f), dp(22f), 0f, 0f, 0f, 0f)
        setStroke(dp(1), colorBorder)
    }

    private fun pillButton(color: Int, enabled: Boolean) = GradientDrawable().apply {
        setColor(if (enabled) color else Color.argb(60, 59, 130, 246))
        cornerRadius = dp(12f)
    }

    private fun dp(value: Int): Int =
        (value * context.resources.displayMetrics.density + 0.5f).toInt()

    private fun dp(value: Float): Float =
        value * context.resources.displayMetrics.density

    // ── Brand logo (custom View drawing the two intersecting planes) ──────────

    inner class LogoView(context: Context, private val sizePx: Int) : View(context) {
        private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        private val back = Path()
        private val front = Path()
        private val inter = Path()

        init {
            // Paths defined in a 64×64 space — scaled on draw
            back.apply { moveTo(10f,44f); lineTo(28f,12f); lineTo(38f,12f); lineTo(20f,44f); close() }
            front.apply { moveTo(26f,52f); lineTo(44f,20f); lineTo(54f,20f); lineTo(36f,52f); close() }
            inter.apply { moveTo(26f,44f); lineTo(28f,12f); lineTo(38f,12f); lineTo(36f,44f); close() }
        }

        override fun onMeasure(w: Int, h: Int) = setMeasuredDimension(sizePx, sizePx)

        override fun onDraw(canvas: Canvas) {
            val scale = sizePx / 64f
            canvas.scale(scale, scale)
            paint.color = Color.argb(89, 59, 130, 246)  // 35%
            canvas.drawPath(back, paint)
            paint.color = colorBlue
            canvas.drawPath(front, paint)
            paint.color = Color.argb(64, 96, 165, 250)  // 25%
            canvas.drawPath(inter, paint)
        }
    }
}


/**
 * TradeOverlayManager
 *
 * Creates and manages a system overlay window (TYPE_APPLICATION_OVERLAY) that
 * appears on top of trading apps when the user's gates are incomplete.
 *
 * Requires SYSTEM_ALERT_WINDOW permission ("Display over other apps").
 */
