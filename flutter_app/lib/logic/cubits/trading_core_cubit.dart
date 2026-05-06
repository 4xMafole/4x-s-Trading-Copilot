import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models.dart';
import '../../data/schema_migration.dart';
import '../../data/trading_repository.dart';
import '../../services/device_widget_bridge.dart';
import '../../services/live_activity_bridge.dart';
import '../../services/notification_center.dart';
import '../../services/weekly_digest_service.dart';
import '../drawdown_engine.dart';
import '../intelligence_engine.dart';
import '../risk_budget_engine.dart';
import 'trading_core_state.dart';

class ImportPreview {
  const ImportPreview({
    required this.format,
    required this.merge,
    required this.currentCount,
    required this.incomingCount,
    required this.importedCount,
    required this.skippedCount,
    required this.duplicateCount,
    required this.resultingCount,
    this.fromDate,
    this.toDate,
  });

  final String format;
  final bool merge;
  final int currentCount;
  final int incomingCount;
  final int importedCount;
  final int skippedCount;
  final int duplicateCount;
  final int resultingCount;
  final String? fromDate;
  final String? toDate;
}

class ImportResult {
  const ImportResult({
    required this.ok,
    required this.message,
    this.importedCount = 0,
    this.skippedCount = 0,
    this.preview,
    this.dryRun = false,
  });

  final bool ok;
  final String message;
  final int importedCount;
  final int skippedCount;
  final ImportPreview? preview;
  final bool dryRun;
}

class _DedupTrades {
  const _DedupTrades({required this.trades, required this.skippedCount});
  final List<Trade> trades;
  final int skippedCount;
}

final RegExp _isoDatePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

