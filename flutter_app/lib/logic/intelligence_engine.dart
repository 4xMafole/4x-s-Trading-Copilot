import 'package:flutter/material.dart';

import '../data/models.dart';
import '../ui/app_theme.dart';
import '../ui/trading_screen_view_model.dart';

/// One smart insight surfaced on the dashboard.
class Insight {
  const Insight(this.icon, this.text, this.tone);
  final IconData icon;
  final String text;
  final Color tone;
}

/// Pure business-logic helpers derived from the live trading state.
///
/// Intentionally framework-agnostic beyond [IconData]/[Color] (which are
/// platform-neutral value types). The UI imports these to render — it does
/// not redefine them.
class IntelligenceEngine {
  const IntelligenceEngine._();

  /// Smart insights derived from session, P/L, trade count, gates and lock.
  static List<Insight> computeInsights(TradingScreenViewModel c) {
    final insights = <Insight>[];
    final session = c.getSessionInfo();
    final today = c.getTodayPnl();
    final trades = c.getTodayTrades();
    final autoGates = c.computeAutoGates();
    final gates = c.state.effectiveGates;
    final passedCount = gates.where((g) {
      if (g.auto) return autoGates[g.id] ?? false;
      return c.state.checks[g.id] ?? false;
    }).length;

    if (!session.ok) {
      insights.add(
        Insight(
          Icons.block,
          'No-trade zone active. ${session.detail}',
          AppTheme.red,
        ),
      );
    } else {
      insights.add(
        Insight(
          Icons.check_circle_outline,
          '${session.label} — execution window open.',
          AppTheme.green,
        ),
      );
    }

    if (today < -100) {
      insights.add(
        Insight(
          Icons.warning_amber_rounded,
          'Down ${today.abs().toStringAsFixed(0)} USD today. Protect remaining capital.',
          AppTheme.red,
        ),
      );
    } else if (today > 200) {
      insights.add(
        Insight(
          Icons.trending_up,
          'Strong day at +${today.toStringAsFixed(0)} USD. Consider locking profit.',
          AppTheme.green,
        ),
      );
    }

    if (trades.length >= c.state.dailyTradeCap) {
      insights.add(
        Insight(
          Icons.do_not_disturb,
          'Max daily trades reached. Review journal and stop.',
          AppTheme.amber,
        ),
      );
    } else if (trades.length == 1 && trades.first.pnl < 0) {
      insights.add(
        Insight(
          Icons.psychology,
          'First trade was a loss. Stay disciplined on the second.',
          AppTheme.amber,
        ),
      );
    }

    if (passedCount < gates.length && session.ok) {
      final remaining = gates.length - passedCount;
      insights.add(
        Insight(
          Icons.checklist,
          '$remaining gate${remaining == 1 ? '' : 's'} still pending before entry.',
          AppTheme.accent,
        ),
      );
    } else if (passedCount == gates.length && session.ok && trades.length < 2) {
      insights.add(
        Insight(
          Icons.rocket_launch_outlined,
          'All gates passed. You are cleared to execute.',
          AppTheme.green,
        ),
      );
    }

    if (c.state.lock) {
      insights.add(
        Insight(
          Icons.lock_outline,
          'Account locked after consecutive losses. Rest and reset.',
          AppTheme.red,
        ),
      );
    }

    // Setup-quality vs P/L correlation. Surfaces once we have ≥10 tagged
    // closed trades — too few before that to be meaningful.
    final tagged = c.state.allTrades
        .where((t) => !t.isHypothetical && (t.setupQuality ?? '').isNotEmpty)
        .toList();
    if (tagged.length >= 10) {
      double sumOf(String q) => tagged
          .where((t) => t.setupQuality == q)
          .fold<double>(0, (s, t) => s + t.pnl);
      int countOf(String q) => tagged.where((t) => t.setupQuality == q).length;

      final aPnl = sumOf('A+');
      final bPnl = sumOf('B');
      final cPnl = sumOf('C');
      final aCount = countOf('A+');
      final cCount = countOf('C');

      if (aPnl > 0 && (bPnl + cPnl) <= 0) {
        insights.add(
          Insight(
            Icons.star_outline,
            'A+ setups produced +${aPnl.toStringAsFixed(0)} USD. B/C trades drag you down — only take A+.',
            AppTheme.green,
          ),
        );
      } else if (cCount >= aCount && cPnl < 0) {
        insights.add(
          Insight(
            Icons.warning_amber_rounded,
            'C-grade setups are bleeding (${cPnl.toStringAsFixed(0)} USD over $cCount trades). Tighten setup quality.',
            AppTheme.red,
          ),
        );
      }
    }

    // Trigger pattern detection. ≥10 tagged trades with non-Plan triggers.
    final triggered = c.state.allTrades
        .where((t) => !t.isHypothetical && (t.trigger ?? '').isNotEmpty)
        .toList();
    if (triggered.length >= 10) {
      final nonPlan = triggered.where((t) => t.trigger != 'Plan').toList();
      if (nonPlan.length / triggered.length >= 0.5) {
        final pct = (nonPlan.length * 100 / triggered.length).round();
        insights.add(
          Insight(
            Icons.psychology_alt,
            '$pct% of recent trades were impulse-triggered (FOMO/Revenge/etc). Trade only the plan.',
            AppTheme.amber,
          ),
        );
      }
    }

    // Mood-aware nudge. If today's mood is a known risk state, warn the
    // trader before they enter — even if every gate passed.
    final todayMood = c.getTodayMood();
    if (todayMood != null && session.ok && trades.length < 2) {
      const riskMoods = {'Frustrated', 'Hyped', 'Tired'};
      if (riskMoods.contains(todayMood.mood)) {
        insights.add(
          Insight(
            Icons.mood_bad,
            'You logged "${todayMood.mood}" today. Risk-off moods historically degrade execution — consider half-size or paper.',
            AppTheme.amber,
          ),
        );
      }
    }

    // Mood vs P/L correlation once we have enough history (≥10 days with mood).
    final moodMap = c.state.dailyMoods;
    if (moodMap.length >= 10) {
      // PnL grouped by mood label.
      final moodPnl = <String, double>{};
      final moodCount = <String, int>{};
      for (final t in c.state.allTrades) {
        if (t.isHypothetical) continue;
        final m = moodMap[t.date];
        if (m == null) continue;
        moodPnl[m.mood] = (moodPnl[m.mood] ?? 0) + t.pnl;
        moodCount[m.mood] = (moodCount[m.mood] ?? 0) + 1;
      }
      String? worstMood;
      double worstPnl = 0;
      moodPnl.forEach((mood, pnl) {
        if ((moodCount[mood] ?? 0) >= 3 && pnl < worstPnl) {
          worstPnl = pnl;
          worstMood = mood;
        }
      });
      if (worstMood != null && worstPnl < 0) {
        insights.add(
          Insight(
            Icons.insights,
            '"$worstMood" days lost ${worstPnl.abs().toStringAsFixed(0)} USD historically. Sit out or paper-trade on these.',
            AppTheme.red,
          ),
        );
      }
    }

    // Sprint 4.3 — slippage / planned-vs-realized risk insight.
    final slippage = computeSlippageInsight(c.state.allTrades);
    if (slippage != null) insights.add(slippage);

    return insights;
  }

