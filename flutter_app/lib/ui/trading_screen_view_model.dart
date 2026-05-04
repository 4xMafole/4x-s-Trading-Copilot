import 'package:flutter/material.dart' show ThemeMode;

import '../data/models.dart';
import '../logic/cubits/settings_cubit.dart';
import '../logic/cubits/trading_core_cubit.dart';

/// Aggregates both [TradingCoreCubit] and [SettingsCubit] behind a single
/// screen-scoped ViewModel that mirrors the legacy controller surface.
///
/// The ViewModel is an immutable adapter: it carries no listenable state of
/// its own. Reactivity happens at the host widget via BlocBuilder. UI-only
/// state (the active bottom tab) is supplied by the host.
class TradingScreenViewModel {
  TradingScreenViewModel({
    required this.trading,
    required this.settings,
    required this.activeTab,
    required this.setActiveTab,
  });

  final TradingCoreCubit trading;
  final SettingsCubit settings;
  final int activeTab;
  final void Function(int) setActiveTab;

  // ── Trading state passthroughs ───────────────────────────────────────────
  AppState get state => trading.appState;
  DateTime get nowEAT => trading.nowEAT;

  /// Storage encryption status (AES-256 via Hive). Surfaced in Settings.
  bool get encryptionEnabled => trading.encryptionEnabled;

  /// Re-key the encrypted store. Existing data is preserved.
  Future<void> rotateEncryptionKey() => trading.rotateEncryptionKey();

  List<Trade> getTodayTrades() => trading.getTodayTrades();
  int getTradesRemainingToday() => trading.getTradesRemainingToday();
  double getTodayPnl() => trading.getTodayPnl();
  double getChallengePnl() => trading.getChallengePnl();
  int getDayNumber() => trading.getDayNumber();
  Map<String, bool> computeAutoGates() => trading.computeAutoGates();
  SessionInfo getSessionInfo() => trading.getSessionInfo();
  List<Trade> getTradesByDate(String date) => trading.getTradesByDate(date);
  List<Trade> getRealTradesDesc() => trading.getRealTradesDesc();
  List<Trade> getAllTradesDesc() => trading.getAllTradesDesc();
  List<String> getAllTradeDates() => trading.getAllTradeDates();
  String exportData() => trading.exportData();
  String exportAsJson() => trading.exportAsJson();
  String exportAsCsv() => trading.exportAsCsv();

  Future<void> updateState({
    double? balance,
    String? startDate,
    double? priorPnl,
  }) => trading.updateState(
    balance: balance,
    startDate: startDate,
    priorPnl: priorPnl,
  );

  Future<void> addTrade({
    required String sym,
    required String dir,
    required double lots,
    required double pnl,
    required String note,
    required List<String> violations,
    List<String> tags = const <String>[],
    String? htfImage,
    String? ltfImage,
    String? date,
    String? time,
    bool isHypothetical = false,
  }) => trading.addTrade(
    sym: sym,
    dir: dir,
    lots: lots,
    pnl: pnl,
    note: note,
    violations: violations,
    tags: tags,
    htfImage: htfImage,
    ltfImage: ltfImage,
    date: date,
    time: time,
    isHypothetical: isHypothetical,
  );

  Future<void> deleteTrade(String id) => trading.deleteTrade(id);
  Future<void> updateTrade(Trade updated) => trading.updateTrade(updated);
  Future<void> restoreTrade(Trade trade) => trading.restoreTrade(trade);
  Future<void> toggleCheck(String id) => trading.toggleCheck(id);
  Future<void> resetChecks(List<String> gateIds) =>
      trading.resetChecks(gateIds);
  Future<void> resetToday() => trading.resetToday();
  Future<void> resetAll() => trading.resetAll();

  Future<ImportResult> importJsonData(
    String data, {
    bool merge = false,
    bool dryRun = false,
  }) => trading.importJsonData(data, merge: merge, dryRun: dryRun);

  Future<ImportResult> importCsvData(
    String data, {
    bool merge = false,
    bool dryRun = false,
  }) => trading.importCsvData(data, merge: merge, dryRun: dryRun);

  // ── Settings passthroughs ────────────────────────────────────────────────
  ThemeMode get themeMode => settings.themeMode;
  bool get sessionAlertsEnabled => settings.sessionAlertsEnabled;
  Map<String, String> get sessionAlertTimes => settings.sessionAlertTimes;
  Map<String, String> get sessionAlertEventLabels =>
      settings.sessionAlertEventLabels;
  bool get biometricLockEnabled => settings.biometricLockEnabled;

  Future<void> setThemeMode(ThemeMode mode) => settings.setThemeMode(mode);
  Future<bool> setSessionAlertsEnabled(bool enabled) =>
      settings.setSessionAlertsEnabled(enabled);
  Future<bool> rescheduleSessionAlertsNow() =>
      settings.rescheduleSessionAlertsNow();
  Future<bool> updateSessionAlertTimes(Map<String, String> nextTimes) =>
      settings.updateSessionAlertTimes(nextTimes);
  Future<bool> resetSessionAlertTimes() => settings.resetSessionAlertTimes();
  Future<bool> setBiometricLockEnabled(bool enabled) =>
      settings.setBiometricLockEnabled(enabled);
  Future<bool> authenticateBiometric({
    String reason = 'Unlock 4x Trades',
    bool ignoreSetting = false,
  }) => settings.authenticateBiometric(
    reason: reason,
    ignoreSetting: ignoreSetting,
  );
}