String eatDateStr(DateTime eat) {
  final y = eat.toUtc().year;
  final m = eat.toUtc().month.toString().padLeft(2, '0');
  final d = eat.toUtc().day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

SessionInfo computeSessionInfo(DateTime eat) {
  final h = eat.toUtc().hour;
  final m = eat.toUtc().minute;
  final t = h * 60 + m;
  final fri = eat.toUtc().weekday == DateTime.friday;

  if (t < 540) {
    return const SessionInfo(
      label: 'Pre-London - no trade',
      type: 'gray',
      ok: false,
      detail:
          'Market not open for your sessions. Study H4/Daily and mark key levels.',
    );
  }
  if (t < 630) {
    return const SessionInfo(
      label: 'Early London - dead zone',
      type: 'red',
      ok: false,
      detail: '09:00-10:30 EAT: hard no-trade. Observe only.',
    );
  }
  if (t < 780) {
    return const SessionInfo(
      label: 'Mid London - valid',
      type: 'green',
      ok: true,
      detail: '10:30-13:00 EAT: valid setups. Keep risk strict.',
    );
  }
  if (t < 900) {
    return const SessionInfo(
      label: 'Late London - prime',
      type: 'green',
      ok: true,
      detail: '13:00-15:00 EAT: prime multi-instrument window.',
    );
  }
  if (t <= 990) {
    return const SessionInfo(
      label: 'BLACKOUT - no execution',
      type: 'red',
      ok: false,
      detail: '15:00-16:30 EAT: no exceptions.',
    );
  }
  if (fri && t >= 1200) {
    return const SessionInfo(
      label: 'Friday kill-switch',
      type: 'red',
      ok: false,
      detail: 'After 20:00 EAT Friday: flat only, no new trades.',
    );
  }
  if (t <= 1110) {
    return const SessionInfo(
      label: 'NY Open - prime',
      type: 'green',
      ok: true,
      detail: '16:30-18:30 EAT: prime NY window.',
    );
  }
  if (t <= 1200) {
    return const SessionInfo(
      label: 'NY Mid - caution',
      type: 'amber',
      ok: true,
      detail: '18:30-20:00 EAT: continuation setups only.',
    );
  }
  return const SessionInfo(
    label: 'NY Late - no trade',
    type: 'gray',
    ok: false,
    detail: 'Session closed. Journal and review compliance.',
  );
}

class TradingCoreCubit extends Cubit<TradingCoreState> {
  TradingCoreCubit(this._repository)
    : super(TradingCoreState(appState: AppState.defaults(), nowEAT: _getEAT()));

  final TradingRepository _repository;
  static int _idSequence = 0;
  Timer? _ticker;

  AppState get appState => state.appState;
  DateTime get nowEAT => state.nowEAT;

  /// Whether persistent storage is encrypted at rest (AES-256 via Hive).
  bool get encryptionEnabled => _repository.encryptionEnabled;

  /// Re-key the encrypted store. Used by the "Reset encryption key" action
  /// in Settings. Existing data is preserved (re-written under the new key).
  Future<void> rotateEncryptionKey() => _repository.rotateEncryptionKey();

  // For API parity with the old controller's `state` getter.
  AppState get tradingState => state.appState;

  Future<void> init() async {
    final loaded = await _repository.getAppState();
    final preloaded = loaded.copyWith(
      preloaded: true,
      schemaVersion: kCurrentSchemaVersion,
    );
    emit(state.copyWith(appState: preloaded, nowEAT: _getEAT()));

    unawaited(DeviceWidgetBridge.refresh());
    unawaited(_syncLiveActivitySnapshot());

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      final previousMinute = state.nowEAT.toUtc().minute;
      final newNow = _getEAT();
      emit(state.copyWith(nowEAT: newNow));
      await checkLock();
      if (newNow.toUtc().minute != previousMinute) {
        unawaited(_syncLiveActivitySnapshot());
      }
    });
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }

  Future<void> _save(AppState newAppState) async {
    await _repository.saveAppState(newAppState);
    emit(state.copyWith(appState: newAppState));
    unawaited(DeviceWidgetBridge.refresh());
    unawaited(_syncLiveActivitySnapshot());
  }

  Future<void> _syncLiveActivitySnapshot() async {
    await LiveActivityBridge.syncSessionSnapshot(
      nowEat: state.nowEAT,
      session: getSessionInfo(),
      tradesRemaining: getTradesRemainingToday(),
    );

    if (Platform.isAndroid) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'widget_state',
        jsonEncode({
          'lock': state.appState.lock,
          'trades': getTodayTrades().length,
          'pnl': getTodayPnl(),
        }),
      );
    }
  }

  // ── Account / state mutators ─────────────────────────────────────────────
  Future<void> updateState({
    double? balance,
    String? startDate,
    double? priorPnl,
  }) async {
    final prev = state.appState;
    final next = prev.copyWith(
      balance: balance ?? prev.balance,
      startDate: startDate ?? prev.startDate,
      priorPnl: priorPnl ?? prev.priorPnl,
    );

    // Audit balance changes — they materially affect risk math.
    final events = <IntegrityEvent>[];
    if (balance != null && balance != prev.balance) {
      events.add(
        _newIntegrityEvent(
          type: 'balance_changed',
          detail:
              'balance: ${prev.balance.toStringAsFixed(2)} → ${balance.toStringAsFixed(2)}',
        ),
      );
    }

    await _save(
      events.isEmpty
          ? next
          : next.copyWith(integrityLog: [...prev.integrityLog, ...events]),
    );
  }

  // ── Read-only computations ───────────────────────────────────────────────
  List<Trade> getTodayTrades() {
    final today = eatDateStr(state.nowEAT);
    return _sortedTradesDesc(
      state.appState.allTrades.where(
        (t) => t.date == today && !t.isHypothetical,
      ),
    );
  }

  int getTradesRemainingToday() {
    if (state.appState.lock) return 0;
    final remaining = state.appState.dailyTradeCap - getTodayTrades().length;
    return remaining < 0 ? 0 : remaining;
  }

  double getTodayPnl() =>
      getTodayTrades().fold<double>(0, (sum, t) => sum + t.pnl);

  double getChallengePnl() => state.appState.priorPnl + getTodayPnl();

  int getDayNumber() {
    final start =
        DateTime.tryParse('${state.appState.startDate}T00:00:00Z') ??
        DateTime.utc(2026, 4, 20);
    final today = DateTime.parse('${eatDateStr(state.nowEAT)}T00:00:00Z');
    final diff = today.difference(start).inDays + 1;
    return diff < 1 ? 1 : diff;
  }

  Map<String, bool> computeAutoGates() {
    final h = state.nowEAT.toUtc().hour;
    final m = state.nowEAT.toUtc().minute;
    final t = h * 60 + m;
    final fri = state.nowEAT.toUtc().weekday == DateTime.friday;
    final tc = getTodayTrades().length;

    return <String, bool>{
      'g2': !(t >= 540 && t < 630),
      'g3': !(t >= 900 && t <= 990),
      'g8': tc < state.appState.dailyTradeCap && !state.appState.lock,
      'g11': !(fri && t >= 1200),
    };
  }

  SessionInfo getSessionInfo() => computeSessionInfo(state.nowEAT);

  List<Trade> getTradesByDate(String date) =>
      _sortedTradesDesc(state.appState.allTrades.where((t) => t.date == date));

  /// Returns ONLY real trades (not hypothetical). Used for Dashboard metrics.
  List<Trade> getRealTradesDesc() => _sortedTradesDesc(
    state.appState.allTrades.where((t) => !t.isHypothetical),
  );

  /// Returns ALL trades, including hypothetical. Used for Journal.
  List<Trade> getAllTradesDesc() => _sortedTradesDesc(state.appState.allTrades);

  List<String> getAllTradeDates() {
    final dates = <String>{};
    for (final t in state.appState.allTrades) {
      dates.add(t.date);
    }
    return dates.toList()..sort((a, b) => b.compareTo(a));
  }

  // ── Locking ──────────────────────────────────────────────────────────────
  Future<void> checkLock() async {
    bool lock = state.appState.lock;
    int? lockUntil = state.appState.lockUntil;

    if (lock &&
        lockUntil != null &&
        DateTime.now().millisecondsSinceEpoch > lockUntil) {
      lock = false;
      lockUntil = null;
    }

    final todayTrades = getTodayTrades();
    if (todayTrades.length >= state.appState.dailyTradeCap &&
        todayTrades.every((t) => t.pnl < 0) &&
        !lock) {
      lock = true;
      lockUntil = DateTime.now().millisecondsSinceEpoch + (24 * 3600 * 1000);
    }

    if (lock != state.appState.lock || lockUntil != state.appState.lockUntil) {
      final wasLocked = state.appState.lock;
      await _save(state.appState.copyWith(lock: lock, lockUntil: lockUntil));
      // Reactive notification: lock just engaged.
      if (lock && !wasLocked) {
        final prefs = state.appState.notificationPrefs;
        if (prefs.master && prefs.lock) {
          final until = lockUntil != null
              ? DateTime.fromMillisecondsSinceEpoch(lockUntil)
              : null;
          final body = until != null
              ? 'Cooldown until ${until.toLocal().hour.toString().padLeft(2, '0')}:'
                    '${until.toLocal().minute.toString().padLeft(2, '0')}.'
              : 'Cooldown active. Step away from the screen.';
          unawaited(
            NotificationCenter.instance.showLockAlert('Account locked', body),
          );
        }
      }
    }
  }

  // ── Trade mutations ──────────────────────────────────────────────────────
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
  }) async {
    final eat = _getEAT();
    final fallbackDate = eatDateStr(eat);
    final fallbackTime =
        '${eat.toUtc().hour.toString().padLeft(2, '0')}:${eat.toUtc().minute.toString().padLeft(2, '0')} EAT';
    final tradeDate =
        _normalizeDateValue(date ?? '', fallbackDate: fallbackDate) ??
        fallbackDate;
    final tradeTime = _normalizeTimeValue(time ?? '', fallback: fallbackTime);

    final trade = Trade(
      id: _nextTradeId(prefix: 't'),
      date: tradeDate,
      time: tradeTime,
      sym: sym,
      dir: dir,
      lots: lots,
      pnl: pnl,
      note: note,
      violations: violations,
      tags: tags,
      htfImage: htfImage,
      ltfImage: ltfImage,
      isHypothetical: isHypothetical,
      setupQuality: setupQuality,
      trigger: trigger,
      plannedRisk: plannedRisk,
    );

    final auditDetail =
        '#${trade.id} ${trade.sym} ${trade.dir} '
        '${trade.lots.toStringAsFixed(2)} lots, P/L \$${trade.pnl.toStringAsFixed(2)}'
        '${trade.isHypothetical ? " (paper)" : ""}';
    await _save(
      state.appState.copyWith(
        allTrades: <Trade>[...state.appState.allTrades, trade],
        integrityLog: [
          ...state.appState.integrityLog,
          _newIntegrityEvent(type: 'trade_added', detail: auditDetail),
        ],
      ),
    );
    await checkLock();
    unawaited(_fireReactiveNotifications());
    return trade;
  }

  /// Attach a post-trade reflection to an existing trade.
  Future<void> setReflection(String tradeId, TradeReflection reflection) async {
    final next = state.appState.allTrades
        .map((t) => t.id == tradeId ? t.copyWith(reflection: reflection) : t)
        .toList();
    await _save(state.appState.copyWith(allTrades: next));
  }

  // ── Daily mood (Sprint 2.3) ──────────────────────────────────────────────
  /// Returns today's mood (EAT) or null if not checked in yet.
  DailyMood? getTodayMood() {
    final key = eatDateStr(state.nowEAT);
    return state.appState.dailyMoods[key];
  }

  /// Records the trader's mood for today (EAT). Replaces any prior entry.
  Future<void> setTodayMood(String mood, {String note = ''}) async {
    final key = eatDateStr(state.nowEAT);
    final next = <String, DailyMood>{...state.appState.dailyMoods};
    next[key] = DailyMood(
      mood: mood,
      note: note.trim(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await _save(state.appState.copyWith(dailyMoods: next));
  }

  // ── Weekly digest (Sprint 3.2) ───────────────────────────────────────────
  /// Latest unseen digest, if any. UI uses this to render a banner.
  WeeklyDigest? latestUnseenDigest() {
    final list = state.appState.weeklyDigests;
    if (list.isEmpty) return null;
    final candidate = list.first;
    return candidate.seen ? null : candidate;
  }

  /// Builds the digest for last week if (a) it's Sun/Mon and (b) we don't
  /// already have one for that weekId. Safe to call on every app open.
  Future<WeeklyDigest?> generateWeeklyDigestIfDue({
    WeeklyDigestService? service,
  }) async {
    final svc = service ?? WeeklyDigestService();
    final now = state.nowEAT;
    // Generate Sunday or Monday only, to avoid mid-week churn.
    if (now.weekday != DateTime.sunday && now.weekday != DateTime.monday) {
      return null;
    }

    final fresh = await svc.buildDigestForLastWeek(
      state.appState.allTrades,
      localOnly: state.appState.localOnlyAiMode,
    );
    final existing = state.appState.weeklyDigests;
    if (existing.isNotEmpty && existing.first.weekId == fresh.weekId) {
      return null;
    }

    final next = <WeeklyDigest>[fresh, ...existing];
    // Cap at 12 to prevent unbounded growth.
    final capped = next.length > 12 ? next.sublist(0, 12) : next;
    await _save(state.appState.copyWith(weeklyDigests: capped));
    return fresh;
  }

  /// Marks the most recent digest as seen so the banner stops showing.
  Future<void> markLatestDigestSeen() async {
    final list = state.appState.weeklyDigests;
    if (list.isEmpty) return;
    final updated = <WeeklyDigest>[
      list.first.copyWith(seen: true),
      ...list.skip(1),
    ];
    await _save(state.appState.copyWith(weeklyDigests: updated));
  }

  /// Sprint 4.1 — Updates the user's prop-firm drawdown rules.
  Future<void> setPropFirmRules(PropFirmRules rules) async {
    await _save(state.appState.copyWith(propFirmRules: rules));
  }

  /// Sprint 4.2 — Updates the weekly risk budget.
  Future<void> setWeeklyRiskBudget(WeeklyRiskBudget b) async {
    await _save(state.appState.copyWith(weeklyRiskBudget: b));
  }

  /// Sprint 4.4 — Toggles the "block trades around news" guard.
  Future<void> setBlockTradesAroundNews(bool v) async {
    await _save(state.appState.copyWith(blockTradesAroundNews: v));
  }

  /// Sprint 5.3 — Toggles local-only AI mode (no Gemini calls).
  Future<void> setLocalOnlyAiMode(bool v) async {
    await _save(state.appState.copyWith(localOnlyAiMode: v));
  }

  /// Sprint 6.3 — Sets the user's daily trade cap (1, 2, 3, or 5).
  Future<void> setDailyTradeCap(int v) async {
    if (v < 1 || v > 10) return;
    await _save(state.appState.copyWith(dailyTradeCap: v));
  }

  /// Updates the per-category notification preferences. Caller is
  /// responsible for re-running any recurring schedulers afterwards.
  Future<void> setNotificationPrefs(NotificationPrefs prefs) async {
    await _save(state.appState.copyWith(notificationPrefs: prefs));
  }

  // ── Sprint 6.5 — Multi-account management ───────────────────────────────

  /// Snapshots the current top-level account fields into a [TradingAccount].
  TradingAccount _snapshotCurrent({required String id, required String name}) {
    final s = state.appState;
    return TradingAccount(
      id: id,
      name: name,
      balance: s.balance,
      startDate: s.startDate,
      priorPnl: s.priorPnl,
      allTrades: s.allTrades,
      lock: s.lock,
      lockUntil: s.lockUntil,
      propFirmRules: s.propFirmRules,
      weeklyRiskBudget: s.weeklyRiskBudget,
      dailyTradeCap: s.dailyTradeCap,
    );
  }

  /// Replaces the top-level account fields with [a]'s snapshot.
  AppState _unpack(AppState base, TradingAccount a) {
    return base.copyWith(
      balance: a.balance,
      startDate: a.startDate,
      priorPnl: a.priorPnl,
      allTrades: a.allTrades,
      lock: a.lock,
      lockUntil: a.lockUntil,
      propFirmRules: a.propFirmRules,
      weeklyRiskBudget: a.weeklyRiskBudget,
      dailyTradeCap: a.dailyTradeCap,
    );
  }

  String _newAccountId() =>
      'acc_${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';

  /// Creates a new account. If this is the first account ever, the current
  /// state is preserved as a "Personal" account first, then the new account
  /// starts fresh (cloning balance/startDate but with empty trades).
  Future<void> createAccount(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final s = state.appState;
    final newId = _newAccountId();

    // First account ever: snapshot current state as "Personal".
    var accounts = s.accounts;
    var activeId = s.activeAccountId;
    if (activeId == null || accounts.isEmpty) {
      const personalName = 'Personal';
      final personalId = _newAccountId();
      accounts = [..._packCurrent(s, personalId, personalName, accounts)];
      activeId = personalId;
    } else {
      // Pack current live state into the active account before switching.
      accounts = _packCurrent(
        s,
        activeId,
        _activeName(s) ?? 'Personal',
        accounts,
      );
    }

    // The new account starts fresh: clean trades, no lock, default rules.
    final fresh = TradingAccount(
      id: newId,
      name: trimmed,
      balance: s.balance,
      startDate: s.startDate,
      dailyTradeCap: s.dailyTradeCap,
    );
    final nextAccounts = [...accounts, fresh];

    final unpacked = _unpack(s, fresh).copyWith(
      accounts: nextAccounts,
      activeAccountId: newId,
      // Reset session-only check state when switching to a fresh account.
      checks: const {},
      gateProofs: const {},
      integrityLog: [
        ...s.integrityLog,
        _newIntegrityEvent(
          type: 'account_created',
          detail: 'Created account "$trimmed" and switched in.',
        ),
      ],
    );
    await _save(unpacked);
    await checkLock();
  }

  /// Switches the active account to [id]. The current top-level fields are
  /// packed into the previous account; [id]'s snapshot is unpacked in place.
  Future<void> switchAccount(String id) async {
    final s = state.appState;
    if (s.activeAccountId == id) return;
    final target = s.accounts.where((a) => a.id == id).toList();
    if (target.isEmpty) return;

    var accounts = s.accounts;
    if (s.activeAccountId != null) {
      accounts = _packCurrent(
        s,
        s.activeAccountId!,
        _activeName(s) ?? 'Personal',
        accounts,
      );
    }

    final t = target.first;
    final unpacked = _unpack(s, t).copyWith(
      accounts: accounts,
      activeAccountId: id,
      checks: const {},
      gateProofs: const {},
      integrityLog: [
        ...s.integrityLog,
        _newIntegrityEvent(
          type: 'account_switched',
          detail: 'Switched to "${t.name}".',
        ),
      ],
    );
    await _save(unpacked);
    await checkLock();
  }

  /// Renames an existing account.
  Future<void> renameAccount(String id, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    final s = state.appState;
    final accounts = s.accounts
        .map((a) => a.id == id ? a.copyWith(name: trimmed) : a)
        .toList();
    await _save(s.copyWith(accounts: accounts));
  }

  /// Deletes a non-active account. The active account cannot be deleted.
  Future<void> deleteAccount(String id) async {
    final s = state.appState;
    if (s.activeAccountId == id) return;
    final removed = s.accounts.firstWhere(
      (a) => a.id == id,
      orElse: () => const TradingAccount(id: '', name: ''),
    );
    if (removed.id.isEmpty) return;
    final accounts = s.accounts.where((a) => a.id != id).toList();
    await _save(
      s.copyWith(
        accounts: accounts,
        integrityLog: [
          ...s.integrityLog,
          _newIntegrityEvent(
            type: 'account_deleted',
            detail: 'Deleted "${removed.name}".',
          ),
        ],
      ),
    );
  }

  String? _activeName(AppState s) {
    if (s.activeAccountId == null) return null;
    final match = s.accounts.where((a) => a.id == s.activeAccountId);
    return match.isEmpty ? null : match.first.name;
  }

  /// Replaces (or appends) the snapshot for [id] in [accounts] with
  /// the current top-level state in [s].
  List<TradingAccount> _packCurrent(
    AppState s,
    String id,
    String name,
    List<TradingAccount> accounts,
  ) {
    final snapshot = _snapshotCurrent(id: id, name: name);
    final exists = accounts.any((a) => a.id == id);
    if (exists) {
      return accounts.map((a) => a.id == id ? snapshot : a).toList();
    }
    return [...accounts, snapshot];
  }

  /// Sprint 5.2 — Replaces local state with a restored backup. Preserves
  /// the existing integrity log and appends a `restored_backup` event.
  Future<void> restoreFromBackup(AppState restored) async {
    final preservedLog = [
      ...state.appState.integrityLog,
      _newIntegrityEvent(
        type: 'restored_backup',
        detail:
            '${restored.allTrades.length} trades, balance \$${restored.balance.toStringAsFixed(2)}',
      ),
    ];
    await _save(restored.copyWith(integrityLog: preservedLog));
    await checkLock();
  }

  Future<void> deleteTrade(String id) async {
    final removed = state.appState.allTrades.firstWhere(
      (t) => t.id == id,
      orElse: () => Trade(id: id, date: '', time: ''),
    );
    final detail = removed.date.isEmpty
        ? '#$id'
        : '#$id ${removed.sym} ${removed.dir} '
              '${removed.lots.toStringAsFixed(2)} lots, P/L \$${removed.pnl.toStringAsFixed(2)}';
    await _save(
      state.appState.copyWith(
        allTrades: state.appState.allTrades.where((t) => t.id != id).toList(),
        integrityLog: [
          ...state.appState.integrityLog,
          _newIntegrityEvent(type: 'trade_deleted', detail: detail),
        ],
      ),
    );
    await checkLock();
  }

  Future<void> updateTrade(Trade updated) async {
    Trade? before;
    var found = false;
    final next = state.appState.allTrades.map((t) {
      if (t.id != updated.id) return t;
      before = t;
      found = true;
      return updated;
    }).toList();
    if (!found) next.add(updated);

    final auditEvents = <IntegrityEvent>[];
    if (before != null) {
      final diffs = <String>[];
      if (before!.pnl != updated.pnl) {
        diffs.add(
          'P/L \$${before!.pnl.toStringAsFixed(2)} \u2192 \$${updated.pnl.toStringAsFixed(2)}',
        );
      }
      if (before!.lots != updated.lots) {
        diffs.add(
          'lots ${before!.lots.toStringAsFixed(2)} \u2192 ${updated.lots.toStringAsFixed(2)}',
        );
      }
      if (before!.dir != updated.dir) {
        diffs.add('dir ${before!.dir} \u2192 ${updated.dir}');
      }
      if (before!.sym != updated.sym) {
        diffs.add('sym ${before!.sym} \u2192 ${updated.sym}');
      }
      if (before!.isHypothetical != updated.isHypothetical) {
        diffs.add(
          updated.isHypothetical ? 'real \u2192 paper' : 'paper \u2192 real',
        );
      }
      if (diffs.isNotEmpty) {
        auditEvents.add(
          _newIntegrityEvent(
            type: 'trade_edited',
            detail: '#${updated.id} ${diffs.join(", ")}',
          ),
        );
      }
    }

    await _save(
      state.appState.copyWith(
        allTrades: next,
        integrityLog: auditEvents.isEmpty
            ? state.appState.integrityLog
            : [...state.appState.integrityLog, ...auditEvents],
      ),
    );
    await checkLock();
  }

  Future<void> restoreTrade(Trade trade) async {
    final withoutDuplicate = state.appState.allTrades.where(
      (t) => t.id != trade.id,
    );
    await _save(
      state.appState.copyWith(allTrades: <Trade>[...withoutDuplicate, trade]),
    );
    await checkLock();
  }

  /// Bulk-append trades from a screenshot/file import. Skips duplicates by id.
  /// Returns the number of trades actually added.
  Future<int> addTradesBatch(List<Trade> incoming) async {
    if (incoming.isEmpty) return 0;
    final existingIds = state.appState.allTrades.map((t) => t.id).toSet();
    final fresh = incoming.where((t) => !existingIds.contains(t.id)).toList();
    if (fresh.isEmpty) return 0;
    await _save(
      state.appState.copyWith(
        allTrades: <Trade>[...state.appState.allTrades, ...fresh],
      ),
    );
    await checkLock();
    return fresh.length;
  }

  Future<void> toggleCheck(String id) async {
    final checks = <String, bool>{...state.appState.checks};
    checks[id] = !(checks[id] ?? false);
    await _save(state.appState.copyWith(checks: checks));
  }

  /// Pass a manual gate by recording the user's proof / justification.
  /// Empty proof clears the gate (un-passes it).
  Future<void> setGateProof(String gateId, String proof) async {
    final checks = <String, bool>{...state.appState.checks};
    final proofs = <String, String>{...state.appState.gateProofs};
    final trimmed = proof.trim();
    if (trimmed.isEmpty) {
      checks[gateId] = false;
      proofs.remove(gateId);
    } else {
      checks[gateId] = true;
      proofs[gateId] = trimmed;
    }
    await _save(state.appState.copyWith(checks: checks, gateProofs: proofs));
  }

  Future<void> resetChecks(List<String> gateIds) async {
    final checks = <String, bool>{...state.appState.checks};
    final proofs = <String, String>{...state.appState.gateProofs};
    for (final id in gateIds) {
      checks[id] = false;
      proofs.remove(id);
    }
    await _save(state.appState.copyWith(checks: checks, gateProofs: proofs));
  }

  Future<void> resetToday() async {
    final today = eatDateStr(state.nowEAT);
    final prev = state.appState;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final removed = prev.allTrades.where((t) => t.date == today).length;
    await _save(
      prev.copyWith(
        allTrades: prev.allTrades.where((t) => t.date != today).toList(),
        checks: <String, bool>{},
        gateProofs: <String, String>{},
        lock: false,
        lockUntil: null,
        lastResetAt: nowMs,
        integrityLog: [
          ...prev.integrityLog,
          _newIntegrityEvent(
            type: 'reset_today',
            detail: 'cleared $removed trade(s) for $today; lock dismissed',
            timestamp: nowMs,
          ),
        ],
      ),
    );
  }

  Future<void> resetAll() async {
    final prev = state.appState;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    // Preserve audit history across a full reset — it's an audit trail, not state.
    final preservedLog = [
      ...prev.integrityLog,
      _newIntegrityEvent(
        type: 'reset_all',
        detail: 'full data reset (${prev.allTrades.length} trades cleared)',
        timestamp: nowMs,
      ),
    ];
    await _save(
      AppState.defaults().copyWith(
        preloaded: true,
        integrityLog: preservedLog,
        lastResetAt: nowMs,
      ),
    );
  }

  /// Returns true if the trader is currently inside the 24-hour reset
  /// cooldown window. UI must block reset attempts while this is true.
  bool isInResetCooldown() {
    final last = state.appState.lastResetAt;
    if (last == null) return false;
    final elapsed = DateTime.now().millisecondsSinceEpoch - last;
    return elapsed < const Duration(hours: 24).inMilliseconds;
  }

  /// Milliseconds remaining until a new reset is allowed (0 if none).
  int resetCooldownRemainingMs() {
    final last = state.appState.lastResetAt;
    if (last == null) return 0;
    final elapsed = DateTime.now().millisecondsSinceEpoch - last;
    final remaining = const Duration(hours: 24).inMilliseconds - elapsed;
    return remaining < 0 ? 0 : remaining;
  }

  /// Counts reset events (today + all) inside the trailing window.
  /// 3+ resets / 30 days flags the trader as tilt-prone in the UI.
  int recentResetCount({Duration window = const Duration(days: 30)}) {
    final cutoff =
        DateTime.now().millisecondsSinceEpoch - window.inMilliseconds;
    return state.appState.integrityLog
        .where(
          (e) =>
              e.timestamp >= cutoff &&
              (e.type == 'reset_today' || e.type == 'reset_all'),
        )
        .length;
  }

  IntegrityEvent _newIntegrityEvent({
    required String type,
    String detail = '',
    int? timestamp,
  }) {
    final ts = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    return IntegrityEvent(
      id: 'int_${ts}_${type}_${state.appState.integrityLog.length}',
      timestamp: ts,
      type: type,
      detail: detail,
    );
  }

  // ── Export ───────────────────────────────────────────────────────────────
  String exportData() => state.appState.toPrettyJson();

  String exportAsJson() {
    final data = Map<String, dynamic>.from(state.appState.toJson())
      ..['exportedAt'] = DateTime.now().toIso8601String();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  String exportAsCsv() {
    final buffer = StringBuffer();
    buffer.writeln(
      'Date,Time,Instrument,Direction,Lots,P&L,Notes,Violations,HTF Image,LTF Image',
    );
    for (final t in getAllTradesDesc()) {
      final violations = t.violations.join('|');
      final htf = t.htfImage ?? '';
      final ltf = t.ltfImage ?? '';
      buffer.writeln(
        '"${_csvEscape(t.date)}","${_csvEscape(t.time)}","${_csvEscape(t.sym)}","${_csvEscape(t.dir)}",${t.lots},${t.pnl},"${_csvEscape(t.note)}","${_csvEscape(violations)}","${_csvEscape(htf)}","${_csvEscape(ltf)}"',
      );
    }
    return buffer.toString();
  }

  // ── Import ───────────────────────────────────────────────────────────────
  Future<bool> importData(String data) async {
    final result = await importJsonData(data, merge: false);
    return result.ok;
  }

  Future<ImportResult> importJsonData(
    String data, {
    bool merge = false,
    bool dryRun = false,
  }) async {
    try {
      final decoded = jsonDecode(data);
      if (decoded is! Map<String, dynamic>) {
        return const ImportResult(ok: false, message: 'Invalid JSON payload.');
      }
      final migrated = migrateAppStatePayload(
        Map<String, dynamic>.from(decoded),
      );
      final importedState = AppState.fromJson(
        migrated,
      ).copyWith(preloaded: true, schemaVersion: kCurrentSchemaVersion);
      final dedup = _dedupeTradesById(importedState.allTrades);
      final incoming = _sortedTradesDesc(dedup.trades);
      final preview = _buildImportPreview(
        format: 'json',
        merge: merge,
        current: state.appState.allTrades,
        incoming: incoming,
        skippedCount: dedup.skippedCount,
      );

      if (dryRun) {
        return ImportResult(
          ok: true,
          message: _buildPreviewMessage('JSON', preview),
          importedCount: preview.importedCount,
          skippedCount: preview.skippedCount,
          preview: preview,
          dryRun: true,
        );
      }

      AppState newAppState;
      if (merge) {
        final merged = _mergeTrades(state.appState.allTrades, incoming);
        newAppState = state.appState.copyWith(
          allTrades: _sortedTradesDesc(merged),
          preloaded: true,
          schemaVersion: kCurrentSchemaVersion,
        );
      } else {
        newAppState = importedState.copyWith(
          allTrades: incoming,
          preloaded: true,
          schemaVersion: kCurrentSchemaVersion,
        );
      }

      await _save(newAppState);
      await checkLock();

      var msg = 'JSON import successful (${preview.importedCount} trades)';
      if (preview.duplicateCount > 0) {
        msg += ', ${preview.duplicateCount} existing id(s) updated';
      }
      if (preview.skippedCount > 0) {
        msg += ', ${preview.skippedCount} skipped';
      }
      return ImportResult(
        ok: true,
        message: '$msg.',
        importedCount: preview.importedCount,
        skippedCount: preview.skippedCount,
        preview: preview,
      );
    } catch (e) {
      return ImportResult(ok: false, message: 'JSON import failed: $e');
    }
  }

  Future<ImportResult> importCsvData(
    String data, {
    bool merge = false,
    bool dryRun = false,
  }) async {
    try {
      final lines = const LineSplitter()
          .convert(data)
          .where((l) => l.trim().isNotEmpty)
          .toList();
      if (lines.length < 2) {
        return const ImportResult(
          ok: false,
          message: 'CSV must include a header and at least one row.',
        );
      }

      final header = _parseCsvLine(
        lines.first,
      ).map((h) => h.trim().toLowerCase()).toList();
      final idx = <String, int>{};
      for (var i = 0; i < header.length; i++) {
        final key = header[i];
        idx[key] = i;
        if (key == 'pnl') idx['p&l'] = i;
        if (key == 'symbol') idx['instrument'] = i;
        if (key == 'side') idx['direction'] = i;
      }

      const required = [
        'date',
        'time',
        'instrument',
        'direction',
        'lots',
        'p&l',
      ];
      for (final col in required) {
        if (!idx.containsKey(col)) {
          return ImportResult(
            ok: false,
            message: 'CSV missing required column: $col',
          );
        }
      }

      final imported = <Trade>[];
      var skipped = 0;
      final seenIncomingIds = <String>{};
      for (var row = 1; row < lines.length; row++) {
        final fields = _parseCsvLine(lines[row]);

        String read(String key) {
          final i = idx[key];
          if (i == null || i >= fields.length) return '';
          return fields[i].trim();
        }

        final lots = double.tryParse(read('lots'));
        final pnl = double.tryParse(read('p&l'));
        if (lots == null || pnl == null) {
          skipped++;
          continue;
        }

        final date = _normalizeDateValue(
          read('date'),
          fallbackDate: eatDateStr(state.nowEAT),
        );
        if (date == null) {
          skipped++;
          continue;
        }

        final sym = read('instrument').isEmpty
            ? 'XAUUSD'
            : read('instrument').toUpperCase();
        final dir = _normalizeDirection(read('direction'));
        final rawId = idx.containsKey('id') ? read('id') : '';
        final id = rawId.isEmpty ? _nextTradeId(prefix: 'csv') : rawId;
        if (!seenIncomingIds.add(id)) {
          skipped++;
          continue;
        }

        final vRaw = idx.containsKey('violations') ? read('violations') : '';
        final violations = _parseViolations(vRaw);

        imported.add(
          Trade(
            id: id,
            date: date,
            time: _normalizeTimeValue(read('time')),
            sym: sym,
            dir: dir,
            lots: lots,
            pnl: pnl,
            note: idx.containsKey('notes') ? read('notes') : '',
            violations: violations,
            htfImage: idx.containsKey('htf image')
                ? _emptyToNull(read('htf image'))
                : null,
            ltfImage: idx.containsKey('ltf image')
                ? _emptyToNull(read('ltf image'))
                : null,
          ),
        );
      }

      final preview = _buildImportPreview(
        format: 'csv',
        merge: merge,
        current: state.appState.allTrades,
        incoming: imported,
        skippedCount: skipped,
      );

      if (dryRun) {
        return ImportResult(
          ok: true,
          message: _buildPreviewMessage('CSV', preview),
          importedCount: preview.importedCount,
          skippedCount: preview.skippedCount,
          preview: preview,
          dryRun: true,
        );
      }

      if (imported.isEmpty) {
        return ImportResult(
          ok: false,
          message: skipped > 0
              ? 'No valid CSV rows imported. $skipped row(s) were invalid.'
              : 'No valid CSV rows imported.',
          skippedCount: skipped,
        );
      }

      final finalTrades = merge
          ? _mergeTrades(state.appState.allTrades, imported)
          : imported;

      await _save(
        state.appState.copyWith(
          allTrades: _sortedTradesDesc(finalTrades),
          preloaded: true,
          schemaVersion: kCurrentSchemaVersion,
        ),
      );
      await checkLock();

      var msg = 'CSV import successful (${preview.importedCount} rows)';
      if (preview.skippedCount > 0) {
        msg += ', ${preview.skippedCount} skipped';
      }
      if (preview.duplicateCount > 0) {
        msg += ', ${preview.duplicateCount} existing id(s) updated';
      }
      return ImportResult(
        ok: true,
        message: '$msg.',
        importedCount: preview.importedCount,
        skippedCount: preview.skippedCount,
        preview: preview,
      );
    } catch (e) {
      return ImportResult(ok: false, message: 'CSV import failed: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  String _buildPreviewMessage(String label, ImportPreview preview) {
    var msg = '$label preview ready (${preview.importedCount} rows)';
    if (preview.skippedCount > 0) {
      msg += ', ${preview.skippedCount} skipped';
    }
    if (preview.duplicateCount > 0) {
      msg += ', ${preview.duplicateCount} will update existing ids';
    }
    if (preview.fromDate != null && preview.toDate != null) {
      msg += ', ${preview.fromDate} to ${preview.toDate}';
    }
    return '$msg.';
  }

  ImportPreview _buildImportPreview({
    required String format,
    required bool merge,
    required List<Trade> current,
    required List<Trade> incoming,
    required int skippedCount,
  }) {
    final currentIds = current.map((t) => t.id).toSet();
    var duplicateCount = 0;
    for (final t in incoming) {
      if (currentIds.contains(t.id)) duplicateCount++;
    }
    final dates = incoming.map((t) => t.date).where(_isIsoDate).toList()
      ..sort();

    return ImportPreview(
      format: format,
      merge: merge,
      currentCount: current.length,
      incomingCount: incoming.length + skippedCount,
      importedCount: incoming.length,
      skippedCount: skippedCount,
      duplicateCount: duplicateCount,
      resultingCount: merge
          ? current.length + incoming.length - duplicateCount
          : incoming.length,
      fromDate: dates.isEmpty ? null : dates.first,
      toDate: dates.isEmpty ? null : dates.last,
    );
  }

  _DedupTrades _dedupeTradesById(List<Trade> trades) {
    final map = <String, Trade>{};
    var skipped = 0;
    for (final trade in trades) {
      final id = trade.id.trim();
      if (id.isEmpty) {
        skipped++;
        continue;
      }
      if (map.containsKey(id)) skipped++;
      map[id] = trade;
    }
    return _DedupTrades(trades: map.values.toList(), skippedCount: skipped);
  }

  List<String> _parseViolations(String raw) {
    if (raw.trim().isEmpty) return <String>[];
    return raw
        .split('|')
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .toList();
  }

  String? _normalizeDateValue(String raw, {String? fallbackDate}) {
    final value = raw.trim();
    if (value.isEmpty) return fallbackDate;
    if (_isIsoDate(value)) return value;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return null;
    return _formatUtcDate(parsed.toUtc());
  }

  String _normalizeTimeValue(String raw, {String fallback = '00:00 EAT'}) {
    final value = raw.trim();
    if (value.isEmpty) return fallback;
    final first = value.split(' ').first;
    final parts = first.split(':');
    if (parts.length < 2) return fallback;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      return fallback;
    }
    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    return '$hh:$mm EAT';
  }

  String _normalizeDirection(String raw) {
    final value = raw.trim().toLowerCase();
    if (value == 'sell' || value == 'short') return 'sell';
    return 'buy';
  }

  String _nextTradeId({required String prefix}) {
    _idSequence = (_idSequence + 1) % 1000000;
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_$_idSequence';
  }

  bool _isIsoDate(String value) {
    if (!_isoDatePattern.hasMatch(value)) return false;
    final parsed = DateTime.tryParse('${value}T00:00:00Z');
    return parsed != null && _formatUtcDate(parsed.toUtc()) == value;
  }

  String _formatUtcDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  List<Trade> _mergeTrades(List<Trade> current, List<Trade> incoming) {
    final map = <String, Trade>{};
    for (final t in current) {
      map[t.id] = t;
    }
    for (final t in incoming) {
      map[t.id] = t;
    }
    return map.values.toList();
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (c == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(c);
      }
    }
    result.add(buffer.toString());
    return result;
  }

  String _csvEscape(String value) => value.replaceAll('"', '""');

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  List<Trade> _sortedTradesDesc(Iterable<Trade> trades) {
    final list = trades.toList();
    list.sort(_compareTradesDesc);
    return list;
  }

  int _compareTradesDesc(Trade a, Trade b) {
    final byDate = b.date.compareTo(a.date);
    if (byDate != 0) return byDate;
    final byTime = _timeForSort(b.time).compareTo(_timeForSort(a.time));
    if (byTime != 0) return byTime;
    return b.id.compareTo(a.id);
  }

  String _timeForSort(String value) =>
      _normalizeTimeValue(value, fallback: '00:00 EAT').split(' ').first;

  static DateTime _getEAT() =>
      DateTime.now().toUtc().add(const Duration(hours: 3));

  // ── Reactive local-notification triggers ───────────────────────────────
  // Memory-only flags so we only fire on threshold crossings, not on every
  // single trade. Reset when the EAT day rolls over.
  bool _ntfDrawdownDanger = false;
  bool _ntfRiskBudgetWarn = false;
  bool _ntfRiskBudgetExhaust = false;
  bool _ntfStreakWarn = false;
  bool _ntfDailyCap = false;
  String? _ntfDayKey;

  /// Inspect post-trade state and emit any local notifications whose
  /// thresholds have just been crossed. Gated by [AppState.notificationPrefs].
  Future<void> _fireReactiveNotifications() async {
    final s = state.appState;
    final prefs = s.notificationPrefs;
    if (!prefs.master) return;

    final nowEat = _getEAT();
    final todayKey =
        '${nowEat.year}-${nowEat.month.toString().padLeft(2, '0')}-${nowEat.day.toString().padLeft(2, '0')}';
    if (_ntfDayKey != todayKey) {
      _ntfDayKey = todayKey;
      _ntfDailyCap = false;
      _ntfDrawdownDanger = false;
      _ntfStreakWarn = false;
    }

    // 1) Drawdown danger (≥70% of daily OR trailing limit).
    if (prefs.drawdown && s.propFirmRules.enabled) {
      final r = s.propFirmRules;
      double consumed = 0;
      String which = '';
      if (r.maxDailyDrawdown > 0) {
        final dd = DrawdownEngine.dailyDrawdown(s.allTrades, nowEat);
        final c = DrawdownEngine.dailyConsumed(dd, r.maxDailyDrawdown);
        if (c > consumed) {
          consumed = c;
          which = 'daily';
        }
      }
      if (r.maxTotalDrawdown > 0) {
        final dd = DrawdownEngine.currentTrailingDrawdown(
          startBalance: s.balance,
          priorPnl: s.priorPnl,
          allTrades: s.allTrades,
        );
        final c = DrawdownEngine.totalConsumed(dd, r.maxTotalDrawdown);
        if (c > consumed) {
          consumed = c;
          which = 'trailing';
        }
      }
      final tone = toneFor(consumed);
      if (tone == DrawdownTone.danger && !_ntfDrawdownDanger) {
        _ntfDrawdownDanger = true;
        final pct = (consumed * 100).round();
        unawaited(
          NotificationCenter.instance.showDrawdownAlert(
            'Drawdown danger — $pct% used',
            'Your $which drawdown is in the red zone. Consider stopping for today.',
          ),
        );
      } else if (tone != DrawdownTone.danger) {
        _ntfDrawdownDanger = false;
      }
    }

    // 2) Weekly risk budget (≥80% warn, ≥100% exhausted).
    if (prefs.riskBudget && s.weeklyRiskBudget.enabled) {
      final loss = RiskBudgetEngine.weeklyLossUsd(s.allTrades, nowEat);
      final exhausted = RiskBudgetEngine.isExhausted(loss, s.weeklyRiskBudget);
      final warn = RiskBudgetEngine.isWarning(loss, s.weeklyRiskBudget);
      if (exhausted && !_ntfRiskBudgetExhaust) {
        _ntfRiskBudgetExhaust = true;
        unawaited(
          NotificationCenter.instance.showRiskBudgetAlert(
            'Weekly risk budget exhausted',
            'You have used 100% of this week\'s R-budget. Stop trading until Monday.',
          ),
        );
      } else if (warn && !_ntfRiskBudgetWarn && !exhausted) {
        _ntfRiskBudgetWarn = true;
        final pct =
            (RiskBudgetEngine.consumedFraction(loss, s.weeklyRiskBudget) * 100)
                .round();
        unawaited(
          NotificationCenter.instance.showRiskBudgetAlert(
            'Risk budget at $pct%',
            'Only ${100 - pct}% of this week\'s R-budget remains.',
          ),
        );
      }
      if (!warn) _ntfRiskBudgetWarn = false;
      if (!exhausted) _ntfRiskBudgetExhaust = false;
    }

    // 3) Loss streak (3+ recent losers).
    if (prefs.streak) {
      final streak = IntelligenceEngine.currentStreak(s.allTrades);
      final losing = streak.kind == false;
      if (streak.shouldWarn && losing && !_ntfStreakWarn) {
        _ntfStreakWarn = true;
        unawaited(
          NotificationCenter.instance.showStreakAlert(
            '${streak.length} losses in a row',
            'Pause. Step away. Don\'t revenge-trade.',
          ),
        );
      } else if (!(streak.shouldWarn && losing)) {
        _ntfStreakWarn = false;
      }
    }

    // 4) Daily trade cap reached.
    if (prefs.dailyCap) {
      final taken = s.allTrades
          .where((t) => !t.isHypothetical && t.date == todayKey)
          .length;
      if (taken >= s.dailyTradeCap && !_ntfDailyCap) {
        _ntfDailyCap = true;
        unawaited(
          NotificationCenter.instance.showDailyCapAlert(
            'Daily cap reached',
            'You\'ve hit your ${s.dailyTradeCap}-trade cap for today. See you tomorrow.',
          ),
        );
      }
    }
  }
}
