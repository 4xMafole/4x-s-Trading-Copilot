import 'package:flutter/material.dart' show ThemeMode;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(false) bool biometricLockEnabled,
    @Default(false) bool sessionAlertsEnabled,
    @Default(<String, String>{}) Map<String, String> sessionAlertTimes,
    @Default(false) bool hasSeenWalkthrough,
    @Default(true) bool isLoading,
  }) = _SettingsState;
}
