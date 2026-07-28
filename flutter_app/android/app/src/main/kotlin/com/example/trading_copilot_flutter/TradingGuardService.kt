package com.example.trading_copilot_flutter

import android.accessibilityservice.AccessibilityService
import android.content.SharedPreferences
import android.view.accessibility.AccessibilityEvent
import org.json.JSONObject

/**
 * Trading Guard — Accessibility Service
 *
 * Monitors foreground app changes. When a monitored trading app is detected,
 * reads the overlay state from SharedPreferences (written by Flutter) and
 * shows the TradeOverlayManager if the readiness score is below threshold
 * and Trading Guard is enabled.
 */
class TradingGuardService : AccessibilityService() {

    private lateinit var overlayManager: TradeOverlayManager
    private lateinit var prefs: SharedPreferences

    // Apps to monitor — add broker/trading apps here
    private val TRADING_APPS = setOf(
        "net.metaquotes.metatrader4",
        "net.metaquotes.metatrader5",
        "com.spotware.ct",               // cTrader
        "com.tradingview.tradingviewapp", // TradingView
        "com.binance.dev",               // Binance
        "com.bybit.app",                 // Bybit
        "com.htfinvest.htf",             // FTMO HTF
        "com.easymarkets.easymarkets",
        "com.ig.client",                 // IG
        "com.etoro.mobile",              // eToro
        "com.xm.group",                  // XM
    )

    // Friendly names for display
    private val APP_NAMES = mapOf(
        "net.metaquotes.metatrader4" to "MetaTrader 4",
        "net.metaquotes.metatrader5" to "MetaTrader 5",
        "com.spotware.ct" to "cTrader",
        "com.tradingview.tradingviewapp" to "TradingView",
        "com.binance.dev" to "Binance",
        "com.bybit.app" to "Bybit",
        "com.htfinvest.htf" to "FTMO",
    )

    private var lastShownPackage = ""
    private var lastShownTime = 0L
    // Cooldown: don't show overlay again for 5 minutes after dismiss
    private val COOLDOWN_MS = 5 * 60 * 1000L

    override fun onServiceConnected() {
        super.onServiceConnected()
        overlayManager = TradeOverlayManager(applicationContext)
        prefs = getSharedPreferences("locotrader_overlay", MODE_PRIVATE)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val pkg = event.packageName?.toString() ?: return

        // Skip if it's our own app
        if (pkg == packageName) return
        if (!TRADING_APPS.contains(pkg)) return

        // Check if overlay is enabled
        if (!prefs.getBoolean("enabled", false)) return

        // Cooldown check — don't spam the overlay
        val now = System.currentTimeMillis()
        if (pkg == lastShownPackage && (now - lastShownTime) < COOLDOWN_MS) return

        // Read the current gate/readiness state Flutter wrote to prefs
        val stateJson = prefs.getString("state", null) ?: return
        val state = runCatching { JSONObject(stateJson) }.getOrNull() ?: return

        val readinessScore = state.optInt("score", 0)
        val incompletedGates = mutableListOf<String>()
        val gatesArray = state.optJSONArray("incomplete_gates")
        if (gatesArray != null) {
            for (i in 0 until gatesArray.length()) {
                incompletedGates.add(gatesArray.getString(i))
            }
        }
        val isLocked = state.optBoolean("locked", false)

        // If fully ready and not locked, skip overlay
        if (readinessScore >= 100 && !isLocked && incompletedGates.isEmpty()) return

        val appName = APP_NAMES[pkg] ?: pkg.substringAfterLast(".")
        lastShownPackage = pkg
        lastShownTime = now

        overlayManager.show(
            appName = appName,
            readinessScore = readinessScore,
            incompleteGates = incompletedGates,
            isLocked = isLocked,
        )
    }

    override fun onInterrupt() {
        overlayManager.hide()
    }

    override fun onDestroy() {
        super.onDestroy()
        overlayManager.hide()
    }
}
