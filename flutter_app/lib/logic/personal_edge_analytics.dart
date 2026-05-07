import '../data/models.dart';

/// Per-user edge analytics. All computations are dynamic — each user gets
/// a personalized "Edge Map" derived purely from their own trade history.
///
/// Replaces the previously-hardcoded research dump in the Edge tab so that
/// any imported broker history (MT5/CSV) drives the same analytic outlook.
class PersonalEdgeAnalytics {
  PersonalEdgeAnalytics._();

  /// Minimum non-hypothetical trades required for any section to render
  /// meaningful results. Below this we surface a cold-start message.
  static const int kMinTrades = 5;

  /// Minimum trades on a single symbol before it can become the
  /// "deep dive" candidate.
  static const int kMinTradesForDeepDive = 8;

  // ── Top-level overview ──────────────────────────────────────────────

  static OverviewStats overview(List<Trade> trades) {
    final real = trades.where((t) => !t.isHypothetical).toList();
    if (real.isEmpty) return OverviewStats.empty();

    final wins = real.where((t) => t.pnl > 0).toList();
    final losses = real.where((t) => t.pnl < 0).toList();
    final netPnl = real.fold<double>(0, (s, t) => s + t.pnl);

    final avgWin = wins.isEmpty
        ? 0.0
        : wins.fold<double>(0, (s, t) => s + t.pnl) / wins.length;
    final avgLoss = losses.isEmpty
        ? 0.0
        : losses.fold<double>(0, (s, t) => s + t.pnl) / losses.length;

    // Avg R:R achieved = |avgWin| / |avgLoss|.
    final rr = (avgLoss == 0) ? 0.0 : avgWin / avgLoss.abs();

    // Profit factor = total wins / total losses (abs).
    final grossWin = wins.fold<double>(0, (s, t) => s + t.pnl);
    final grossLoss = losses.fold<double>(0, (s, t) => s + t.pnl).abs();
    final profitFactor = grossLoss == 0
        ? double.infinity
        : grossWin / grossLoss;

    // Period span (using trade `date` strings, format yyyy-MM-dd).
    final dates = real.map((t) => t.date).where((d) => d.isNotEmpty).toList()
      ..sort();
    final firstDate = dates.isEmpty ? null : dates.first;
    final lastDate = dates.isEmpty ? null : dates.last;

    return OverviewStats(
      total: real.length,
      wins: wins.length,
      netPnl: netPnl,
      winRate: real.isEmpty ? 0 : (wins.length / real.length) * 100,
      avgWin: avgWin,
      avgLoss: avgLoss,
      avgRR: rr,
      profitFactor: profitFactor,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  // ── Per-symbol breakdown ────────────────────────────────────────────

  /// Returns symbol stats sorted by trade count desc.
  static List<SymbolBreakdown> symbolBreakdown(List<Trade> trades) {
    final real = trades.where((t) => !t.isHypothetical).toList();
    final Map<String, List<Trade>> grouped = {};
    for (final t in real) {
      grouped.putIfAbsent(t.sym, () => []).add(t);
    }

    final out = <SymbolBreakdown>[];
    for (final entry in grouped.entries) {
      final list = entry.value;
      final wins = list.where((t) => t.pnl > 0).length;
      final net = list.fold<double>(0, (s, t) => s + t.pnl);
      out.add(
        SymbolBreakdown(
          symbol: entry.key,
          total: list.length,
          wins: wins,
          winRate: list.isEmpty ? 0 : (wins / list.length) * 100,
          netPnl: net,
        ),
      );
    }

    out.sort((a, b) => b.total.compareTo(a.total));
    return out;
  }

  /// Top performers (best edge): symbols with positive net P&L AND
  /// win rate above [_winRateThreshold] OR strong RR (large net P&L
  /// with low win rate is still profitable).
  static List<SymbolBreakdown> topPerformers(List<Trade> trades) {
    final all = symbolBreakdown(trades);
    return all.where((s) => s.netPnl > 0 && s.total >= 3).toList()
      ..sort((a, b) => b.netPnl.compareTo(a.netPnl));
  }

  /// Underperformers: net negative P&L on at least 3 trades.
  static List<SymbolBreakdown> underperformers(List<Trade> trades) {
    final all = symbolBreakdown(trades);
    return all.where((s) => s.netPnl < 0 && s.total >= 3).toList()
      ..sort((a, b) => a.netPnl.compareTo(b.netPnl)); // most negative first
  }

  // ── Session timing (hourly) ─────────────────────────────────────────

  /// Bucketed by hour-of-day window. Each bucket spans 2 hours so we
  /// don't fragment small samples. Hour is derived from the trade `time`
  /// (close time, EAT or whatever timezone the user trades in).
  static List<TimeBucket> hourlyBuckets(List<Trade> trades) {
    final real = trades.where((t) => !t.isHypothetical).toList();
    final buckets = <int, List<Trade>>{};
    for (final t in real) {
      final hour = _parseHour(t.time);
      if (hour == null) continue;
      final bucket = (hour ~/ 2) * 2; // 2-hour buckets: 0, 2, 4, ... 22
      buckets.putIfAbsent(bucket, () => []).add(t);
    }

    final out = <TimeBucket>[];
    for (final entry in buckets.entries) {
      final list = entry.value;
      final wins = list.where((t) => t.pnl > 0).length;
      final net = list.fold<double>(0, (s, t) => s + t.pnl);
      out.add(
        TimeBucket(
          startHour: entry.key,
          endHour: entry.key + 2,
          total: list.length,
          wins: wins,
          winRate: list.isEmpty ? 0 : (wins / list.length) * 100,
          netPnl: net,
        ),
      );
    }
    out.sort((a, b) => a.startHour.compareTo(b.startHour));
    return out;
  }

  /// Auto-detect the user's worst time window — at least 3 trades, net
  /// negative P&L, and below 35% win rate. Returns null if no window
  /// qualifies.
  static TimeBucket? worstTimeWindow(List<Trade> trades) {
    final buckets = hourlyBuckets(trades);
    final candidates =
        buckets
            .where((b) => b.total >= 3 && b.netPnl < 0 && b.winRate < 35)
            .toList()
          ..sort((a, b) => a.netPnl.compareTo(b.netPnl));
    return candidates.isEmpty ? null : candidates.first;
  }

  /// Auto-detect the user's best time window — at least 3 trades, net
  /// positive P&L, win rate above 50%.
  static TimeBucket? bestTimeWindow(List<Trade> trades) {
    final buckets = hourlyBuckets(trades);
    final candidates =
        buckets
            .where((b) => b.total >= 3 && b.netPnl > 0 && b.winRate >= 50)
            .toList()
          ..sort((a, b) => b.netPnl.compareTo(a.netPnl));
    return candidates.isEmpty ? null : candidates.first;
  }

  // ── Deep-dive symbol (auto-detect) ──────────────────────────────────

  /// Returns the symbol that deserves a deep dive — the most-traded
  /// instrument that has at least [kMinTradesForDeepDive] trades. Returns
  /// null if the user doesn't have a clear primary instrument yet.
  static String? deepDiveSymbol(List<Trade> trades) {
    final breakdown = symbolBreakdown(trades);
    final candidate = breakdown.firstWhere(
      (s) => s.total >= kMinTradesForDeepDive,
      orElse: () => const SymbolBreakdown(
        symbol: '',
        total: 0,
        wins: 0,
        winRate: 0,
        netPnl: 0,
      ),
    );
    return candidate.symbol.isEmpty ? null : candidate.symbol;
  }

  /// Buy/sell directional bias for a single symbol.
  static DirectionBias? directionBias(List<Trade> trades, String symbol) {
    final list = trades
        .where((t) => !t.isHypothetical && t.sym == symbol)
        .toList();
    if (list.length < 4) return null;

    final buys = list.where((t) => t.dir == 'buy').toList();
    final sells = list.where((t) => t.dir == 'sell').toList();

    return DirectionBias(
      symbol: symbol,
      buyTotal: buys.length,
      buyWins: buys.where((t) => t.pnl > 0).length,
      buyNet: buys.fold<double>(0, (s, t) => s + t.pnl),
      sellTotal: sells.length,
      sellWins: sells.where((t) => t.pnl > 0).length,
      sellNet: sells.fold<double>(0, (s, t) => s + t.pnl),
    );
  }

  /// Day-of-week breakdown for a single symbol. Returned sorted Mon→Sun.
  static List<DayOfWeekBucket> dayOfWeekBreakdown(
    List<Trade> trades,
    String symbol,
  ) {
    final list = trades
        .where((t) => !t.isHypothetical && t.sym == symbol)
        .toList();
    final buckets = <int, List<Trade>>{};
    for (final t in list) {
      final dt = DateTime.tryParse(t.date);
      if (dt == null) continue;
      buckets.putIfAbsent(dt.weekday, () => []).add(t);
    }

    final out = <DayOfWeekBucket>[];
    for (final entry in buckets.entries) {
      final tradesOnDay = entry.value;
      final wins = tradesOnDay.where((t) => t.pnl > 0).length;
      final net = tradesOnDay.fold<double>(0, (s, t) => s + t.pnl);
      out.add(
        DayOfWeekBucket(
          weekday: entry.key,
          total: tradesOnDay.length,
          wins: wins,
          winRate: tradesOnDay.isEmpty ? 0 : (wins / tradesOnDay.length) * 100,
          netPnl: net,
        ),
      );
    }
    out.sort((a, b) => a.weekday.compareTo(b.weekday));
    return out;
  }

  // ── Stacking detection ──────────────────────────────────────────────

  /// A "stacked day" is any trading day with 3+ trades on the same symbol.
  /// Compares stacked days vs single-entry days (1 trade per symbol per day).
  static StackingAnalysis stackingAnalysis(List<Trade> trades) {
    final real = trades.where((t) => !t.isHypothetical).toList();
    // Group by (date, symbol).
    final Map<String, List<Trade>> daySym = {};
    for (final t in real) {
      final key = '${t.date}|${t.sym}';
      daySym.putIfAbsent(key, () => []).add(t);
    }

    final stackedTrades = <Trade>[];
    final singleTrades = <Trade>[];
    var stackedDayCount = 0;
    var singleDayCount = 0;

    for (final list in daySym.values) {
      if (list.length >= 3) {
        stackedTrades.addAll(list);
        stackedDayCount++;
      } else if (list.length == 1) {
        singleTrades.addAll(list);
        singleDayCount++;
      }
    }

    return StackingAnalysis(
      stackedTotal: stackedTrades.length,
      stackedWins: stackedTrades.where((t) => t.pnl > 0).length,
      stackedNet: stackedTrades.fold<double>(0, (s, t) => s + t.pnl),
      stackedDayCount: stackedDayCount,
      singleTotal: singleTrades.length,
      singleWins: singleTrades.where((t) => t.pnl > 0).length,
      singleNet: singleTrades.fold<double>(0, (s, t) => s + t.pnl),
      singleDayCount: singleDayCount,
    );
  }

  // ── Behavioral flags (auto-detect) ──────────────────────────────────

  /// Returns a list of behavioral flags derived from the user's history.
  /// Each flag is a structured insight with severity tone.
  static List<BehaviorFlag> behaviorFlags(List<Trade> trades) {
    final out = <BehaviorFlag>[];
    final real = trades.where((t) => !t.isHypothetical).toList();
    if (real.length < kMinTrades) return out;

    // 1. Stacking flag.
    final stacking = stackingAnalysis(trades);
    if (stacking.stackedTotal >= 3 &&
        stacking.singleTotal >= 3 &&
        stacking.stackedWinRate < stacking.singleWinRate - 10) {
      out.add(
        BehaviorFlag(
          title: 'STACKING',
          severity: BehaviorSeverity.critical,
          body:
              'Stacked days (3+ trades): ${stacking.stackedWinRate.toStringAsFixed(1)}% WR. '
              'Single-entry days: ${stacking.singleWinRate.toStringAsFixed(1)}% WR. '
              'After any losing trade, wait 60 minutes before re-entering the same instrument.',
        ),
      );
    }

    // 2. Worst time window.
    final worst = worstTimeWindow(trades);
    if (worst != null) {
      out.add(
        BehaviorFlag(
          title: 'WORST TIME WINDOW',
          severity: BehaviorSeverity.critical,
          body:
              '${_fmtHour(worst.startHour)}–${_fmtHour(worst.endHour)}: '
              '${worst.total} trades, ${worst.winRate.toStringAsFixed(1)}% WR, '
              '${_signed(worst.netPnl)}. Treat this window as a no-trade zone.',
        ),
      );
    }

    // 3. Direction bias on top symbol.
    final deepSym = deepDiveSymbol(trades);
    if (deepSym != null) {
      final bias = directionBias(trades, deepSym);
      if (bias != null && bias.hasMeaningfulSplit) {
        final winnerSide = bias.buyWinRate > bias.sellWinRate
            ? 'BUYS'
            : 'SELLS';
        final loserSide = winnerSide == 'BUYS' ? 'SELLS' : 'BUYS';
        final winnerWR = (winnerSide == 'BUYS'
            ? bias.buyWinRate
            : bias.sellWinRate);
        final loserWR = (loserSide == 'BUYS'
            ? bias.buyWinRate
            : bias.sellWinRate);
        if ((winnerWR - loserWR).abs() >= 20) {
          out.add(
            BehaviorFlag(
              title: '$deepSym DIRECTIONAL BIAS',
              severity: BehaviorSeverity.warning,
              body:
                  '$deepSym $winnerSide: ${winnerWR.toStringAsFixed(1)}% WR. '
                  '$loserSide: ${loserWR.toStringAsFixed(1)}% WR. '
                  'Default to $winnerSide until macro structure shifts.',
            ),
          );
        }
      }
    }

    // 4. Lot size inconsistency.
    if (real.length >= 10) {
      final lots = real.map((t) => t.lots).toList()..sort();
      final minLot = lots.first;
      final maxLot = lots.last;
      if (minLot > 0 && maxLot / minLot >= 10) {
        out.add(
          BehaviorFlag(
            title: 'LOT SIZE INCONSISTENCY',
            severity: BehaviorSeverity.warning,
            body:
                'Lot sizes range from $minLot to $maxLot (${(maxLot / minLot).toStringAsFixed(1)}× spread). '
                'Use the Calculator before every trade to enforce a consistent risk model.',
          ),
        );
      }
    }

    // 5. Loss streak signal (recent).
    final recent = real.take(10).toList();
    if (recent.length >= 5) {
      final consecutiveLosses = _maxConsecutiveLosses(recent);
      if (consecutiveLosses >= 4) {
        out.add(
          BehaviorFlag(
            title: 'RECENT LOSS STREAK',
            severity: BehaviorSeverity.critical,
            body:
                '$consecutiveLosses consecutive losing trades in your last 10. '
                'Step away — review setup criteria before any new entry.',
          ),
        );
      }
    }

    return out;
  }

  // ── Internals ───────────────────────────────────────────────────────

  static int? _parseHour(String time) {
    if (time.isEmpty) return null;
    final m = RegExp(r'^(\d{1,2}):').firstMatch(time);
    if (m == null) return null;
    final h = int.tryParse(m.group(1) ?? '');
    if (h == null || h < 0 || h > 23) return null;
    return h;
  }

  static int _maxConsecutiveLosses(List<Trade> trades) {
    var maxRun = 0;
    var run = 0;
    for (final t in trades) {
      if (t.pnl < 0) {
        run++;
        if (run > maxRun) maxRun = run;
      } else {
        run = 0;
      }
    }
    return maxRun;
  }

  static String _fmtHour(int h) => '${h.toString().padLeft(2, '0')}:00';

  static String _signed(double v) => v >= 0
      ? '+\$${v.toStringAsFixed(2)}'
      : '-\$${v.abs().toStringAsFixed(2)}';
}

// ─── Data classes ──────────────────────────────────────────────────────

class OverviewStats {
  final int total;
  final int wins;
  final double netPnl;
  final double winRate;
  final double avgWin;
  final double avgLoss;
  final double avgRR;
  final double profitFactor;
  final String? firstDate;
  final String? lastDate;

  const OverviewStats({
    required this.total,
    required this.wins,
    required this.netPnl,
    required this.winRate,
    required this.avgWin,
    required this.avgLoss,
    required this.avgRR,
    required this.profitFactor,
    required this.firstDate,
    required this.lastDate,
  });

  factory OverviewStats.empty() => const OverviewStats(
    total: 0,
    wins: 0,
    netPnl: 0,
    winRate: 0,
    avgWin: 0,
    avgLoss: 0,
    avgRR: 0,
    profitFactor: 0,
    firstDate: null,
    lastDate: null,
  );

  bool get hasData => total > 0;

  /// Plain-English period like "Jul 2025 – Mar 2026" or "Aug 2025".
  String? get periodLabel {
    if (firstDate == null || lastDate == null) return null;
    final f = DateTime.tryParse(firstDate!);
    final l = DateTime.tryParse(lastDate!);
    if (f == null || l == null) return null;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final fLabel = '${months[f.month - 1]} ${f.year}';
    final lLabel = '${months[l.month - 1]} ${l.year}';
    return fLabel == lLabel ? fLabel : '$fLabel – $lLabel';
  }
}

class SymbolBreakdown {
  final String symbol;
  final int total;
  final int wins;
  final double winRate;
  final double netPnl;

  const SymbolBreakdown({
    required this.symbol,
    required this.total,
    required this.wins,
    required this.winRate,
    required this.netPnl,
  });
}

class TimeBucket {
  final int startHour; // 0-22 (2-hour buckets)
  final int endHour;
  final int total;
  final int wins;
  final double winRate;
  final double netPnl;

  const TimeBucket({
    required this.startHour,
    required this.endHour,
    required this.total,
    required this.wins,
    required this.winRate,
    required this.netPnl,
  });

  String get label =>
      '${startHour.toString().padLeft(2, '0')}:00–'
      '${endHour.toString().padLeft(2, '0')}:00';
}

class DirectionBias {
  final String symbol;
  final int buyTotal;
  final int buyWins;
  final double buyNet;
  final int sellTotal;
  final int sellWins;
  final double sellNet;

  const DirectionBias({
    required this.symbol,
    required this.buyTotal,
    required this.buyWins,
    required this.buyNet,
    required this.sellTotal,
    required this.sellWins,
    required this.sellNet,
  });

  double get buyWinRate => buyTotal == 0 ? 0 : (buyWins / buyTotal) * 100;
  double get sellWinRate => sellTotal == 0 ? 0 : (sellWins / sellTotal) * 100;

  bool get hasMeaningfulSplit => buyTotal >= 3 && sellTotal >= 3;
}

class DayOfWeekBucket {
  final int weekday; // DateTime.monday ... DateTime.sunday
  final int total;
  final int wins;
  final double winRate;
  final double netPnl;

  const DayOfWeekBucket({
    required this.weekday,
    required this.total,
    required this.wins,
    required this.winRate,
    required this.netPnl,
  });

  String get label {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(weekday - 1).clamp(0, 6)];
  }
}

class StackingAnalysis {
  final int stackedTotal;
  final int stackedWins;
  final double stackedNet;
  final int stackedDayCount;
  final int singleTotal;
  final int singleWins;
  final double singleNet;
  final int singleDayCount;

  const StackingAnalysis({
    required this.stackedTotal,
    required this.stackedWins,
    required this.stackedNet,
    required this.stackedDayCount,
    required this.singleTotal,
    required this.singleWins,
    required this.singleNet,
    required this.singleDayCount,
  });

  double get stackedWinRate =>
      stackedTotal == 0 ? 0 : (stackedWins / stackedTotal) * 100;
  double get singleWinRate =>
      singleTotal == 0 ? 0 : (singleWins / singleTotal) * 100;

  bool get hasData => stackedTotal > 0 || singleTotal > 0;
}

enum BehaviorSeverity { warning, critical }

class BehaviorFlag {
  final String title;
  final BehaviorSeverity severity;
  final String body;

  const BehaviorFlag({
    required this.title,
    required this.severity,
    required this.body,
  });
}
