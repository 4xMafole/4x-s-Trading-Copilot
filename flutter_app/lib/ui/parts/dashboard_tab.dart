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
                      'Day ${c.getDayNumber()} · ${todayTrades.length}/${c.dailyTradeCap} today · ${allRealTrades.length} total',
                      style: TextStyle(
                        color: context.c.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    if (c.accounts.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: _AccountSwitcherChip(controller: c),
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

        // ── Weekly digest banner (Sprint 3.2) ──
        _WeeklyDigestBanner(controller: c),

        // ── High-impact news banner (Sprint 4.4) ──
        const _NewsImpactBanner(),

        // ── Distance from Bust (Sprint 4.1) ──
        _DistanceFromBustCard(controller: c),

        // ── Weekly R-budget meter (Sprint 4.2) ──
        _WeeklyRiskBudgetCard(controller: c),

        // ── Self-comparison: this month vs last (Sprint 6.2) ──
        _SelfComparisonCard(controller: c),

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

/// Sprint 3.2 — Sunday digest banner. Renders only when an unseen
/// digest exists. "Got it" marks it as seen so the banner stops showing.
class _WeeklyDigestBanner extends StatefulWidget {
  const _WeeklyDigestBanner({required this.controller});
  final TradingScreenViewModel controller;

  @override
  State<_WeeklyDigestBanner> createState() => _WeeklyDigestBannerState();
}

class _WeeklyDigestBannerState extends State<_WeeklyDigestBanner> {
  @override
  Widget build(BuildContext context) {
    final digest = widget.controller.latestUnseenDigest();
    if (digest == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekly Digest · ${digest.weekId}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DigestLine(label: 'WIN', body: digest.win, tone: Colors.green),
            const SizedBox(height: 8),
            _DigestLine(
              label: 'WORST HABIT',
              body: digest.worstHabit,
              tone: Colors.redAccent,
            ),
            const SizedBox(height: 8),
            _DigestLine(
              label: 'ONE FIX',
              body: digest.oneFix,
              tone: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await widget.controller.markLatestDigestSeen();
                  if (mounted) setState(() {});
                },
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DigestLine extends StatelessWidget {
  const _DigestLine({
    required this.label,
    required this.body,
    required this.tone,
  });
  final String label;
  final String body;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: TextStyle(
              color: tone,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Expanded(
          child: Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

/// Sprint 4.1 — "Distance from Bust" card. Visualises how close the trader
/// is to busting their daily and trailing drawdown limits. Hidden when
/// prop-firm rules are not enabled.
class _DistanceFromBustCard extends StatelessWidget {
  const _DistanceFromBustCard({required this.controller});
  final TradingScreenViewModel controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final rules = c.propFirmRules;
    if (!rules.enabled ||
        (rules.maxDailyDrawdown <= 0 && rules.maxTotalDrawdown <= 0)) {
      return const SizedBox.shrink();
    }

    final trades = c.state.allTrades;
    final daily = DrawdownEngine.dailyDrawdown(trades, c.nowEAT);
    final weekly = DrawdownEngine.weeklyDrawdown(trades, c.nowEAT);
    final trailing = DrawdownEngine.currentTrailingDrawdown(
      startBalance: c.state.balance,
      priorPnl: c.state.priorPnl,
      allTrades: trades,
    );

    final dailyConsumed = DrawdownEngine.dailyConsumed(
      daily,
      rules.maxDailyDrawdown,
    );
    final totalConsumed = DrawdownEngine.totalConsumed(
      trailing,
      rules.maxTotalDrawdown,
    );
    final worstConsumed = math.max(dailyConsumed, totalConsumed);
    final tone = toneFor(worstConsumed);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield_outlined, color: _toneColor(tone), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Distance from Bust',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (rules.firmName.isNotEmpty)
                  Text(
                    rules.firmName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (rules.maxDailyDrawdown > 0) ...[
              _DdRow(
                label: 'Today',
                used: daily,
                limit: rules.maxDailyDrawdown,
                consumed: dailyConsumed,
              ),
              const SizedBox(height: 12),
            ],
            if (rules.maxTotalDrawdown > 0) ...[
              _DdRow(
                label: 'Trailing',
                used: trailing,
                limit: rules.maxTotalDrawdown,
                consumed: totalConsumed,
              ),
              const SizedBox(height: 12),
            ],
            _DdRow(
              label: 'This week',
              used: weekly,
              limit: 0, // informational only
              consumed: 0,
              showBar: false,
            ),
            if (worstConsumed >= 0.7) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.4),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '70%+ of your firm limit consumed. Stop trading or '
                        'switch to paper-only for the rest of the period.',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _toneColor(DrawdownTone t) {
    switch (t) {
      case DrawdownTone.safe:
        return Colors.green;
      case DrawdownTone.caution:
        return Colors.amber.shade700;
      case DrawdownTone.danger:
        return Colors.redAccent;
    }
  }
}

class _DdRow extends StatelessWidget {
  const _DdRow({
    required this.label,
    required this.used,
    required this.limit,
    required this.consumed,
    this.showBar = true,
  });
  final String label;
  final double used;
  final double limit;
  final double consumed;
  final bool showBar;

  @override
  Widget build(BuildContext context) {
    final tone = toneFor(consumed);
    final color = switch (tone) {
      DrawdownTone.safe => Colors.green,
      DrawdownTone.caution => Colors.amber.shade700,
      DrawdownTone.danger => Colors.redAccent,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Text(
              limit > 0
                  ? '\$${used.toStringAsFixed(0)} / \$${limit.toStringAsFixed(0)}'
                  : '\$${used.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: showBar ? color : null,
              ),
            ),
          ],
        ),
        if (showBar) ...[
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: consumed,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ],
    );
  }
}

/// Sprint 4.2 — Weekly R-budget meter. Visualises how much of the trader's
/// weekly risk budget has been consumed by realized losses (real trades
/// only). At 80% the card turns amber with a warning; at 100% it turns
/// red and announces paper-only enforcement.
class _WeeklyRiskBudgetCard extends StatelessWidget {
  const _WeeklyRiskBudgetCard({required this.controller});
  final TradingScreenViewModel controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final b = c.weeklyRiskBudget;
    if (!b.enabled || b.weeklyBudgetR <= 0 || b.rUnitUsd <= 0) {
      return const SizedBox.shrink();
    }

    final lossUsd = RiskBudgetEngine.weeklyLossUsd(c.state.allTrades, c.nowEAT);
    final usedR = RiskBudgetEngine.consumedR(lossUsd, b);
    final fraction = RiskBudgetEngine.consumedFraction(lossUsd, b);
    final exhausted = RiskBudgetEngine.isExhausted(lossUsd, b);
    final warning = RiskBudgetEngine.isWarning(lossUsd, b);
    final color = exhausted
        ? Colors.redAccent
        : warning
        ? Colors.amber.shade700
        : Colors.green;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Weekly R-Budget',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${usedR.toStringAsFixed(1)}R / ${b.weeklyBudgetR.toStringAsFixed(0)}R',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 10,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${lossUsd.toStringAsFixed(0)} lost this week · 1R = \$${b.rUnitUsd.toStringAsFixed(0)}',
              style: TextStyle(color: context.c.textSecondary, fontSize: 12),
            ),
            if (exhausted) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.4),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline, color: Colors.redAccent, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Weekly budget exhausted. New trades will be logged as '
                        'paper-only until next Monday.',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (warning) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade800,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '80%+ of budget consumed. One more loss likely ends '
                        'your week. Trade only A+ setups.',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Sprint 4.4 � High-impact news banner. Fetches Forex Factory's free
/// "this week" feed once per session, then shows a red banner when a
/// high-impact event is within �60 minutes.
class _NewsImpactBanner extends StatefulWidget {
  const _NewsImpactBanner();

  @override
  State<_NewsImpactBanner> createState() => _NewsImpactBannerState();
}

class _NewsImpactBannerState extends State<_NewsImpactBanner> {
  static final EconomicCalendarService _service = EconomicCalendarService();
  static String? _lastNotifiedKey;
  List<EconomicEvent> _events = const <EconomicEvent>[];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final events = await _service.getHighImpactEvents();
    if (!mounted) return;
    setState(() {
      _events = events;
      _loaded = true;
    });
    _maybeFireImminentNotification(events);
  }

  void _maybeFireImminentNotification(List<EconomicEvent> events) {
    try {
      final now = DateTime.now();
      final imminent = EconomicCalendarService.imminentEvent(events, now);
      if (imminent == null) return;
      final state = context.read<TradingCoreCubit>().state.appState;
      final prefs = state.notificationPrefs;
      if (!prefs.master || !prefs.newsImminent) return;
      final key =
          '${imminent.country}|${imminent.title}|${imminent.timeUtc.toIso8601String()}';
      if (_lastNotifiedKey == key) return;
      _lastNotifiedKey = key;
      final mins = imminent.minutesFrom(now);
      final whenLabel = mins >= 0 ? 'in ${mins}m' : '${mins.abs()}m ago';
      unawaited(
        NotificationCenter.instance.showNewsAlert(
          'High-impact news $whenLabel',
          '${imminent.country} · ${imminent.title}',
        ),
      );
    } catch (_) {
      /* best-effort */
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    final now = DateTime.now();
    final imminent = EconomicCalendarService.imminentEvent(_events, now);
    if (imminent == null) return const SizedBox.shrink();

    final minutes = imminent.minutesFrom(now);
    final whenLabel = minutes >= 0 ? 'in ${minutes}m' : '${minutes.abs()}m ago';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.campaign, color: Colors.redAccent, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'High-impact news $whenLabel',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${imminent.country} · ${imminent.title}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Volatility spike likely. Skip new entries until print + 5 min.',
                    style: TextStyle(
                      color: context.c.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sprint 6.2 — Self-Comparison Widget.
/// Shows discipline + win-rate + P/L for the current calendar month
/// versus the previous one. Discipline = % of trades with zero
/// violations. Hidden until at least one trade exists in either month.
class _SelfComparisonCard extends StatelessWidget {
  const _SelfComparisonCard({required this.controller});
  final TradingScreenViewModel controller;

  ({int year, int month}) _shiftMonth(int year, int month, int delta) {
    final m0 = month - 1 + delta;
    final yShift = m0 >= 0 ? m0 ~/ 12 : ((m0 - 11) ~/ 12);
    final mNorm = ((m0 % 12) + 12) % 12;
    return (year: year + yShift, month: mNorm + 1);
  }

  String _label(int year, int month) {
    const names = [
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
    return '${names[month - 1]} $year';
  }

  _MonthSummary _summarize(List<Trade> trades, int year, int month) {
    final prefix = '$year-${month.toString().padLeft(2, '0')}-';
    final inMonth = trades.where((t) => t.date.startsWith(prefix)).toList();
    final clean = inMonth.where((t) => t.violations.isEmpty).length;
    final wins = inMonth.where((t) => t.pnl > 0).length;
    final pnl = inMonth.fold<double>(0, (s, t) => s + t.pnl);
    return _MonthSummary(
      count: inMonth.length,
      discipline: inMonth.isEmpty ? 0 : clean / inMonth.length,
      winRate: inMonth.isEmpty ? 0 : wins / inMonth.length,
      pnl: pnl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final trades = controller.state.allTrades;
    final cur = _summarize(trades, now.year, now.month);
    final prevYm = _shiftMonth(now.year, now.month, -1);
    final prev = _summarize(trades, prevYm.year, prevYm.month);

    if (cur.count == 0 && prev.count == 0) {
      return const SizedBox.shrink();
    }

    final delta = cur.discipline - prev.discipline;
    final improving = delta > 0.001;
    final tone = improving
        ? AppTheme.green
        : delta < -0.001
        ? AppTheme.red
        : context.c.textSecondary;
    final headline = prev.count == 0
        ? 'First month logged — keep it clean.'
        : cur.count == 0
        ? 'No trades yet this month. Start strong.'
        : improving
        ? 'You\'re more disciplined this month — keep going.'
        : delta < -0.001
        ? 'Discipline slipping vs last month.'
        : 'Holding steady vs last month.';

    Widget rowFor(String label, _MonthSummary s) {
      return Row(
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: TextStyle(
                color: context.c.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: s.discipline.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: context.c.border,
                valueColor: AlwaysStoppedAnimation(
                  s.count == 0 ? context.c.textTertiary : AppTheme.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 44,
            child: Text(
              s.count == 0 ? '—' : '${(s.discipline * 100).round()}%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  improving
                      ? Icons.trending_up
                      : delta < -0.001
                      ? Icons.trending_down
                      : Icons.trending_flat,
                  size: 18,
                  color: tone,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You vs You',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (prev.count > 0 && cur.count > 0)
                  Text(
                    '${delta >= 0 ? '+' : ''}${(delta * 100).toStringAsFixed(0)} pts',
                    style: TextStyle(
                      color: tone,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              headline,
              style: TextStyle(color: context.c.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            rowFor(_label(now.year, now.month), cur),
            const SizedBox(height: 8),
            rowFor(_label(prevYm.year, prevYm.month), prev),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Trades',
                    value: '${cur.count}',
                    sub: 'prev ${prev.count}',
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    label: 'Win rate',
                    value: cur.count == 0
                        ? '—'
                        : '${(cur.winRate * 100).round()}%',
                    sub: prev.count == 0
                        ? 'prev —'
                        : 'prev ${(prev.winRate * 100).round()}%',
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    label: 'Net P/L',
                    value: cur.count == 0
                        ? '—'
                        : '\$${cur.pnl.toStringAsFixed(0)}',
                    sub: prev.count == 0
                        ? 'prev —'
                        : 'prev \$${prev.pnl.toStringAsFixed(0)}',
                    valueColor: cur.count == 0
                        ? null
                        : (cur.pnl >= 0 ? AppTheme.green : AppTheme.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthSummary {
  const _MonthSummary({
    required this.count,
    required this.discipline,
    required this.winRate,
    required this.pnl,
  });
  final int count;
  final double discipline;
  final double winRate;
  final double pnl;
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.sub,
    this.valueColor,
  });
  final String label;
  final String value;
  final String sub;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: context.c.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          style: TextStyle(fontSize: 10, color: context.c.textTertiary),
        ),
      ],
    );
  }
}

/// Sprint 6.5 — Compact account switcher shown in the dashboard header
/// when the user has more than one account. Tap → bottom-sheet picker.
class _AccountSwitcherChip extends StatelessWidget {
  const _AccountSwitcherChip({required this.controller});
  final TradingScreenViewModel controller;

  Future<void> _showPicker(BuildContext context) async {
    final accounts = controller.accounts;
    final activeId = controller.activeAccountId;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: context.c.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Switch account',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...accounts.map((a) {
                final selected = a.id == activeId;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected ? AppTheme.accent : null,
                  ),
                  title: Text(
                    a.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '\$${a.balance.toStringAsFixed(0)} · '
                    '${a.allTrades.length} trade${a.allTrades.length == 1 ? '' : 's'}'
                    '${a.lock ? ' · locked' : ''}',
                  ),
                  onTap: selected ? null : () => Navigator.pop(ctx, a.id),
                );
              }),
            ],
          ),
        ),
      ),
    );
    if (picked != null) {
      await controller.switchAccount(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = controller.activeAccount;
    if (active == null) return const SizedBox.shrink();
    return InkWell(
      onTap: () => _showPicker(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: context.c.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 12,
              color: context.c.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              active.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.c.textSecondary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 14,
              color: context.c.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