  /// Sprint 4.3 — Compares each trade's planned $ risk vs realized loss
  /// (absolute, only for losing trades). If the trader's average realized
  /// loss is materially larger than planned, surface it as an insight.
  /// Requires at least 5 losing trades with `plannedRisk` set.
  static Insight? computeSlippageInsight(List<Trade> all) {
    final losses = all
        .where(
          (t) =>
              !t.isHypothetical &&
              t.pnl < 0 &&
              t.plannedRisk != null &&
              t.plannedRisk! > 0,
        )
        .toList();
    if (losses.length < 5) return null;

    double sumPlanned = 0;
    double sumActual = 0;
    for (final t in losses) {
      sumPlanned += t.plannedRisk!;
      sumActual += -t.pnl;
    }
    if (sumPlanned <= 0) return null;
    final ratio = sumActual / sumPlanned;
    if (ratio < 1.15) return null; // within 15% — no leak.

    final pct = ((ratio - 1) * 100).round();
    return Insight(
      Icons.speed,
      'Average realized loss is ${ratio.toStringAsFixed(2)}x planned (+$pct% slippage). Tighten stop execution.',
      AppTheme.red,
    );
  }

  /// Composite readiness score (0-100) based on session window, gate pass
  /// rate, lock state and remaining trade slots.
  static int readinessScore(TradingScreenViewModel c) {
    int score = 0;
    final session = c.getSessionInfo();
    final auto = c.computeAutoGates();
    final effectiveGates = c.state.effectiveGates;
    final total = effectiveGates.length;
    final passed = effectiveGates.where((g) {
      if (g.auto) return auto[g.id] ?? false;
      return c.state.checks[g.id] ?? false;
    }).length;

    if (session.ok) score += 30;
    score += ((passed / total) * 50).round();
    if (!c.state.lock) score += 10;
    if (c.getTodayTrades().length < c.state.dailyTradeCap) score += 10;
    return score.clamp(0, 100);
  }

