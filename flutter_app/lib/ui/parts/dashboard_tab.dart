// GENERATED-BY-SPLIT - do not import this file directly.
part of '../trading_screen.dart';

// ═══════════════════════════════════════════════════════════════════════
//  TAB 0: DASHBOARD — the intelligent home screen
// ═══════════════════════════════════════════════════════════════════════

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({required this.controller, required this.onWalkthrough});
  final TradingScreenViewModel controller;
  final Future<void> Function({bool markSeen}) onWalkthrough;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final session = c.getSessionInfo();
    final score = IntelligenceEngine.readinessScore(c);
    final insights = IntelligenceEngine.computeInsights(c);
    final todayTrades = c.getTodayTrades();
    final allRealTrades = c.getRealTradesDesc();
    final challenge = c.getChallengePnl();
    final today = c.getTodayPnl();
    final allPnl = allRealTrades.fold<double>(0, (sum, t) => sum + t.pnl);
    final wins = allRealTrades.where((t) => t.pnl > 0).length;
    final winRate = allRealTrades.isEmpty
        ? 0.0
        : (wins / allRealTrades.length) * 100;
    final balance = c.state.balance + challenge;
    final progress = (challenge / 1250).clamp(0.0, 1.0);
    final streak = IntelligenceEngine.disciplineStreak(c);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        // ── Header row ──
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '4x Trades',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD740), Color(0xFFFFA000)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _eatTime(c.nowEAT),
                    style: TextStyle(
                      color: context.c.textTertiary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => onWalkthrough(),
              icon: Icon(
                Icons.help_outline,
                color: context.c.textTertiary,
                size: 22,
              ),
              tooltip: 'Walkthrough',
            ),
            _ThemeToggleButton(controller: c),
          ],
        ),

        const SizedBox(height: 24),

        // ── Readiness Score ──
        _Card(
          child: Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: _AnimatedNumber(
                  value: score.toDouble(),
                  builder: (ctx, animated) {
                    final shown = animated.round();
                    return CustomPaint(
                      painter: _ScoreRingPainter(
                        shown,
                        IntelligenceEngine.scoreColor(shown),
                        context.c.border,
                      ),
                      child: Center(
                        child: Text(
                          '$shown',
                          style: TextStyle(
                            color: IntelligenceEngine.scoreColor(shown),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Readiness Score',
                      style: TextStyle(
                        color: context.c.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      score >= 80
                          ? 'Conditions are favorable. Execute with discipline.'
                          : score >= 50
                          ? 'Partial readiness. Complete remaining gates.'
                          : 'Not ready. Wait for better conditions.',
                      style: TextStyle(
                        color: context.c.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Key metrics row ──
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: 'Balance',
                value: _compact(balance),
                tone: context.c.text,
                animateNumeric: balance,
                formatNumeric: _compact,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                label: 'Today',
                value: _signed(today),
                tone: today >= 0 ? AppTheme.green : AppTheme.red,
                animateNumeric: today,
                formatNumeric: _signed,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                label: 'Target',
                value: '${(progress * 100).toStringAsFixed(0)}%',
                tone: AppTheme.accent,
                animateNumeric: progress * 100,
                formatNumeric: (v) => '${v.toStringAsFixed(0)}%',
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ── Overall metrics row ──
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: 'All Trades',
                value: '${allRealTrades.length}',
                tone: context.c.text,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                label: 'All-Time',
                value: _signed(allPnl),
                tone: allPnl >= 0 ? AppTheme.green : AppTheme.red,
                animateNumeric: allPnl,
                formatNumeric: _signed,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                label: 'Win Rate',
                value: '${winRate.toStringAsFixed(0)}%',
                tone: AppTheme.accent,
                animateNumeric: winRate,
                formatNumeric: (v) => '${v.toStringAsFixed(0)}%',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Equity preview — last 30 trades cumulative P/L ──
        if (allRealTrades.isNotEmpty)
          _Card(
            tone: allPnl >= 0 ? context.c.positive : context.c.negative,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Equity · last ${math.min(30, allRealTrades.length)} trades',
                      style: TextStyle(
                        color: context.c.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const Spacer(),
                    _Pill(
                      label: '${winRate.toStringAsFixed(0)}% WIN',
                      tone: winRate >= 50
                          ? context.c.positive
                          : context.c.caution,
                      dense: true,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _Sparkline(
                  values: allRealTrades.reversed
                      .toList()
                      .sublist(math.max(0, allRealTrades.length - 30))
                      .map((t) => t.pnl)
                      .toList(),
                  color: allPnl >= 0 ? context.c.positive : context.c.negative,
                  height: 44,
                ),
                const SizedBox(height: 8),
                _WinLossBar(
                  winRate: allRealTrades.isEmpty
                      ? 0
                      : wins / allRealTrades.length,
                  tradeCount: allRealTrades.length,
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),

        // ── Session status ──
        _Card(
          child: Row(
            children: [
              Container(
                width: 8,
                height: 44,
                decoration: BoxDecoration(
                  color: _sessionTone(context, session.type),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.label,
                      style: TextStyle(
                        color: _sessionTone(context, session.type),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Day ${c.getDayNumber()} · ${todayTrades.length}/2 today · ${allRealTrades.length} total',
                      style: TextStyle(
                        color: context.c.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _Pill(
                label: c.state.lock
                    ? 'Locked'
                    : (session.ok ? 'Open' : 'Closed'),
                tone: c.state.lock
                    ? AppTheme.red
                    : (session.ok ? AppTheme.green : context.c.textTertiary),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Discipline streak ──
        _Card(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: streak > 0
                      ? AppTheme.amber.withValues(alpha: 0.15)
                      : context.c.border,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    streak > 0 ? '🔥' : '·',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discipline Streak',
                      style: TextStyle(
                        color: context.c.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      streak == 0
                          ? 'Trade clean tomorrow to start a streak.'
                          : streak == 1
                          ? '1 day respecting the plan. Keep it.'
                          : '$streak days of disciplined trading.',
                      style: TextStyle(
                        color: context.c.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _AnimatedNumber(
                value: streak.toDouble(),
                builder: (ctx, current) => Text(
                  '${current.round()}',
                  style: TextStyle(
                    color: streak > 0 ? AppTheme.amber : context.c.textTertiary,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Smart insights ──
        const _SectionHeader('Insights'),
        ...insights.map(
          (ins) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _Card(
              child: Row(
                children: [
                  Icon(ins.icon, color: ins.tone, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ins.text,
                      style: TextStyle(color: context.c.text, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Quick action ──
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => controller.setActiveTab(1),
            child: const Text('Start Trade Flow →'),
          ),
        ),
      ],
    );
  }
}
