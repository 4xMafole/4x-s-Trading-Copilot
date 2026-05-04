import 'dart:io';

import 'package:flutter/services.dart';

import '../data/models.dart';

class LiveActivityBridge {
  static const MethodChannel _channel =
      MethodChannel('trading_copilot/live_activity');

  static String? _lastSyncKey;

  static Future<void> syncSessionSnapshot({
    required DateTime nowEat,
    required SessionInfo session,
    required int tradesRemaining,
  }) async {
    if (!Platform.isIOS) return;

    final syncKey =
        '${_formatEatDate(nowEat)} ${nowEat.toUtc().hour.toString().padLeft(2, '0')}:${nowEat.toUtc().minute.toString().padLeft(2, '0')}|${session.label}|$tradesRemaining';
    if (_lastSyncKey == syncKey) return;
    _lastSyncKey = syncKey;

    final payload = {
      'sessionLabel': session.label,
      'tradesRemaining': tradesRemaining,
      'eatTime':
          '${nowEat.toUtc().hour.toString().padLeft(2, '0')}:${nowEat.toUtc().minute.toString().padLeft(2, '0')} EAT',
    };

    try {
      await _channel.invokeMethod('syncSessionActivity', payload);
    } catch (_) {
      // Live activity sync is best-effort.
    }
  }

  static Future<void> endSessionActivity() async {
    if (!Platform.isIOS) return;
    _lastSyncKey = null;

    try {
      await _channel.invokeMethod('endSessionActivity');
    } catch (_) {
      // Live activity end is best-effort.
    }
  }

  static String _formatEatDate(DateTime eat) {
    final y = eat.toUtc().year.toString().padLeft(4, '0');
    final m = eat.toUtc().month.toString().padLeft(2, '0');
    final d = eat.toUtc().day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