  /// Color used to render a readiness score chip/ring.
  static Color scoreColor(int score) {
    if (score >= 80) return AppTheme.green;
    if (score >= 50) return AppTheme.amber;
    return AppTheme.red;
  }

  /// Number of consecutive past calendar days (counting back from yesterday)
  /// where the user logged at least one trade and recorded zero violations.
  ///
  /// Today is excluded so the streak only counts *closed* sessions; a fresh
  /// violation today won't silently break a multi-week streak until tomorrow.
  /// Days with no trades at all also break the streak (no-trade days are
  /// neutral but cannot extend a discipline streak).
  static int disciplineStreak(TradingScreenViewModel c) {
    final trades = c.getRealTradesDesc();
    if (trades.isEmpty) return 0;

    final byDate = <String, List<Trade>>{};
    for (final t in trades) {
      byDate.putIfAbsent(t.date, () => <Trade>[]).add(t);
    }

    int streak = 0;
    var cursor = DateTime(
      c.nowEAT.year,
      c.nowEAT.month,
      c.nowEAT.day,
    ).subtract(const Duration(days: 1));

    // Cap at 365 to avoid pathological loops.
    for (int i = 0; i < 365; i++) {
      final key = _fmtDate(cursor);
      final dayTrades = byDate[key];
      if (dayTrades == null || dayTrades.isEmpty) break;
      final hasViolation = dayTrades.any((t) => t.violations.isNotEmpty);
      if (hasViolation) break;
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static String _fmtDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  /// Sprint 3.3 — Pre-trade streak warning detector.
  ///
  /// Looks at the most recent N real (non-hypothetical) trades and returns
  /// a [TradeStreak] describing whether the trader is on a hot win streak
  /// (overconfidence risk) or a cold loss streak (revenge-trade risk).
  ///
  /// A streak of length >= 3 is considered actionable.
  static TradeStreak currentStreak(List<Trade> allTrades) {
    final trades = allTrades.where((t) => !t.isHypothetical).toList()
      ..sort((a, b) {
        final d = b.date.compareTo(a.date);
        if (d != 0) return d;
        return b.time.compareTo(a.time);
      });
    if (trades.isEmpty) return const TradeStreak.none();

    // Skip break-even trades (pnl == 0) for streak calc — they're neutral.
    int wins = 0;
    int losses = 0;
    StreakKind? kind;
    for (final t in trades) {
      if (t.pnl > 0) {
        if (kind == null) kind = StreakKind.win;
        if (kind != StreakKind.win) break;
        wins++;
      } else if (t.pnl < 0) {
        if (kind == null) kind = StreakKind.loss;
        if (kind != StreakKind.loss) break;
        losses++;
      } else {
        // break-even — treat as neutral, stop streak walk.
        break;
      }
    }
    final length = kind == StreakKind.win ? wins : losses;
    if (kind == null || length == 0) return const TradeStreak.none();
    return TradeStreak(kind: kind, length: length);
  }
}

enum StreakKind { win, loss }

class TradeStreak {
  const TradeStreak({required this.kind, required this.length});
  const TradeStreak.none() : kind = null, length = 0;

  final StreakKind? kind;
  final int length;

  /// Length >= 3 of either kind → show pre-trade warning.
  bool get shouldWarn => length >= 3;
}
