import '../data/models.dart';

/// Aggregated win-rate / P&L bucket. Used by the Personal Edge UI to render
/// the trader's actual hot zones and dead zones.
class EdgeBucket {
  const EdgeBucket({
    required this.label,
    required this.wins,
    required this.losses,
    required this.totalPnl,
  });

  final String label;
  final int wins;
  final int losses;
  final double totalPnl;

  int get count => wins + losses;
  double get winRate => count == 0 ? 0 : wins / count;
}

/// Self-calibrating personal-edge analytics.
///
/// Replaces hardcoded "best window" guesses with the trader's actual
/// historical performance. Activates once the trader has logged ≥30 real
/// (non-hypothetical) trades — fewer than that is statistically meaningless.
class PersonalEdgeEngine {
  const PersonalEdgeEngine._();

  /// Minimum real trades required before personal-edge insights surface.
  static const int kMinTrades = 30;

  /// True once the trader has enough history for stable metrics.
  static bool isReady(List<Trade> allTrades) {
    return _real(allTrades).length >= kMinTrades;
  }

  static List<Trade> _real(List<Trade> all) =>
      all.where((t) => !t.isHypothetical).toList();

  /// Win rate by hour-of-day (EAT). Returns 24 buckets (00..23). Hours with
  /// zero trades are still included so the UI can render a stable heatmap.
  static List<EdgeBucket> hourlyBuckets(List<Trade> allTrades) {
    final buckets = List<_MutableBucket>.generate(
      24,
      (h) => _MutableBucket(label: '${h.toString().padLeft(2, '0')}:00'),
    );
    for (final t in _real(allTrades)) {
      final h = _parseHourEat(t.time);
      if (h == null) continue;
      buckets[h].add(t.pnl);
    }
    return buckets.map((b) => b.toEdgeBucket()).toList();
  }

  /// Win rate by instrument symbol.
  static List<EdgeBucket> instrumentBuckets(List<Trade> allTrades) {
    final map = <String, _MutableBucket>{};
    for (final t in _real(allTrades)) {
      final b = map.putIfAbsent(t.sym, () => _MutableBucket(label: t.sym));
      b.add(t.pnl);
    }
    final list = map.values.map((b) => b.toEdgeBucket()).toList();
    list.sort((a, b) => b.totalPnl.compareTo(a.totalPnl));
    return list;
  }

  /// Win rate by day-of-week. 7 buckets (Mon..Sun).
  static List<EdgeBucket> dayOfWeekBuckets(List<Trade> allTrades) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final buckets = List<_MutableBucket>.generate(
      7,
      (i) => _MutableBucket(label: labels[i]),
    );
    for (final t in _real(allTrades)) {
      final dow = _parseDayOfWeek(t.date);
      if (dow == null) continue;
      buckets[dow].add(t.pnl);
    }
    return buckets.map((b) => b.toEdgeBucket()).toList();
  }

  /// Best contiguous trading window detected from hourly buckets.
  /// Looks for the 2-hour window with the highest combined P&L (≥4 trades).
  /// Returns null if no positive window exists yet.
  static EdgeBucket? bestWindow(List<Trade> allTrades) {
    final hourly = hourlyBuckets(allTrades);
    EdgeBucket? best;
    for (var h = 0; h < 23; h++) {
      final a = hourly[h];
      final b = hourly[h + 1];
      final combined = EdgeBucket(
        label: '${a.label}–${(h + 2).toString().padLeft(2, '0')}:00',
        wins: a.wins + b.wins,
        losses: a.losses + b.losses,
        totalPnl: a.totalPnl + b.totalPnl,
      );
      if (combined.count < 4 || combined.totalPnl <= 0) continue;
      if (best == null || combined.totalPnl > best.totalPnl) best = combined;
    }
    return best;
  }

  /// Worst contiguous 2-hour window. Returns null if nothing is consistently
  /// negative yet.
  static EdgeBucket? deadZone(List<Trade> allTrades) {
    final hourly = hourlyBuckets(allTrades);
    EdgeBucket? worst;
    for (var h = 0; h < 23; h++) {
      final a = hourly[h];
      final b = hourly[h + 1];
      final combined = EdgeBucket(
        label: '${a.label}–${(h + 2).toString().padLeft(2, '0')}:00',
        wins: a.wins + b.wins,
        losses: a.losses + b.losses,
        totalPnl: a.totalPnl + b.totalPnl,
      );
      if (combined.count < 4 || combined.totalPnl >= 0) continue;
      if (worst == null || combined.totalPnl < worst.totalPnl) worst = combined;
    }
    return worst;
  }

  // ── Parsers ──────────────────────────────────────────────────────────────
  /// Parses "HH:MM EAT" / "HH:MM" / "HH:MM:SS" and returns the hour 0-23.
  static int? _parseHourEat(String time) {
    final raw = time.trim();
    if (raw.isEmpty) return null;
    final colon = raw.indexOf(':');
    if (colon <= 0) return null;
    final h = int.tryParse(raw.substring(0, colon));
    if (h == null || h < 0 || h > 23) return null;
    return h;
  }

  /// Parses "YYYY-MM-DD" → weekday index where Mon=0..Sun=6.
  static int? _parseDayOfWeek(String date) {
    try {
      final dt = DateTime.parse(date);
      // DateTime.weekday: Mon=1..Sun=7
      return dt.weekday - 1;
    } catch (_) {
      return null;
    }
  }
}

class _MutableBucket {
  _MutableBucket({required this.label});
  final String label;
  int wins = 0;
  int losses = 0;
  double totalPnl = 0;

  void add(double pnl) {
    totalPnl += pnl;
    if (pnl > 0) {
      wins++;
    } else if (pnl < 0) {
      losses++;
    }
  }

  EdgeBucket toEdgeBucket() =>
      EdgeBucket(label: label, wins: wins, losses: losses, totalPnl: totalPnl);
}
