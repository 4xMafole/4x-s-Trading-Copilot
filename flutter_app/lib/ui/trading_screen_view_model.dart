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
    this.requestLogTrade,
  });

  final TradingCoreCubit trading;
  final SettingsCubit settings;
  final int activeTab;
  final void Function(int) setActiveTab;

  /// Optional bridge from any tab back to the host screen so that callers
  /// (e.g. the Trade Flow wizard) can switch to the Journal tab AND open
  /// the log-trade sheet pre-filled with a wizard draft in one shot.
  final void Function(WizardDraft? draft)? requestLogTrade;

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

  Future<Trade> addTrade({
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
    String? setupQuality,
    String? trigger,
    double? plannedRisk,
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
    setupQuality: setupQuality,
    trigger: trigger,
    plannedRisk: plannedRisk,
  );

  Future<void> setReflection(String tradeId, TradeReflection r) =>
      trading.setReflection(tradeId, r);

  DailyMood? getTodayMood() => trading.getTodayMood();
  Future<void> setTodayMood(String mood, {String note = ''}) =>
      trading.setTodayMood(mood, note: note);

  WeeklyDigest? latestUnseenDigest() => trading.latestUnseenDigest();
  Future<WeeklyDigest?> generateWeeklyDigestIfDue() =>
      trading.generateWeeklyDigestIfDue();
  Future<void> markLatestDigestSeen() => trading.markLatestDigestSeen();

  PropFirmRules get propFirmRules => trading.state.appState.propFirmRules;
  Future<void> setPropFirmRules(PropFirmRules r) => trading.setPropFirmRules(r);

  WeeklyRiskBudget get weeklyRiskBudget =>
      trading.state.appState.weeklyRiskBudget;
  Future<void> setWeeklyRiskBudget(WeeklyRiskBudget b) =>
      trading.setWeeklyRiskBudget(b);

  bool get blockTradesAroundNews =>
      trading.state.appState.blockTradesAroundNews;
  Future<void> setBlockTradesAroundNews(bool v) =>
      trading.setBlockTradesAroundNews(v);

  bool get localOnlyAiMode => trading.state.appState.localOnlyAiMode;
  Future<void> setLocalOnlyAiMode(bool v) => trading.setLocalOnlyAiMode(v);

  int get dailyTradeCap => trading.state.appState.dailyTradeCap;
  Future<void> setDailyTradeCap(int v) => trading.setDailyTradeCap(v);

  // ── Trade-flow wizard ───────────────────────────────────────────────────
  double get riskCapUsd => trading.state.appState.riskCapUsd;
  Future<void> setRiskCapUsd(double v) => trading.setRiskCapUsd(v);

  WizardDraft? get wizardDraft => trading.state.appState.wizardDraft;
  Future<void> updateWizardDraft(WizardDraft draft) =>
      trading.updateWizardDraft(draft);
  Future<void> clearWizardDraft() => trading.clearWizardDraft();

  Future<void> setNotificationPrefs(NotificationPrefs prefs) =>
      trading.setNotificationPrefs(prefs);

  // Sprint 6.5 — Multi-account.
  List<TradingAccount> get accounts => trading.state.appState.accounts;
  String? get activeAccountId => trading.state.appState.activeAccountId;
  TradingAccount? get activeAccount {
    final id = activeAccountId;
    if (id == null) return null;
    final match = accounts.where((a) => a.id == id);
    return match.isEmpty ? null : match.first;
  }

  Future<void> createAccount(String name) => trading.createAccount(name);
  Future<void> switchAccount(String id) => trading.switchAccount(id);
  Future<void> renameAccount(String id, String name) =>
      trading.renameAccount(id, name);
  Future<void> deleteAccount(String id) => trading.deleteAccount(id);

  Future<void> restoreFromBackup(AppState restored) =>
      trading.restoreFromBackup(restored);

  Future<void> deleteTrade(String id) => trading.deleteTrade(id);
  Future<void> updateTrade(Trade updated) => trading.updateTrade(updated);
  Future<void> restoreTrade(Trade trade) => trading.restoreTrade(trade);
  Future<void> toggleCheck(String id) => trading.toggleCheck(id);
  Future<void> setGateProof(String gateId, String proof) =>
      trading.setGateProof(gateId, proof);
  Future<void> resetChecks(List<String> gateIds) =>
      trading.resetChecks(gateIds);
  Future<void> resetToday() => trading.resetToday();
  Future<void> resetAll() => trading.resetAll();

  bool isInResetCooldown() => trading.isInResetCooldown();
  int resetCooldownRemainingMs() => trading.resetCooldownRemainingMs();
  int recentResetCount({Duration window = const Duration(days: 30)}) =>
      trading.recentResetCount(window: window);
  List<IntegrityEvent> get integrityLog => trading.state.appState.integrityLog;

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

  /// Add a batch of trades extracted from an on-device screenshot import.
  Future<int> addTradesBatch(List<Trade> trades) =>
      trading.addTradesBatch(trades);

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
