// GENERATED-BY-SPLIT - do not import this file directly.
part of '../trading_screen.dart';

// ═══════════════════════════════════════════════════════════════════════
//  TAB 1: TRADE FLOW — Plan → Size → Execute
// ═══════════════════════════════════════════════════════════════════════

class _TradeFlowTab extends StatefulWidget {
  const _TradeFlowTab({required this.controller});
  final TradingScreenViewModel controller;

  @override
  State<_TradeFlowTab> createState() => _TradeFlowTabState();
}

class _TradeFlowTabState extends State<_TradeFlowTab> {
  int step = 0;
  String instrument = 'XAUUSD';
  final slCtrl = TextEditingController(text: '7');
  final entriesCtrl = TextEditingController(text: '1');

  @override
  void dispose() {
    slCtrl.dispose();
    entriesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final autoChecks = c.computeAutoGates();
    final passedCount = kGates.where((g) {
      if (g.auto) return autoChecks[g.id] ?? false;
      return c.state.checks[g.id] ?? false;
    }).length;

    final stopLoss = double.tryParse(slCtrl.text) ?? 0;
    final entries = int.tryParse(entriesCtrl.text) ?? 1;
    final meta = kInstruments[instrument]!;
    var lot = 0.0;
    if (stopLoss > 0 && meta.pipVal > 0 && entries > 0) {
      lot = (125 / entries) / (stopLoss * meta.pipVal * 10);
    }
    final risk = (lot * entries * stopLoss * meta.pipVal * 10)
        .clamp(0, 125)
        .toDouble();

    final stepLabels = ['Plan', 'Size', 'Execute'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        // ── Title ──
        Text(
          'Trade Flow',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          'Step ${step + 1} of 3 — ${stepLabels[step]}',
          style: TextStyle(color: context.c.textSecondary, fontSize: 13),
        ),

        const SizedBox(height: 20),

        // ── Step indicator ──
        Row(
          children: List.generate(3, (i) {
            final done = i < step;
            final active = i == step;
            final tone = done
                ? AppTheme.green
                : (active ? AppTheme.accent : context.c.textTertiary);
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => step = i),
                child: Column(
                  children: [
                    Container(
                      height: 3,
                      margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: done || active ? tone : context.c.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stepLabels[i],
                      style: TextStyle(
                        color: tone,
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 20),

        // ── Step content ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: switch (step) {
            0 => _PlanStep(
              key: const ValueKey('plan'),
              controller: c,
              autoChecks: autoChecks,
              passedCount: passedCount,
            ),
            1 => _SizeStep(
              key: const ValueKey('size'),
              instrument: instrument,
              slCtrl: slCtrl,
              entriesCtrl: entriesCtrl,
              lot: lot,
              risk: risk,
              onInstrumentChange: (v) => setState(() => instrument = v),
              onInputChange: () => setState(() {}),
            ),
            _ => _ExecuteStep(
              key: const ValueKey('exec'),
              controller: c,
              lot: lot,
              risk: risk,
            ),
          },
        ),

        const SizedBox(height: 20),

        // ── Navigation ──
        Row(
          children: [
            if (step > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => step--),
                  child: const Text('Back'),
                ),
              ),
            if (step > 0) const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  // Gate enforcement: if blocked, vibrate and show why.
                  String? blocker;
                  if (step == 0 && passedCount < kGates.length) {
                    final remaining = kGates.length - passedCount;
                    blocker =
                        '$remaining gate${remaining == 1 ? '' : 's'} still pending. Complete the checklist before sizing.';
                  } else if (step == 1 && risk > 125) {
                    blocker =
                        'Risk above 125 USD cap. Reduce SL or entries.';
                  } else if (step == 2) {
                    final session = c.getSessionInfo();
                    final tradesToday = c.getTodayTrades().length;
                    if (c.state.lock) {
                      blocker = 'Account locked. No execution allowed.';
                    } else if (!session.ok) {
                      blocker =
                          'Outside execution window: ${session.detail}';
                    } else if (tradesToday >= 2) {
                      blocker =
                          'Daily trade cap reached. Stop and review.';
                    }
                  }

                  if (blocker != null) {
                    HapticFeedback.heavyImpact();
                    Future.delayed(
                      const Duration(milliseconds: 90),
                      HapticFeedback.heavyImpact,
                    );
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.red,
                          content: Row(
                            children: [
                              const Icon(
                                Icons.block,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  blocker,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    return;
                  }

                  HapticFeedback.lightImpact();
                  if (step < 2) {
                    setState(() => step++);
                  } else {
                    c.setActiveTab(2);
                  }
                },
                child: Text(step < 2 ? 'Continue' : 'Log Trade →'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlanStep extends StatelessWidget {
  const _PlanStep({
    super.key,
    required this.controller,
    required this.autoChecks,
    required this.passedCount,
  });
  final TradingScreenViewModel controller;
  final Map<String, bool> autoChecks;
  final int passedCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  value: passedCount / kGates.length,
                  backgroundColor: context.c.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.green,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$passedCount/${kGates.length}',
              style: TextStyle(color: context.c.textSecondary, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Gates list
        ...kGates.map((gate) {
          final passed = gate.auto
              ? (autoChecks[gate.id] ?? false)
              : (controller.state.checks[gate.id] ?? false);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _Card(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: gate.auto
                        ? Icon(
                            passed ? Icons.check_circle : Icons.cancel_outlined,
                            size: 20,
                            color: passed ? AppTheme.green : AppTheme.red,
                          )
                        : Checkbox(
                            value: passed,
                            onChanged: (_) => controller.toggleCheck(gate.id),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gate.label,
                          style: TextStyle(
                            color: passed
                                ? context.c.text
                                : context.c.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          gate.sub,
                          style: TextStyle(
                            color: context.c.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (gate.auto)
                    _Pill(
                      label: passed ? 'Auto ✓' : 'Blocked',
                      tone: passed ? AppTheme.green : AppTheme.red,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _SizeStep extends StatelessWidget {
  const _SizeStep({
    super.key,
    required this.instrument,
    required this.slCtrl,
    required this.entriesCtrl,
    required this.lot,
    required this.risk,
    required this.onInstrumentChange,
    required this.onInputChange,
  });
  final String instrument;
  final TextEditingController slCtrl;
  final TextEditingController entriesCtrl;
  final double lot;
  final double risk;
  final ValueChanged<String> onInstrumentChange;
  final VoidCallback onInputChange;

  @override
  Widget build(BuildContext context) {
    final meta = kInstruments[instrument]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Metrics
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: 'Lot/entry',
                value: lot.toStringAsFixed(2),
                tone: AppTheme.accent,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                label: 'Risk',
                value: '\$${risk.toStringAsFixed(0)}',
                tone: risk <= 125 ? AppTheme.green : AppTheme.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                label: 'Min TP',
                value: ((double.tryParse(slCtrl.text) ?? 0) * 2)
                    .toStringAsFixed(1),
                tone: AppTheme.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Instrument chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kInstruments.keys.map((k) {
            return ChoiceChip(
              label: Text(k == 'NQ' ? 'NQ100' : k),
              selected: instrument == k,
              onSelected: (_) => onInstrumentChange(k),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: slCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Stop loss (${meta.unit})',
            helperText: meta.desc,
          ),
          onChanged: (_) => onInputChange(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: entriesCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Stacked entries'),
          onChanged: (_) => onInputChange(),
        ),
      ],
    );
  }
}

class _ExecuteStep extends StatelessWidget {
  const _ExecuteStep({
    super.key,
    required this.controller,
    required this.lot,
    required this.risk,
  });
  final TradingScreenViewModel controller;
  final double lot;
  final double risk;

  @override
  Widget build(BuildContext context) {
    final trades = controller.getTodayTrades().length;
    final locked = controller.state.lock || trades >= 2;
    final session = controller.getSessionInfo();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Execution Check',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _StatusRow(
            'Session',
            session.ok ? 'Open' : 'Closed',
            session.ok ? AppTheme.green : AppTheme.red,
          ),
          _StatusRow(
            'Trades',
            '$trades / 2',
            trades < 2 ? AppTheme.green : AppTheme.amber,
          ),
          _StatusRow(
            'Lot size',
            '${lot.toStringAsFixed(2)} lots',
            AppTheme.accent,
          ),
          _StatusRow(
            'Risk',
            '\$${risk.toStringAsFixed(0)}',
            risk <= 125 ? AppTheme.green : AppTheme.red,
          ),
          _StatusRow(
            'System',
            locked ? 'Locked' : 'Ready',
            locked ? AppTheme.red : AppTheme.green,
          ),
          const SizedBox(height: 12),
          Text(
            locked
                ? 'Execution blocked. Review journal and wait for next window.'
                : 'Ready to execute. Log the trade in Journal immediately after entry.',
            style: TextStyle(color: context.c.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
