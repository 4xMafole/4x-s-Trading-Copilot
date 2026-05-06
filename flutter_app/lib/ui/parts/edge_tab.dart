// GENERATED-BY-SPLIT - do not import this file directly.
part of '../trading_screen.dart';

// ═══════════════════════════════════════════════════════════════════════
//  TAB 3: EDGE MAP
// ═══════════════════════════════════════════════════════════════════════

class _EdgeTab extends StatelessWidget {
  const _EdgeTab({required this.controller});
  final TradingScreenViewModel controller;

  @override
  Widget build(BuildContext context) {
    final trades = controller.state.allTrades;
    final realTrades = controller.getRealTradesDesc();

    final live = _LiveStats.compute(realTrades);
    final theoretical = _LiveStats.compute(
      trades.where((t) => t.isHypothetical).toList(),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text(
          'Edge Map',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          'What actually makes you money',
          style: TextStyle(color: context.c.textSecondary, fontSize: 13),
        ),

        // ── AI Analysis Section ──────────────────────────────
        const SizedBox(height: 24),
        BlocBuilder<AiCoachCubit, AiCoachState>(
          builder: (context, aiState) {
            return aiState.when(
              initial: () => _AiCoachActionCard(controller: controller),
              loading: () => const _Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppTheme.accent),
                        SizedBox(height: 16),
                        Text(
                          'AI is crunching your numbers...',
                          style: TextStyle(color: AppTheme.accent),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              success: (report) =>
                  _AiCoachResultCard(report: report, controller: controller),
              error: (message) => _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Analysis Failed',
                      style: TextStyle(
                        color: AppTheme.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyle(color: context.c.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.c.surfaceRaised,
                      ),
                      onPressed: () => context.read<AiCoachCubit>().reset(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // ── Section: My Personal Edge (Sprint 3.1) ─────────────────
        const SizedBox(height: 24),
        _PersonalEdgeSection(allTrades: trades),

        // ── Section 1: Personal Account Overview ──────────────────
        const SizedBox(height: 24),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal account overview — 572 trades · Jul 2025 – Mar 2026',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 14),
              _statGrid(const [
                _StatBox(
                  label: 'Total trades',
                  value: '572',
                  tone: AppTheme.accent,
                ),
                _StatBox(
                  label: 'Net P&L',
                  value: '+\$301.06',
                  tone: AppTheme.green,
                ),
                _StatBox(
                  label: 'Overall win rate',
                  value: '32.4%',
                  tone: AppTheme.amber,
                ),
                _StatBox(
                  label: 'Avg R:R achieved',
                  value: '2.71',
                  tone: AppTheme.green,
                ),
                _StatBox(
                  label: 'Avg win',
                  value: '+\$38.48',
                  tone: AppTheme.green,
                ),
                _StatBox(
                  label: 'Avg loss',
                  value: '-\$14.19',
                  tone: AppTheme.red,
                ),
              ]),
              const SizedBox(height: 14),
              _AlertBox(
                tone: AppTheme.accent,
                title: 'THE PARADOX',
                body:
                    '32.4% win rate but still net profitable. Your average win (\$38.48) is 2.71× your average loss (\$14.19). The system has positive expectancy — it only needs discipline applied on top.',
              ),
            ],
          ),
        ),

        // ── Section 1b: Live Challenge Stats ──────────────────────
        if (realTrades.isNotEmpty) ...[
          const SizedBox(height: 12),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live challenge — ${live.total} trades',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),
                _statGrid([
                  _StatBox(
                    label: 'Trades',
                    value: '${live.total}',
                    tone: AppTheme.accent,
                  ),
                  _StatBox(
                    label: 'Net P&L',
                    value: _signed(live.netPnl),
                    tone: live.netPnl >= 0 ? AppTheme.green : AppTheme.red,
                  ),
                  _StatBox(
                    label: 'Win rate',
                    value: '${live.winRate.toStringAsFixed(1)}%',
                    tone: live.winRate >= 40 ? AppTheme.green : AppTheme.amber,
                  ),
                  _StatBox(
                    label: 'Avg win',
                    value: live.avgWin > 0
                        ? '+\$${live.avgWin.toStringAsFixed(2)}'
                        : '—',
                    tone: AppTheme.green,
                  ),
                  _StatBox(
                    label: 'Avg loss',
                    value: live.avgLoss < 0
                        ? '\$${live.avgLoss.toStringAsFixed(2)}'
                        : '—',
                    tone: AppTheme.red,
                  ),
                ]),
                // Equity curve preview + win/loss split bar.
                if (realTrades.length >= 2) ...[
                  const SizedBox(height: Spacing.lg),
                  Text(
                    'EQUITY CURVE',
                    style: TextStyle(
                      color: context.c.textTertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  _Sparkline(
                    values: realTrades.map((t) => t.pnl).toList(),
                    color: live.netPnl >= 0
                        ? context.c.positive
                        : context.c.negative,
                    height: 56,
                  ),
                  const SizedBox(height: Spacing.md),
                  _WinLossBar(
                    winRate: live.winRate / 100,
                    tradeCount: live.total,
                  ),
                  const SizedBox(height: Spacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WINS  ${(live.winRate).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: context.c.positive,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        '${(100 - live.winRate).toStringAsFixed(0)}%  LOSSES',
                        style: TextStyle(
                          color: context.c.negative,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ],
                if (live.total >= 5) ...[
                  const SizedBox(height: 14),
                  // Per-symbol breakdown
                  ...live.bySymbol.entries.map((e) {
                    final s = e.value;
                    return _EdgeRow(
                      label: e.key,
                      sub: '${s.total} trades',
                      val: '${s.winRate.toStringAsFixed(1)}% WR',
                      valSub: _signed(s.netPnl),
                      valColor: s.netPnl >= 0 ? AppTheme.green : AppTheme.red,
                      percent: s.winRate,
                    );
                  }),
                ],
              ],
            ),
          ),
        ],

        // ── Section 1c: Theoretical (Hypothetical) Stats ──────────────────────
        if (theoretical.total > 0) ...[
          const SizedBox(height: 12),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hypothetical Backlog — ${theoretical.total} trades',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppTheme.accent),
                ),
                const SizedBox(height: Spacing.sm),
                _statGrid([
                  _StatBox(
                    label: 'Trades',
                    value: '${theoretical.total}',
                    tone: AppTheme.accent,
                  ),
                  _StatBox(
                    label: 'Net P&L',
                    value: _signed(theoretical.netPnl),
                    tone: theoretical.netPnl >= 0
                        ? AppTheme.green
                        : AppTheme.red,
                  ),
                  _StatBox(
                    label: 'Win rate',
                    value: '${theoretical.winRate.toStringAsFixed(1)}%',
                    tone: theoretical.winRate >= 40
                        ? AppTheme.green
                        : AppTheme.amber,
                  ),
                ]),
              ],
            ),
          ),
        ],

        // ── Section 2: Symbol Performance ─────────────────────────
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Symbol performance — where your edge lives',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _sectionLabel(context, 'Your top instruments'),
              const _EdgeRow(
                label: 'XAUUSD',
                sub: '19 trades · Primary instrument',
                val: '47% WR',
                valSub: '+\$406.90',
                valColor: AppTheme.green,
                percent: 47,
              ),
              const _EdgeRow(
                label: 'NQ100',
                sub: '16 trades · Secondary instrument',
                val: '44% WR',
                valSub: '+\$49.10',
                valColor: AppTheme.green,
                percent: 44,
              ),
              const _EdgeRow(
                label: 'EURUSD',
                sub: '40 trades · Conditional only',
                val: '25% WR',
                valSub: '+\$50.70',
                valColor: AppTheme.amber,
                percent: 25,
              ),
              const SizedBox(height: 20),
              _sectionLabel(context, 'Avoid completely'),
              const _EdgeRow(
                label: 'XAGUSD',
                sub: '3 trades',
                val: '0% WR',
                valSub: '-\$179.05',
                valColor: AppTheme.red,
                percent: 0,
              ),
              const _EdgeRow(
                label: 'BTCUSD / ETHUSD',
                sub: '11 trades combined',
                val: '18% WR',
                valSub: '-\$55.56',
                valColor: AppTheme.red,
                percent: 18,
              ),
              const _EdgeRow(
                label: 'GBPUSD',
                sub: '15 trades',
                val: '33% WR',
                valSub: '-\$60.22',
                valColor: AppTheme.red,
                percent: 33,
              ),
            ],
          ),
        ),

        // ── Section 3: Session Timing ─────────────────────────────
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Session timing — your confirmed windows (EAT)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              const _EdgeRow(
                label: '09:00–10:30 EAT — dead zone',
                labelColor: AppTheme.red,
                sub: 'EURUSD: 24 trades, 23 straight losses',
                val: '4.2% WR',
                valSub: '-\$71.17',
                valColor: AppTheme.red,
                active: true,
              ),
              const _EdgeRow(
                label: '10:30–13:00 EAT — mid London',
                sub: 'EU sells valid. Small sample but promising',
                val: '66.7% WR',
                valSub: '+\$15.27',
                valColor: AppTheme.green,
              ),
              const _EdgeRow(
                label: '13:00–15:00 EAT — late London',
                sub: 'All three instruments. Best EU + XAUUSD zone',
                val: 'Prime window',
                valColor: AppTheme.green,
              ),
              const _EdgeRow(
                label: '15:00–16:30 EAT — blackout',
                labelColor: AppTheme.red,
                sub: 'XAUUSD: identical WR inside and outside — coin flip',
                val: '45.5% WR',
                valSub: 'No edge',
                valColor: AppTheme.red,
                active: true,
              ),
              const _EdgeRow(
                label: '16:30–18:30 EAT — NY open',
                sub: 'NQ primary. XAUUSD continuation',
                val: 'Prime window',
                valColor: AppTheme.green,
              ),
              const _EdgeRow(
                label: '20:00+ EAT — NY late',
                labelColor: AppTheme.red,
                sub: 'Thin liquidity, asymmetric losses',
                val: '50% WR',
                valSub: '-\$29.60',
                valColor: AppTheme.red,
                active: true,
              ),
            ],
          ),
        ),

        // ── Section 4: EURUSD Deep Dive ──────────────────────────
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EURUSD deep dive — direction bias confirmed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _BiasCard(
                      title: 'Buying EURUSD',
                      tone: AppTheme.red,
                      trades: '29 trades',
                      wr: '13.8% WR',
                      net: 'Net: -\$6.05',
                      footnote: '25 of 29 buys hit SL',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _BiasCard(
                      title: 'Selling EURUSD',
                      tone: AppTheme.green,
                      trades: '11 trades',
                      wr: '54.5% WR',
                      net: 'Net: +\$56.75',
                      footnote: 'Your real EU edge',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _sectionLabel(context, 'EU day-of-week breakdown'),
              const _EdgeRow(
                label: 'Thursday',
                sub: '9 trades',
                val: '44.4% WR · +\$72.07',
                valColor: AppTheme.green,
                percent: 44,
              ),
              const _EdgeRow(
                label: 'Monday',
                sub: '5 trades',
                val: '20% WR · +\$41.22',
                valColor: AppTheme.green,
                percent: 20,
              ),
              const _EdgeRow(
                label: 'Tuesday',
                sub: '19 trades',
                val: '26.3% WR · +\$20.61',
                valColor: AppTheme.amber,
                percent: 26,
              ),
              const _EdgeRow(
                label: 'Wednesday',
                labelColor: AppTheme.red,
                sub: '5 trades',
                val: '0% WR · -\$44.30',
                valColor: AppTheme.red,
                percent: 0,
                active: true,
              ),
              const _EdgeRow(
                label: 'Friday',
                labelColor: AppTheme.red,
                sub: '2 trades',
                val: '0% WR · -\$38.90',
                valColor: AppTheme.red,
                percent: 0,
                active: true,
              ),
              const SizedBox(height: 14),
              const _AlertBox(
                tone: AppTheme.amber,
                title: 'EU ENTRY RULE — ALL 4 REQUIRED',
                body:
                    'Thursday or Monday · 13:00–16:30 EAT · HTF bearish (sell only) · Single entry only. Missing even one condition = no trade.',
              ),
            ],
          ),
        ),

        // ── Section 5: Stacking vs Single Entry ──────────────────
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stacking vs single entry — the definitive case',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _BiasCard(
                      title: 'Single entry days',
                      tone: AppTheme.green,
                      trades: '',
                      wr: '50% WR',
                      net: '+\$103.61 · 16 days',
                      footnote: 'One entry with conviction — the math works',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _BiasCard(
                      title: 'Stacked days',
                      tone: AppTheme.red,
                      trades: '',
                      wr: '8.3% WR',
                      net: '-\$52.91 · 6 days',
                      footnote:
                          'Re-entering after loss — not finding new setups',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Section 6: Behavioural Flags ─────────────────────────
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Behavioural flags — confirmed patterns',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 14),
              const _AlertBox(
                tone: AppTheme.red,
                title: 'STACKING (CRITICAL)',
                body:
                    'Personal account: 3–56 trades per day. EU stacked days: 8.3% WR. Single entry days: 50% WR. After any losing trade, wait 60 minutes minimum before re-entry on same instrument.',
              ),
              const SizedBox(height: 10),
              const _AlertBox(
                tone: AppTheme.red,
                title: 'EARLY LONDON EXECUTION',
                body:
                    '09:00–10:30 EAT: 23 consecutive EURUSD losses. 4.2% WR. Hard no-trade zone — treat it as a second blackout.',
              ),
              const SizedBox(height: 10),
              const _AlertBox(
                tone: AppTheme.amber,
                title: 'EU BUY BIAS',
                body:
                    '29 buys → 13.8% WR · 11 sells → 54.5% WR. Default to sells until macro structure shifts bullish on H4/Daily.',
              ),
              const SizedBox(height: 10),
              const _AlertBox(
                tone: AppTheme.amber,
                title: 'LOT SIZE INCONSISTENCY',
                body:
                    'Personal account: 0.01 to 1.8 lots with no formula. Use the Calculator tab before every trade — 30 seconds, no exceptions.',
              ),
            ],
          ),
        ),

        // ── Section 7: XAUUSD Blackout Zone ──────────────────────
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'XAUUSD blackout zone — the confirmed verdict',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 14),
              _statGrid(const [
                _StatBox(
                  label: 'WR inside blackout',
                  value: '45.5%',
                  tone: AppTheme.amber,
                ),
                _StatBox(
                  label: 'WR after blackout',
                  value: '45.5%',
                  tone: AppTheme.amber,
                ),
                _StatBox(
                  label: 'Net inside (raw)',
                  value: '+\$259',
                  tone: AppTheme.amber,
                ),
                _StatBox(
                  label: 'Net (remove outlier)',
                  value: '-\$67.19',
                  tone: AppTheme.red,
                ),
              ]),
              const SizedBox(height: 14),
              const _AlertBox(
                tone: AppTheme.red,
                title: 'THE +\$192.60 OUTLIER',
                body:
                    'The entire positive P&L inside the blackout is carried by one trade on Jan 20. Remove it and the window returns -\$67 on 10 trades. That is not an edge — it is lottery trading. The blackout stands.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Edge tab helper widgets ──────────────────────────────────────────

/// Sprint 3.1 — Personal Edge: auto-calibrating performance lens.
///
/// Surfaces the trader's real hot zones / dead zones once they have at
/// least [PersonalEdgeEngine.kMinTrades] real trades. Below that threshold
/// the section explains how many more trades are needed.
class _PersonalEdgeSection extends StatelessWidget {
  const _PersonalEdgeSection({required this.allTrades});
  final List<Trade> allTrades;

  @override
  Widget build(BuildContext context) {
    final ready = PersonalEdgeEngine.isReady(allTrades);
    final realCount = allTrades.where((t) => !t.isHypothetical).length;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph, color: AppTheme.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'My Personal Edge',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (ready)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'AUTO-CALIBRATED',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Computed from your real trades — recalibrates with every entry.',
            style: TextStyle(color: context.c.textTertiary, fontSize: 11),
          ),
          const SizedBox(height: 16),
          if (!ready)
            _PersonalEdgeColdStart(realCount: realCount)
          else
            _PersonalEdgeReady(allTrades: allTrades),
        ],
      ),
    );
  }
}

