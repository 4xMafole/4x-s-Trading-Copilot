import 'dart:convert';
import 'package:flutter/services.dart';

/// Flutter-to-Android bridge for the Trading Guard overlay feature.
///
/// Communicates with native code via MethodChannel to:
///  - Check/request permissions
///  - Enable/disable the service
///  - Push current gate state so the overlay can display it
class TradingGuardBridge {
  TradingGuardBridge._();
  static final instance = TradingGuardBridge._();

  static const _channel = MethodChannel('com.locotrader.app/trading_guard');

  /// Whether the "Display over other apps" permission is granted.
  Future<bool> hasOverlayPermission() async {
    try {
      return await _channel.invokeMethod<bool>('hasOverlayPermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Opens Android Settings for the user to grant overlay permission.
  Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (_) {}
  }

  /// Whether the Accessibility Service is currently enabled for LocoTrader.
  Future<bool> isAccessibilityServiceEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isAccessibilityEnabled') ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// Opens Android Accessibility Settings so the user can enable the service.
  Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  /// Push the current overlay state (score, gates, lock) to SharedPreferences
  /// so the native AccessibilityService can read it without running Flutter.
  Future<void> pushOverlayState({
    required bool enabled,
    required int readinessScore,
    required List<String> incompleteGates,
    required bool isLocked,
  }) async {
    final state = jsonEncode({
      'score': readinessScore,
      'incomplete_gates': incompleteGates,
      'locked': isLocked,
    });
    try {
      await _channel.invokeMethod('setOverlayState', {
        'enabled': enabled,
        'state': state,
      });
    } catch (_) {}
  }
}
