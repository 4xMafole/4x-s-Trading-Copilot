import '../data/models.dart';
import '../services/ai_service.dart';

/// Sprint 5.3 — Local-only AI mode rule-based insights engine.
///
/// Pure-Dart, zero network. Produces an [AiReport] that mirrors the
/// shape returned by the Gemini-backed [AiService.generateEdgeReport]
/// so the UI is fully agnostic.
class LocalInsightsEngine {
  const LocalInsightsEngine();

  AiReport generateEdgeReport(List<Trade> trades) {
    if (trades.isEmpty) {
      return AiReport(
        strengths: const [],
        leaks: const [],
        harshTruth:
            'No trades logged. Local-only mode is on — log a few trades to see rule-based insights.',
      );
    }

    final realized = trades.where((t) => !t.isHypothetical).toList();
    final src = realized.isNotEmpty ? realized : trades;

    final wins = src.where((t) => t.pnl > 0).toList();
    final losses = src.where((t) => t.pnl < 0).toList();
    final winRate = src.isEmpty ? 0.0 : wins.length / src.length;
    final totalPnl = src.fold<double>(0, (s, t) => s + t.pnl);
    final grossWin = wins.fold<double>(0, (s, t) => s + t.pnl);
    final grossLoss = losses.fold<double>(0, (s, t) => s + t.pnl).abs();
    final profitFactor = grossLoss == 0
        ? (grossWin > 0 ? double.infinity : 0.0)
        : grossWin / grossLoss;
    final avgWin = wins.isEmpty ? 0.0 : grossWin / wins.length;
    final avgLoss = losses.isEmpty ? 0.0 : grossLoss / losses.length;

    // ── Symbol leak detection ──
    final pnlBySym = <String, double>{};
    final cntBySym = <String, int>{};
    for (final t in src) {
      pnlBySym[t.sym] = (pnlBySym[t.sym] ?? 0) + t.pnl;
      cntBySym[t.sym] = (cntBySym[t.sym] ?? 0) + 1;
    }
    String? worstSym;
    double worstSymPnl = 0;
    pnlBySym.forEach((sym, pnl) {
      if (pnl < worstSymPnl && (cntBySym[sym] ?? 0) >= 2) {
        worstSym = sym;
        worstSymPnl = pnl;
      }
    });

    // ── Hour-of-day leak detection ──
    final pnlByHour = <int, double>{};
    final cntByHour = <int, int>{};
    for (final t in src) {
      final h = _parseHour(t.time);
      if (h == null) continue;
      pnlByHour[h] = (pnlByHour[h] ?? 0) + t.pnl;
      cntByHour[h] = (cntByHour[h] ?? 0) + 1;
    }
    int? worstHour;
    double worstHourPnl = 0;
    pnlByHour.forEach((h, pnl) {
      if (pnl < worstHourPnl && (cntByHour[h] ?? 0) >= 2) {
        worstHour = h;
        worstHourPnl = pnl;
      }
    });

    // ── Violations ──
    final violationCount = src.where((t) => t.violations.isNotEmpty).length;

    // ── Compose ──
    final strengths = <String>[];
    if (winRate >= 0.55) {
      strengths.add(
        'Win rate ${(winRate * 100).toStringAsFixed(0)}% across ${src.length} trades — above 55%.',
      );
    }
    if (profitFactor.isFinite && profitFactor >= 1.5) {
      strengths.add(
        'Profit factor ${profitFactor.toStringAsFixed(2)} — gross win/loss ratio is healthy.',
      );
    }
    if (avgWin > avgLoss && wins.isNotEmpty && losses.isNotEmpty) {
      strengths.add(
        'Avg win \$${avgWin.toStringAsFixed(2)} > avg loss \$${avgLoss.toStringAsFixed(2)} — risk:reward is on your side.',
      );
    }
    if (strengths.isEmpty) {
      strengths.add('Not enough signal yet — keep logging cleanly.');
    }

    final leaks = <String>[];
    if (worstSym != null) {
      leaks.add(
        '${worstSym!} is bleeding \$${worstSymPnl.toStringAsFixed(2)} across ${cntBySym[worstSym!]} trades. Cut it or fix the setup.',
      );
    }
    if (worstHour != null) {
      leaks.add(
        '${worstHour!.toString().padLeft(2, '0')}:00 EAT hour is net \$${worstHourPnl.toStringAsFixed(2)} over ${cntByHour[worstHour!]} trades — that session is a leak.',
      );
    }
    if (violationCount > 0) {
      leaks.add(
        '$violationCount trade${violationCount == 1 ? '' : 's'} broke your own rules. Discipline is the leak before strategy.',
      );
    }
    if (avgLoss > avgWin && wins.isNotEmpty && losses.isNotEmpty) {
      leaks.add(
        'Avg loss \$${avgLoss.toStringAsFixed(2)} ≥ avg win \$${avgWin.toStringAsFixed(2)} — your R:R is upside-down.',
      );
    }
    if (leaks.isEmpty) {
      leaks.add('No clear mathematical leaks detected in the current sample.');
    }

    final harsh = totalPnl >= 0
        ? 'Net \$${totalPnl.toStringAsFixed(2)} across ${src.length} trades. The math is currently on your side — protect it. Local-only mode: no AI was contacted.'
        : 'Net \$${totalPnl.toStringAsFixed(2)} across ${src.length} trades. The market is telling you something the journal already shows. Fix the leak above before adding size. Local-only mode: no AI was contacted.';

    return AiReport(
      strengths: strengths.take(3).toList(),
      leaks: leaks.take(3).toList(),
      harshTruth: harsh,
    );
  }

  int? _parseHour(String hhmm) {
    if (hhmm.isEmpty) return null;
    final parts = hhmm.split(':');
    if (parts.isEmpty) return null;
    return int.tryParse(parts.first);
  }
}
