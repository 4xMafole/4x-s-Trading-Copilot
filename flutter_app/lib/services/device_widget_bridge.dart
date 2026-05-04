import 'dart:io';

import 'package:flutter/services.dart';

class DeviceWidgetBridge {
  static const MethodChannel _channel = MethodChannel('trading_copilot/widget');

  static Future<void> refresh() async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('refreshWidget');
    } catch (_) {
      // Widget refresh is best-effort.
    }
  }
}
