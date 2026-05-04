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
    await _save(
      state.appState.copyWith(
        balance: balance ?? state.appState.balance,
        startDate: startDate ?? state.appState.startDate,
        priorPnl: priorPnl ?? state.appState.priorPnl,
      ),
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
    final remaining = 2 - getTodayTrades().length;
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
      'g8': tc < 2 && !state.appState.lock,
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
    if (todayTrades.length >= 2 &&
        todayTrades.every((t) => t.pnl < 0) &&
        !lock) {
      lock = true;
      lockUntil = DateTime.now().millisecondsSinceEpoch + (24 * 3600 * 1000);
    }

    if (lock != state.appState.lock || lockUntil != state.appState.lockUntil) {
      await _save(state.appState.copyWith(lock: lock, lockUntil: lockUntil));
    }
  }

  // ── Trade mutations ──────────────────────────────────────────────────────
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
    );

    await _save(
      state.appState.copyWith(
        allTrades: <Trade>[...state.appState.allTrades, trade],
      ),
    );
    await checkLock();
  }

  Future<void> deleteTrade(String id) async {
    await _save(
      state.appState.copyWith(
        allTrades: state.appState.allTrades.where((t) => t.id != id).toList(),
      ),
    );
    await checkLock();
  }

  Future<void> updateTrade(Trade updated) async {
    var found = false;
    final next = state.appState.allTrades.map((t) {
      if (t.id != updated.id) return t;
      found = true;
      return updated;
    }).toList();
    if (!found) next.add(updated);

    await _save(state.appState.copyWith(allTrades: next));
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

  Future<void> toggleCheck(String id) async {
    final checks = <String, bool>{...state.appState.checks};
    checks[id] = !(checks[id] ?? false);
    await _save(state.appState.copyWith(checks: checks));
  }

  Future<void> resetChecks(List<String> gateIds) async {
    final checks = <String, bool>{...state.appState.checks};
    for (final id in gateIds) {
      checks[id] = false;
    }
    await _save(state.appState.copyWith(checks: checks));
  }

  Future<void> resetToday() async {
    final today = eatDateStr(state.nowEAT);
    await _save(
      state.appState.copyWith(
        allTrades: state.appState.allTrades
            .where((t) => t.date != today)
            .toList(),
        checks: <String, bool>{},
        lock: false,
        lockUntil: null,
      ),
    );
  }

  Future<void> resetAll() async {
    await _save(AppState.defaults().copyWith(preloaded: true));
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
}
