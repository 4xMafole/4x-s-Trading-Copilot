package com.example.trading_copilot_flutter

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		// ── App widget channel ──
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"refreshWidget" -> {
						TradingStatusWidgetProvider.updateAllWidgets(this)
						result.success(true)
					}
					else -> result.notImplemented()
				}
			}

		// ── Trading Guard channel ──
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, GUARD_CHANNEL)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"hasOverlayPermission" -> {
						result.success(Settings.canDrawOverlays(this))
					}
					"requestOverlayPermission" -> {
						val intent = Intent(
							Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
							Uri.parse("package:$packageName")
						)
						startActivity(intent)
						result.success(null)
					}
					"isAccessibilityEnabled" -> {
						result.success(isAccessibilityServiceEnabled())
					}
					"openAccessibilitySettings" -> {
						startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
						result.success(null)
					}
					"setOverlayState" -> {
						val enabled = call.argument<Boolean>("enabled") ?: false
						val state = call.argument<String>("state") ?: ""
						val prefs = getSharedPreferences("locotrader_overlay", MODE_PRIVATE)
						prefs.edit()
							.putBoolean("enabled", enabled)
							.putString("state", state)
							.apply()
						result.success(null)
					}
					else -> result.notImplemented()
				}
			}
	}

	private fun isAccessibilityServiceEnabled(): Boolean {
		val service = "$packageName/${TradingGuardService::class.java.canonicalName}"
		return try {
			val enabled = Settings.Secure.getInt(
				contentResolver,
				Settings.Secure.ACCESSIBILITY_ENABLED,
				0
			)
			if (enabled != 1) return false
			val services = Settings.Secure.getString(
				contentResolver,
				Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
			) ?: return false
			val splitter = TextUtils.SimpleStringSplitter(':')
			splitter.setString(services)
			splitter.any { it.equals(service, ignoreCase = true) }
		} catch (_: Exception) {
			false
		}
	}

	companion object {
		private const val WIDGET_CHANNEL = "trading_copilot/widget"
		private const val GUARD_CHANNEL = "com.locotrader.app/trading_guard"
	}
}
