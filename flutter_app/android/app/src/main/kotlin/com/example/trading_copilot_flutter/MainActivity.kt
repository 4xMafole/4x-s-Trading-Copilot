package com.example.trading_copilot_flutter

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

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
	}

	companion object {
		private const val WIDGET_CHANNEL = "trading_copilot/widget"
	}
}
