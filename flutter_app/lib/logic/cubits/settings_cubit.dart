import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';

import '../../data/trading_repository.dart';
import '../../services/session_alert_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(
    this._repository, {
    SessionAlertService? sessionAlertService,
    LocalAuthentication? localAuthentication,
  }) : _sessionAlertService = sessionAlertService ?? SessionAlertService(),
       _localAuthentication = localAuthentication ?? LocalAuthentication(),
       super(const SettingsState());

  final TradingRepository _repository;
  final SessionAlertService _sessionAlertService;
  final LocalAuthentication _localAuthentication;

  static const Map<String, String> defaultSessionAlertTimes = {
    'mid_london': '10:30',
    'late_london': '13:00',
    'blackout': '15:00',
    'ny_open': '16:30',
  };
  static const Map<String, String> _sessionAlertEventLabels = {
    'mid_london': 'Mid London start',
    'late_london': 'Late London prime',
    'blackout': 'Blackout warning',
    'ny_open': 'NY open prime',
  };
  static const Map<String, String> _sessionAlertTitles = {
    'mid_london': 'Mid London open',
    'late_london': 'Late London open',
    'blackout': 'Blackout starting',
    'ny_open': 'NY open',
  };
  static const Map<String, String> _sessionAlertBodies = {
    'mid_london': '10:30 EAT. Valid setups only, stay selective.',
    'late_london': 'XAUUSD prime window.',
    'blackout': '15:00-16:30 EAT. Step away from execution.',
    'ny_open': '16:30 EAT. NY prime window is live.',
  };

  static final RegExp _alertTimePattern = RegExp(
    r'^([01]\d|2[0-3]):([0-5]\d)$',
  );

  Map<String, String> get sessionAlertEventLabels => _sessionAlertEventLabels;

  // Convenience getters for parity with the old API.
  ThemeMode get themeMode => state.themeMode;
  bool get sessionAlertsEnabled => state.sessionAlertsEnabled;
  Map<String, String> get sessionAlertTimes =>
      Map<String, String>.unmodifiable(state.sessionAlertTimes);
  bool get biometricLockEnabled => state.biometricLockEnabled;

  Future<void> init() async {
    final theme = await _repository.getThemeMode();
    final bioLocked = await _repository.getBiometricLockEnabled();
    final alertsEnabled = await _repository.getSessionAlertsEnabled();
    final hasSeenWalkthrough = await _repository.hasSeenWalkthrough();

    final timesStr = await _repository.getSessionAlertTimes();
    Map<String, String> storedTimes = Map<String, String>.from(
      defaultSessionAlertTimes,
    );
    if (timesStr != null && timesStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(timesStr);
        if (decoded is Map) {
          for (final key in defaultSessionAlertTimes.keys) {
            final value = decoded[key];
            if (value is String && _isValidAlertTime(value.trim())) {
              storedTimes[key] = value.trim();
            }
          }
        }
      } catch (_) {}
    }

    emit(
      state.copyWith(
        themeMode: theme,
        biometricLockEnabled: bioLocked,
        sessionAlertsEnabled: alertsEnabled,
        sessionAlertTimes: storedTimes,
        hasSeenWalkthrough: hasSeenWalkthrough,
        isLoading: false,
      ),
    );

    if (alertsEnabled) {
      unawaited(_syncSessionAlertsSilently());
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state.themeMode == mode) return;
    await _repository.setThemeMode(mode);
    emit(state.copyWith(themeMode: mode));
  }

  Future<bool> setSessionAlertsEnabled(bool enabled) async {
    if (state.sessionAlertsEnabled == enabled) return true;

    if (enabled) {
      final synced = await _syncSessionAlerts();
      if (!synced) return false;
    } else {
      try {
        await _sessionAlertService.disableSessionAlerts();
      } catch (_) {}
    }

    await _repository.setSessionAlertsEnabled(enabled);
    emit(state.copyWith(sessionAlertsEnabled: enabled));
    return true;
  }

  Future<bool> rescheduleSessionAlertsNow() async {
    if (!state.sessionAlertsEnabled) return false;
    return _syncSessionAlerts();
  }

  Future<bool> updateSessionAlertTimes(Map<String, String> nextTimes) async {
    final normalized = Map<String, String>.from(defaultSessionAlertTimes);
    for (final key in defaultSessionAlertTimes.keys) {
      final raw = (nextTimes[key] ?? defaultSessionAlertTimes[key]!).trim();
      if (!_isValidAlertTime(raw)) return false;
      normalized[key] = raw;
    }

    await _repository.setSessionAlertTimes(jsonEncode(normalized));
    emit(state.copyWith(sessionAlertTimes: normalized));

    if (state.sessionAlertsEnabled) {
      final synced = await _syncSessionAlerts();
      if (!synced) return false;
    }
    return true;
  }

  Future<bool> resetSessionAlertTimes() async {
    final defaults = Map<String, String>.from(defaultSessionAlertTimes);
    await _repository.setSessionAlertTimes(jsonEncode(defaults));
    emit(state.copyWith(sessionAlertTimes: defaults));

    if (state.sessionAlertsEnabled) {
      return _syncSessionAlerts();
    }
    return true;
  }

  Future<bool> setBiometricLockEnabled(bool enabled) async {
    if (state.biometricLockEnabled == enabled) return true;

    if (enabled) {
      final supported = await _isBiometricSupported();
      if (!supported) return false;
      final confirmed = await authenticateBiometric(
        reason: 'Confirm biometric lock setup for 4x Trades',
        ignoreSetting: true,
      );
      if (!confirmed) return false;
    }

    await _repository.setBiometricLockEnabled(enabled);
    emit(state.copyWith(biometricLockEnabled: enabled));
    return true;
  }

  Future<bool> authenticateBiometric({
    String reason = 'Unlock 4x Trades',
    bool ignoreSetting = false,
  }) async {
    if (!ignoreSetting && !state.biometricLockEnabled) return true;
    try {
      return await _localAuthentication.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: false,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> setHasSeenWalkthrough(bool seen) async {
    await _repository.setHasSeenWalkthrough(seen);
    emit(state.copyWith(hasSeenWalkthrough: seen));
  }

  Future<bool> _syncSessionAlertsSilently() async {
    try {
      await _sessionAlertService.enableSessionAlerts(_buildSchedules());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _syncSessionAlerts() async {
    try {
      return await _sessionAlertService.enableSessionAlerts(_buildSchedules());
    } catch (_) {
      return false;
    }
  }

  Future<bool> _isBiometricSupported() async {
    try {
      final isSupported = await _localAuthentication.isDeviceSupported();
      final canCheck = await _localAuthentication.canCheckBiometrics;
      final available = await _localAuthentication.getAvailableBiometrics();
      return isSupported && (canCheck || available.isNotEmpty);
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  List<SessionAlertSchedule> _buildSchedules() {
    final schedules = <SessionAlertSchedule>[];
    for (final key in defaultSessionAlertTimes.keys) {
      final value =
          (state.sessionAlertTimes[key] ?? defaultSessionAlertTimes[key]!)
              .trim();
      if (!_isValidAlertTime(value)) continue;
      schedules.add(
        SessionAlertSchedule(
          eventKey: key,
          hour: int.parse(value.substring(0, 2)),
          minute: int.parse(value.substring(3, 5)),
          title: _sessionAlertTitles[key] ?? key,
          body: _sessionAlertBodies[key] ?? '',
        ),
      );
    }
    return schedules;
  }

  bool _isValidAlertTime(String value) => _alertTimePattern.hasMatch(value);
}
