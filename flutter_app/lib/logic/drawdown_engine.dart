import 'dart:math' as math;

import '../data/models.dart';

/// Sprint 4.1 — Drawdown awareness engine.
///
/// All math is pure, deterministic, and offline. No I/O. Used by the
/// "Distance from Bust" dashboard card.
class DrawdownEngine {
  const DrawdownEngine._();

  /// Computes today's realized loss (positive number = how much we are down).
  /// Returns 0 if today is currently green.
  static double dailyDrawdown(List<Trade> allTrades, DateTime nowEat) {
    final today = _fmt(nowEat);
    double sum = 0;
    for (final t in allTrades) {
      if (t.isHypothetical) continue;
      if (t.date == today) sum += t.pnl;
    }
    return sum < 0 ? -sum : 0.0;
  }

  /// Cumulative realized P/L for the current ISO week (Mon..Sun in EAT).
  /// Returns positive number if down, 0 if green/flat.
  static double weeklyDrawdown(List<Trade> allTrades, DateTime nowEat) {
    final daysSinceMon = (nowEat.weekday - DateTime.monday) % 7;
    final monday = DateTime(
      nowEat.year,
      nowEat.month,
      nowEat.day,
    ).subtract(Duration(days: daysSinceMon));
    final mondayKey = _fmt(monday);

    double sum = 0;
    for (final t in allTrades) {
      if (t.isHypothetical) continue;
      if (t.date.compareTo(mondayKey) >= 0) sum += t.pnl;
    }
    return sum < 0 ? -sum : 0.0;
  }

  /// Trailing peak-to-trough drawdown across the entire equity curve,
  /// starting from `startBalance + priorPnl`. Returns positive USD.
  static double maxTrailingDrawdown({
    required double startBalance,
    required double priorPnl,
    required List<Trade> allTrades,
  }) {
    final real = allTrades.where((t) => !t.isHypothetical).toList()
      ..sort((a, b) {
        final d = a.date.compareTo(b.date);
        if (d != 0) return d;
        return a.time.compareTo(b.time);
      });
    double equity = startBalance + priorPnl;
    double peak = equity;
    double maxDd = 0;
    for (final t in real) {
      equity += t.pnl;
      if (equity > peak) peak = equity;
      final dd = peak - equity;
      if (dd > maxDd) maxDd = dd;
    }
    return maxDd;
  }

  /// Current trailing drawdown from peak (live, not historical max).
  static double currentTrailingDrawdown({
    required double startBalance,
    required double priorPnl,
    required List<Trade> allTrades,
  }) {
    final real = allTrades.where((t) => !t.isHypothetical).toList()
      ..sort((a, b) {
        final d = a.date.compareTo(b.date);
        if (d != 0) return d;
        return a.time.compareTo(b.time);
      });
    double equity = startBalance + priorPnl;
    double peak = equity;
    for (final t in real) {
      equity += t.pnl;
      if (equity > peak) peak = equity;
    }
    return math.max(0, peak - equity);
  }

  /// 0..1 fraction of the daily limit consumed (0 = safe, 1 = bust).
  static double dailyConsumed(double dd, double limit) {
    if (limit <= 0) return 0;
    return (dd / limit).clamp(0.0, 1.0).toDouble();
  }

  /// 0..1 fraction of the trailing total limit consumed.
  static double totalConsumed(double dd, double limit) {
    if (limit <= 0) return 0;
    return (dd / limit).clamp(0.0, 1.0).toDouble();
  }

  static String _fmt(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}

enum DrawdownTone { safe, caution, danger }

DrawdownTone toneFor(double consumed) {
  if (consumed >= 0.7) return DrawdownTone.danger;
  if (consumed >= 0.4) return DrawdownTone.caution;
  return DrawdownTone.safe;
}
