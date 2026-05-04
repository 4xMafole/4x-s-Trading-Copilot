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
    final passedCount = kGates.where((g) {
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

    if (trades.length >= 2) {
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

    if (passedCount < kGates.length && session.ok) {
      final remaining = kGates.length - passedCount;
      insights.add(
        Insight(
          Icons.checklist,
          '$remaining gate${remaining == 1 ? '' : 's'} still pending before entry.',
          AppTheme.accent,
        ),
      );
    } else if (passedCount == kGates.length &&
        session.ok &&
        trades.length < 2) {
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

    return insights;
  }

  /// Composite readiness score (0-100) based on session window, gate pass
  /// rate, lock state and remaining trade slots.
  static int readinessScore(TradingScreenViewModel c) {
    int score = 0;
    final session = c.getSessionInfo();
    final auto = c.computeAutoGates();
    final total = kGates.length;
    final passed = kGates.where((g) {
      if (g.auto) return auto[g.id] ?? false;
      return c.state.checks[g.id] ?? false;
    }).length;

    if (session.ok) score += 30;
    score += ((passed / total) * 50).round();
    if (!c.state.lock) score += 10;
    if (c.getTodayTrades().length < 2) score += 10;
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
}
