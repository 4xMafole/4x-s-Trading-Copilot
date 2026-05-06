import '../data/models.dart';

/// Sprint 4.2 — Weekly risk budget engine.
///
/// Tracks how much of the trader's weekly R-budget has been consumed by
/// realized losses on real (non-hypothetical) trades during the current
/// ISO week (Mon..Sun in EAT). Pure / offline / no I/O.
class RiskBudgetEngine {
  const RiskBudgetEngine._();

  /// Total realized loss this week (positive USD), real trades only.
  static double weeklyLossUsd(List<Trade> all, DateTime nowEat) {
    final daysSinceMon = (nowEat.weekday - DateTime.monday) % 7;
    final monday = DateTime(
      nowEat.year,
      nowEat.month,
      nowEat.day,
    ).subtract(Duration(days: daysSinceMon));
    final mondayKey = _fmt(monday);

    double loss = 0;
    for (final t in all) {
      if (t.isHypothetical) continue;
      if (t.date.compareTo(mondayKey) < 0) continue;
      if (t.pnl < 0) loss += -t.pnl;
    }
    return loss;
  }

  /// Convert weekly loss USD → consumed R-units.
  static double consumedR(double lossUsd, WeeklyRiskBudget b) {
    if (b.rUnitUsd <= 0) return 0;
    return lossUsd / b.rUnitUsd;
  }

  /// 0..1 fraction of the weekly R-budget consumed.
  static double consumedFraction(double lossUsd, WeeklyRiskBudget b) {
    if (b.weeklyBudgetR <= 0 || b.rUnitUsd <= 0) return 0;
    final used = consumedR(lossUsd, b);
    return (used / b.weeklyBudgetR).clamp(0.0, 1.0).toDouble();
  }

  /// True when the budget is exhausted (>=100%) — caller should force
  /// paper-only mode for the rest of the week.
  static bool isExhausted(double lossUsd, WeeklyRiskBudget b) {
    if (!b.enabled || b.weeklyBudgetR <= 0 || b.rUnitUsd <= 0) return false;
    return consumedR(lossUsd, b) >= b.weeklyBudgetR;
  }

  /// True at >=80% — caller should show a warning banner.
  static bool isWarning(double lossUsd, WeeklyRiskBudget b) {
    if (!b.enabled || b.weeklyBudgetR <= 0 || b.rUnitUsd <= 0) return false;
    return consumedFraction(lossUsd, b) >= 0.8;
  }

  static String _fmt(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}