class _PersonalEdgeColdStart extends StatelessWidget {
  const _PersonalEdgeColdStart({required this.realCount});
  final int realCount;

  @override
  Widget build(BuildContext context) {
    final remaining = PersonalEdgeEngine.kMinTrades - realCount;
    final progress = (realCount / PersonalEdgeEngine.kMinTrades).clamp(
      0.0,
      1.0,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: progress,
            backgroundColor: context.c.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '$realCount / ${PersonalEdgeEngine.kMinTrades} real trades logged.',
          style: TextStyle(color: context.c.text, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          'Personal edge unlocks in $remaining more trade${remaining == 1 ? '' : 's'}. Hardcoded research stays in effect until then.',
          style: TextStyle(color: context.c.textTertiary, fontSize: 12),
        ),
      ],
    );
  }
}

class _PersonalEdgeReady extends StatelessWidget {
  const _PersonalEdgeReady({required this.allTrades});
  final List<Trade> allTrades;

  @override
  Widget build(BuildContext context) {
    final best = PersonalEdgeEngine.bestWindow(allTrades);
    final dead = PersonalEdgeEngine.deadZone(allTrades);
    final instruments = PersonalEdgeEngine.instrumentBuckets(allTrades);
    final dows = PersonalEdgeEngine.dayOfWeekBuckets(allTrades);
    final hours = PersonalEdgeEngine.hourlyBuckets(allTrades);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (best != null)
          _PersonalEdgeCallout(
            tone: AppTheme.green,
            icon: Icons.trending_up,
            title: 'Best window',
            body:
                '${best.label} EAT — ${(best.winRate * 100).round()}% WR over ${best.count} trades, +${best.totalPnl.toStringAsFixed(0)} USD.',
          ),
        if (dead != null) ...[
          const SizedBox(height: 8),
          _PersonalEdgeCallout(
            tone: AppTheme.red,
            icon: Icons.trending_down,
            title: 'Personal dead zone',
            body:
                '${dead.label} EAT — ${dead.losses}L / ${dead.wins}W, ${dead.totalPnl.toStringAsFixed(0)} USD. Skip this window.',
          ),
        ],
        if (best == null && dead == null)
          Text(
            'Performance is balanced across hours so far — no clear hot or dead zone yet.',
            style: TextStyle(color: context.c.textSecondary, fontSize: 12),
          ),
        const SizedBox(height: 16),
        Text(
          'By instrument',
          style: TextStyle(
            color: context.c.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        for (final b in instruments.take(5)) _PersonalEdgeRow(bucket: b),
        const SizedBox(height: 16),
        Text(
          'By day of week',
          style: TextStyle(
            color: context.c.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        for (final b in dows.where((b) => b.count > 0))
          _PersonalEdgeRow(bucket: b),
        const SizedBox(height: 16),
        Text(
          'Hourly heatmap (EAT)',
          style: TextStyle(
            color: context.c.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        _PersonalHourlyHeatmap(buckets: hours),
      ],
    );
  }
}

class _PersonalEdgeCallout extends StatelessWidget {
  const _PersonalEdgeCallout({
    required this.tone,
    required this.icon,
    required this.title,
    required this.body,
  });
  final Color tone;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tone.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: tone, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: tone,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: TextStyle(
                    color: context.c.text,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalEdgeRow extends StatelessWidget {
  const _PersonalEdgeRow({required this.bucket});
  final EdgeBucket bucket;

  @override
  Widget build(BuildContext context) {
    final winPct = (bucket.winRate * 100).round();
    final tone = bucket.totalPnl > 0
        ? AppTheme.green
        : (bucket.totalPnl < 0 ? AppTheme.red : context.c.textSecondary);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              bucket.label,
              style: TextStyle(color: context.c.text, fontSize: 12),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                minHeight: 5,
                value: bucket.winRate,
                backgroundColor: context.c.border,
                valueColor: AlwaysStoppedAnimation<Color>(tone),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            child: Text(
              '$winPct% · ${bucket.count}t · ${bucket.totalPnl >= 0 ? '+' : ''}${bucket.totalPnl.toStringAsFixed(0)}',
              textAlign: TextAlign.right,
              style: TextStyle(color: tone, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalHourlyHeatmap extends StatelessWidget {
  const _PersonalHourlyHeatmap({required this.buckets});
  final List<EdgeBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final max = buckets.fold<double>(
      0,
      (s, b) => b.totalPnl.abs() > s ? b.totalPnl.abs() : s,
    );
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var h = 0; h < buckets.length; h++)
          Container(
            width: 32,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: _toneFor(buckets[h], max).withValues(
                alpha: buckets[h].count == 0
                    ? 0.05
                    : 0.18 +
                          (buckets[h].totalPnl.abs() / (max == 0 ? 1 : max)) *
                              0.55,
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _toneFor(buckets[h], max).withValues(alpha: 0.25),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  h.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: context.c.text,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  buckets[h].count == 0 ? '–' : '${buckets[h].count}',
                  style: TextStyle(color: context.c.textTertiary, fontSize: 9),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _toneFor(EdgeBucket b, double max) {
    if (b.count == 0) return Colors.grey;
    if (b.totalPnl > 0) return AppTheme.green;
    if (b.totalPnl < 0) return AppTheme.red;
    return Colors.grey;
  }
}

Widget _sectionLabel(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: context.c.textTertiary,
      ),
    ),
  );
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.tone,
  });
  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.c.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: context.c.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                letterSpacing: -0.5,
                color: tone,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Arranges stat boxes in a uniform 2-column grid so they fit neatly.
Widget _statGrid(List<Widget> items) {
  const spacing = 8.0;
  final rows = <Widget>[];
  for (var i = 0; i < items.length; i += 2) {
    final left = items[i];
    final right = i + 1 < items.length ? items[i + 1] : const SizedBox.shrink();
    rows.add(
      Padding(
        padding: EdgeInsets.only(bottom: i + 2 < items.length ? spacing : 0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: left),
              const SizedBox(width: spacing),
              Expanded(child: right),
            ],
          ),
        ),
      ),
    );
  }
  return Column(children: rows);
}

class _EdgeRow extends StatelessWidget {
  const _EdgeRow({
    required this.label,
    required this.sub,
    required this.val,
    required this.valColor,
    this.valSub,
    this.percent,
    this.labelColor,
    this.active = false,
  });
  final String label;
  final String sub;
  final String val;
  final String? valSub;
  final Color valColor;
  final double? percent;
  final Color? labelColor;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: active ? 14 : 0),
      decoration: active
          ? BoxDecoration(
              color: AppTheme.red.withValues(alpha: 0.06),
              border: Border(left: BorderSide(color: AppTheme.red, width: 3)),
              borderRadius: BorderRadius.circular(4),
            )
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(color: context.c.border, width: 0.5),
              ),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: labelColor ?? context.c.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(fontSize: 11, color: context.c.textTertiary),
                ),
              ],
            ),
          ),
          if (percent != null) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(1),
                    child: LinearProgressIndicator(
                      value: (percent! / 100).clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: context.c.border,
                      color: valColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                val,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valColor,
                ),
              ),
              if (valSub != null) ...[
                const SizedBox(height: 2),
                Text(
                  valSub!,
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: context.c.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BiasCard extends StatelessWidget {
  const _BiasCard({
    required this.title,
    required this.tone,
    required this.trades,
    required this.wr,
    required this.net,
    required this.footnote,
  });
  final String title;
  final Color tone;
  final String trades;
  final String wr;
  final String net;
  final String footnote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tone.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: tone,
            ),
          ),
          if (trades.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              trades,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: tone.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            wr,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              letterSpacing: -0.5,
              color: tone,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            net,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: tone.withValues(alpha: 0.7),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: tone.withValues(alpha: 0.2)),
              ),
            ),
            child: Text(
              footnote.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: tone.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertBox extends StatelessWidget {
  const _AlertBox({
    required this.tone,
    required this.title,
    required this.body,
  });
  final Color tone;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tone.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: tone,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: context.c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Live stats computed from challenge trades.
class _LiveStats {
  final int total;
  final int wins;
  final double netPnl;
  final double winRate;
  final double avgWin;
  final double avgLoss;
  final Map<String, _SymbolStats> bySymbol;

  _LiveStats({
    required this.total,
    required this.wins,
    required this.netPnl,
    required this.winRate,
    required this.avgWin,
    required this.avgLoss,
    required this.bySymbol,
  });

  factory _LiveStats.compute(List<Trade> trades) {
    if (trades.isEmpty) {
      return _LiveStats(
        total: 0,
        wins: 0,
        netPnl: 0,
        winRate: 0,
        avgWin: 0,
        avgLoss: 0,
        bySymbol: {},
      );
    }

    final wins = trades.where((t) => t.pnl > 0).toList();
    final losses = trades.where((t) => t.pnl < 0).toList();
    final netPnl = trades.fold<double>(0, (s, t) => s + t.pnl);
    final avgWin = wins.isEmpty
        ? 0.0
        : wins.fold<double>(0, (s, t) => s + t.pnl) / wins.length;
    final avgLoss = losses.isEmpty
        ? 0.0
        : losses.fold<double>(0, (s, t) => s + t.pnl) / losses.length;

    final Map<String, List<Trade>> grouped = {};
    for (final t in trades) {
      grouped.putIfAbsent(t.sym, () => []).add(t);
    }
    final bySymbol = grouped.map(
      (sym, list) => MapEntry(sym, _SymbolStats.compute(list)),
    );

    return _LiveStats(
      total: trades.length,
      wins: wins.length,
      netPnl: netPnl,
      winRate: (wins.length / trades.length) * 100,
      avgWin: avgWin,
      avgLoss: avgLoss,
      bySymbol: bySymbol,
    );
  }
}

class _SymbolStats {
  final int total;
  final double winRate;
  final double netPnl;

  _SymbolStats({
    required this.total,
    required this.winRate,
    required this.netPnl,
  });

  factory _SymbolStats.compute(List<Trade> trades) {
    final wins = trades.where((t) => t.pnl > 0).length;
    final net = trades.fold<double>(0, (s, t) => s + t.pnl);
    return _SymbolStats(
      total: trades.length,
      winRate: trades.isEmpty ? 0 : (wins / trades.length) * 100,
      netPnl: net,
    );
  }
}

// ── AI UI Components ──────────────────────────────────────────────────

class _AiCoachActionCard extends StatelessWidget {
  const _AiCoachActionCard({required this.controller});
  final TradingScreenViewModel controller;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppTheme.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Edge Analysis',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppTheme.accent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Generate a brutal, no-nonsense analysis of your actual trading edge using Gemini 3.1 Flash.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent.withValues(alpha: 0.1),
                foregroundColor: AppTheme.accent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                  ),
                ),
              ),
              onPressed: () {
                final trades = controller.state.allTrades;
                context.read<AiCoachCubit>().analyzeEdge(
                  trades,
                  localOnly: controller.localOnlyAiMode,
                );
              },
              child: const Text(
                'Analyze Logged Edge',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: context.c.textSecondary,
                side: BorderSide(color: context.c.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                try {
                  final result = await fp.FilePicker.pickFiles(
                    type: fp.FileType.any,
                  );

                  if (result != null && result.files.single.path != null) {
                    final file = File(result.files.single.path!);
                    final importedTrades = await MT5Parser.parseCsv(file);

                    if (importedTrades.isNotEmpty && context.mounted) {
                      // Analyze imported trades + existing local hypothetical trades (optional), or just imported trades
                      context.read<AiCoachCubit>().analyzeEdge(
                        importedTrades,
                        localOnly: controller.localOnlyAiMode,
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No recognized trades found in file. Ensure it is a valid MT5 export.',
                          ),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error reading file: \$e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text(
                'Upload & Analyze MT5 History',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accent,
                side: const BorderSide(color: AppTheme.accent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _importFromScreenshot(context, controller),
              icon: const Icon(Icons.photo_camera_outlined, size: 18),
              label: const Text(
                'Import from Screenshot',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pick a broker screenshot, run on-device OCR, parse candidate trades
  /// and show a confirm sheet before persisting them to the journal.
  Future<void> _importFromScreenshot(
    BuildContext context,
    TradingScreenViewModel c,
  ) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      if (!context.mounted) return;
      // Show a quick blocking spinner while ML Kit runs.
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final lines = await ScreenshotOcrService.extractLines(File(picked.path));
      final candidates = TradeExtractor.parseLines(lines);

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss spinner

      if (candidates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No trades detected. Try a clearer screenshot of your history page.',
            ),
          ),
        );
        return;
      }

      final eat = c.nowEAT;
      final fallbackDate =
          '${eat.toUtc().year.toString().padLeft(4, '0')}-${eat.toUtc().month.toString().padLeft(2, '0')}-${eat.toUtc().day.toString().padLeft(2, '0')}';
      final fallbackTime =
          '${eat.toUtc().hour.toString().padLeft(2, '0')}:${eat.toUtc().minute.toString().padLeft(2, '0')}';

      await _showConfirmImportSheet(
        context,
        controller: c,
        candidates: candidates,
        fallbackDate: fallbackDate,
        fallbackTime: fallbackTime,
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).maybePop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Screenshot import failed: $e')));
      }
    }
  }

  Future<void> _showConfirmImportSheet(
    BuildContext context, {
    required TradingScreenViewModel controller,
    required List<TradeCandidate> candidates,
    required String fallbackDate,
    required String fallbackTime,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.c.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      color: AppTheme.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Found ${candidates.length} trade${candidates.length == 1 ? '' : 's'}',
                      style: Theme.of(sheetCtx).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Review the extracted trades. Confirm to add them to your journal.',
                  style: TextStyle(
                    color: context.c.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: candidates.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: context.c.border, height: 1),
                    itemBuilder: (_, i) {
                      final t = candidates[i];
                      final positive = t.pnl >= 0;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: t.dir == 'buy'
                              ? AppTheme.green.withValues(alpha: 0.15)
                              : AppTheme.red.withValues(alpha: 0.15),
                          child: Icon(
                            t.dir == 'buy'
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: t.dir == 'buy'
                                ? AppTheme.green
                                : AppTheme.red,
                            size: 14,
                          ),
                        ),
                        title: Text(
                          '${t.sym}  ·  ${t.lots > 0 ? t.lots.toStringAsFixed(2) : '—'} lots',
                          style: TextStyle(
                            color: context.c.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${t.date ?? fallbackDate}  ${t.time ?? fallbackTime}',
                          style: TextStyle(
                            color: context.c.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                        trailing: Text(
                          '${positive ? '+' : ''}\$${t.pnl.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: positive ? AppTheme.green : AppTheme.red,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetCtx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.c.textSecondary,
                          side: BorderSide(color: context.c.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final trades = TradeExtractor.toTrades(
                            candidates,
                            fallbackDate: fallbackDate,
                            fallbackTime: fallbackTime,
                          );
                          final added = await controller.addTradesBatch(trades);
                          if (sheetCtx.mounted) {
                            Navigator.pop(sheetCtx);
                            ScaffoldMessenger.of(sheetCtx).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Imported $added trade${added == 1 ? '' : 's'} from screenshot.',
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Confirm import'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AiCoachResultCard extends StatelessWidget {
  const _AiCoachResultCard({required this.report, required this.controller});
  final AiReport report;
  final TradingScreenViewModel controller;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppTheme.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Edge Report',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: AppTheme.accent),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => context.read<AiCoachCubit>().reset(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Strengths
          if (report.strengths.isNotEmpty) ...[
            Text(
              'WHAT WORKS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: AppTheme.green.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            ...report.strengths.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '+',
                      style: TextStyle(
                        color: AppTheme.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(s, style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Leaks
          if (report.leaks.isNotEmpty) ...[
            Text(
              'PROFIT LEAKS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: AppTheme.red.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            ...report.leaks.map(
              (l) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '—',
                      style: TextStyle(
                        color: AppTheme.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(l, style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Harsh Truth
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
              border: Border(
                left: BorderSide(color: AppTheme.accent, width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'THE HARSH TRUTH',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  report.harshTruth,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
