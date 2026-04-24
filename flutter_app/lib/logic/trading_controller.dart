import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models.dart';

class TradingController extends ChangeNotifier {
  TradingController();

  static const String _storageKey = 'em_fp2_v4';

  AppState _state = AppState.defaults();
  AppState get state => _state;

  int _activeTab = 0;
  int get activeTab => _activeTab;

  DateTime _nowEAT = _getEAT();
  DateTime get nowEAT => _nowEAT;

  Timer? _ticker;

  Future<void> init() async {
    await _load();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _nowEAT = _getEAT();
      checkLock();
      notifyListeners();
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void setActiveTab(int index) {
    _activeTab = index;
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored == null || stored.isEmpty) {
      _state = AppState.defaults().copyWith(preloaded: true);
      return;
    }
    try {
      final parsed = jsonDecode(stored) as Map<String, dynamic>;
      _state = AppState.fromJson(parsed).copyWith(preloaded: true);
    } catch (_) {
      _state = AppState.defaults().copyWith(preloaded: true);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_state.toJson()));
  }

  Future<void> updateState({
    double? balance,
    String? startDate,
    double? priorPnl,
  }) async {
    _state = _state.copyWith(
      balance: balance,
      startDate: startDate,
      priorPnl: priorPnl,
    );
    await _save();
    notifyListeners();
  }

  List<Trade> getTodayTrades() {
    final today = eatDateStr(_nowEAT);
    return _state.allTrades.where((t) => t.date == today).toList();
  }

  double getTodayPnl() {
    return getTodayTrades().fold<double>(0, (sum, t) => sum + t.pnl);
  }

  double getChallengePnl() {
    return _state.priorPnl + getTodayPnl();
  }

  int getDayNumber() {
    final start =
        DateTime.tryParse('${_state.startDate}T00:00:00Z') ??
        DateTime.utc(2026, 4, 20);
    final today = DateTime.parse('${eatDateStr(_nowEAT)}T00:00:00Z');
    final diff = today.difference(start).inDays + 1;
    return diff < 1 ? 1 : diff;
  }

  Future<void> checkLock() async {
    bool lock = _state.lock;
    int? lockUntil = _state.lockUntil;

    if (lock &&
        lockUntil != null &&
        DateTime.now().millisecondsSinceEpoch > lockUntil) {
      lock = false;
      lockUntil = null;
    }

    final todayTrades = getTodayTrades();
    if (todayTrades.length >= 2 &&
        todayTrades.every((t) => t.pnl < 0) &&
        !lock) {
      lock = true;
      lockUntil = DateTime.now().millisecondsSinceEpoch + (24 * 3600 * 1000);
    }

    if (lock != _state.lock || lockUntil != _state.lockUntil) {
      _state = _state.copyWith(
        lock: lock,
        lockUntil: lockUntil,
        clearLockUntil: lockUntil == null,
      );
      await _save();
    }
  }

  Future<void> addTrade({
    required String sym,
    required String dir,
    required double lots,
    required double pnl,
    required String note,
    required List<String> violations,
  }) async {
    final eat = _getEAT();
    final trade = Trade(
      id: 't${DateTime.now().millisecondsSinceEpoch}',
      date: eatDateStr(eat),
      time:
          '${eat.toUtc().hour.toString().padLeft(2, '0')}:${eat.toUtc().minute.toString().padLeft(2, '0')} EAT',
      sym: sym,
      dir: dir,
      lots: lots,
      pnl: pnl,
      note: note,
      violations: violations,
    );

    _state = _state.copyWith(allTrades: <Trade>[..._state.allTrades, trade]);
    await checkLock();
    await _save();
    notifyListeners();
  }

  Future<void> deleteTrade(String id) async {
    _state = _state.copyWith(
      allTrades: _state.allTrades.where((t) => t.id != id).toList(),
    );
    await checkLock();
    await _save();
    notifyListeners();
  }

  Future<void> toggleCheck(String id) async {
    final checks = <String, bool>{..._state.checks};
    checks[id] = !(checks[id] ?? false);
    _state = _state.copyWith(checks: checks);
    await _save();
    notifyListeners();
  }

  Future<void> resetChecks(List<String> gateIds) async {
    final checks = <String, bool>{..._state.checks};
    for (final id in gateIds) {
      checks[id] = false;
    }
    _state = _state.copyWith(checks: checks);
    await _save();
    notifyListeners();
  }

  Future<void> resetToday() async {
    final today = eatDateStr(_nowEAT);
    _state = _state.copyWith(
      allTrades: _state.allTrades.where((t) => t.date != today).toList(),
      checks: <String, bool>{},
      lock: false,
      clearLockUntil: true,
    );
    await _save();
    notifyListeners();
  }

  Future<void> resetAll() async {
    _state = AppState.defaults().copyWith(preloaded: true);
    await _save();
    notifyListeners();
  }

  String exportData() => _state.toPrettyJson();

  Future<bool> importData(String data) async {
    try {
      final parsed = jsonDecode(data) as Map<String, dynamic>;
      _state = AppState.fromJson(parsed).copyWith(preloaded: true);
      await _save();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, bool> computeAutoGates() {
    final h = _nowEAT.toUtc().hour;
    final m = _nowEAT.toUtc().minute;
    final t = h * 60 + m;
    final fri = _nowEAT.toUtc().weekday == DateTime.friday;
    final tc = getTodayTrades().length;

    return <String, bool>{
      'g2': !(t >= 540 && t < 630),
      'g3': !(t >= 900 && t <= 990),
      'g8': tc < 2 && !_state.lock,
      'g11': !(fri && t >= 1200),
    };
  }

  SessionInfo getSessionInfo() => computeSessionInfo(_nowEAT);

  static DateTime _getEAT() {
    return DateTime.now().toUtc().add(const Duration(hours: 3));
  }
}

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
