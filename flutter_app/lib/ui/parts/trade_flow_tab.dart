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
  late int step;
  late String instrument;
  late TextEditingController slCtrl;
  late TextEditingController entriesCtrl;
  late TextEditingController tpCtrl;
  String? planImagePath;

  final ImagePicker _imagePicker = ImagePicker();
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    final draft = widget.controller.wizardDraft;
    step = draft?.step ?? 0;
    instrument = draft?.instrument ?? 'XAUUSD';
    slCtrl = TextEditingController(text: draft?.stopLoss ?? '7');
    entriesCtrl = TextEditingController(text: draft?.entries ?? '1');
    tpCtrl = TextEditingController(text: draft?.takeProfit ?? '');
    planImagePath = draft?.planImagePath;
  }

  @override
  void dispose() {
    slCtrl.dispose();
    entriesCtrl.dispose();
    tpCtrl.dispose();
    super.dispose();
  }

  /// Persist the current wizard inputs back to the cubit so the user can
  /// leave the tab and return without losing state.
  void _persistDraft() {
    final draft = WizardDraft(
      step: step,
      instrument: instrument,
      stopLoss: slCtrl.text,
      entries: entriesCtrl.text,
      takeProfit: tpCtrl.text.isEmpty ? null : tpCtrl.text,
      planImagePath: planImagePath,
    );
    // Fire-and-forget; persistence errors are non-fatal here.
    widget.controller.updateWizardDraft(draft);
  }

  Future<void> _pickPlanImage() async {
    try {
      final img = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 85,
      );
      if (img == null || img.path.isEmpty) return;
      // Copy into app docs so the path survives app restarts.
      final source = File(img.path);
      if (!await source.exists()) return;
      final docsDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory(
        '${docsDir.path}${Platform.pathSeparator}plan_images',
      );
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      final stamp = DateTime.now().microsecondsSinceEpoch;
      final ext = img.path.substring(img.path.lastIndexOf('.'));
      final cleanExt = ext.length > 8 ? '.jpg' : ext;
      final target = File(
        '${imageDir.path}${Platform.pathSeparator}plan_$stamp$cleanExt',
      );
      await source.copy(target.path);
      if (!mounted) return;
      setState(() => planImagePath = target.path);
      _persistDraft();
    } catch (_) {
      // Silent fail — picker errors are surfaced to the user via the
      // empty state of the attachment button.
    }
  }

  void _clearPlanImage() {
    setState(() => planImagePath = null);
    _persistDraft();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final autoChecks = c.computeAutoGates();

    // Symbol-scoped gates: only show gates that apply to the current
    // instrument. The user's deep-dive symbol (e.g. EURUSD) will only
    // see its relevant blackout windows / behavioural rules.
    final activeGates = kGates
        .where((g) => g.appliesTo(instrument))
        .toList(growable: false);
    final passedCount = activeGates.where((g) {
      if (g.auto) return autoChecks[g.id] ?? false;
      return c.state.checks[g.id] ?? false;
    }).length;

    final stopLoss = double.tryParse(slCtrl.text) ?? 0;
    final entries = int.tryParse(entriesCtrl.text) ?? 1;
    final takeProfit = double.tryParse(tpCtrl.text) ?? 0;
    final meta = kInstruments[instrument]!;
    final cap = c.riskCapUsd;
    var lot = 0.0;
    if (stopLoss > 0 && meta.pipVal > 0 && entries > 0) {
      lot = (cap / entries) / (stopLoss * meta.pipVal * 10);
    }
    final risk = (lot * entries * stopLoss * meta.pipVal * 10)
        .clamp(0, cap)
        .toDouble();

    final stepLabels = ['Plan', 'Size', 'Execute'];
    final dailyCap = c.dailyTradeCap;

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
                onTap: () {
                  setState(() => step = i);
                  _persistDraft();
                },
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
              activeGates: activeGates,
              instrument: instrument,
              planImagePath: planImagePath,
              onPickPlanImage: _pickPlanImage,
              onClearPlanImage: _clearPlanImage,
            ),
            1 => _SizeStep(
              key: const ValueKey('size'),
              instrument: instrument,
              slCtrl: slCtrl,
              entriesCtrl: entriesCtrl,
              tpCtrl: tpCtrl,
              lot: lot,
              risk: risk,
              riskCap: cap,
              takeProfit: takeProfit,
              onInstrumentChange: (v) {
                setState(() => instrument = v);
                _persistDraft();
              },
              onInputChange: () {
                setState(() {});
                _persistDraft();
              },
            ),
            _ => _ExecuteStep(
              key: const ValueKey('exec'),
              controller: c,
              lot: lot,
              risk: risk,
              dailyCap: dailyCap,
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
                  onPressed: () {
                    setState(() => step--);
                    _persistDraft();
                  },
                  child: const Text('Back'),
                ),
              ),
            if (step > 0) const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  // Gate enforcement: if blocked, vibrate and show why.
                  String? blocker;
                  final rrOk = takeProfit <= 0 || takeProfit >= stopLoss * 2;
                  if (step == 0 && passedCount < activeGates.length) {
                    final remaining = activeGates.length - passedCount;
                    blocker =
                        '$remaining gate${remaining == 1 ? '' : 's'} still pending. Complete the checklist before sizing.';
                  } else if (step == 1 && risk > cap) {
                    blocker =
                        'Risk above ${cap.toStringAsFixed(0)} USD cap. Reduce SL or entries.';
                  } else if (step == 1 && takeProfit > 0 && !rrOk) {
                    blocker =
                        'TP must be ≥ 2× SL (${(stopLoss * 2).toStringAsFixed(1)}). Adjust your target.';
                  } else if (step == 2) {
                    final session = c.getSessionInfo();
                    final tradesToday = c.getTodayTrades().length;
                    if (c.state.lock) {
                      blocker = 'Account locked. No execution allowed.';
                    } else if (!session.ok) {
                      blocker = 'Outside execution window: ${session.detail}';
                    } else if (tradesToday >= dailyCap) {
                      blocker = 'Daily trade cap reached. Stop and review.';
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
                    _persistDraft();
                  } else {
                    // Persist the final draft, then hand off to the
                    // Journal tab with the prefill.
                    _persistDraft();
                    final draft = c.wizardDraft;
                    final handoff = c.requestLogTrade;
                    if (handoff != null) {
                      handoff(draft);
                    } else {
                      c.setActiveTab(2);
                    }
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
    required this.activeGates,
    required this.instrument,
    required this.planImagePath,
    required this.onPickPlanImage,
    required this.onClearPlanImage,
  });
  final TradingScreenViewModel controller;
  final Map<String, bool> autoChecks;
  final int passedCount;
  final List<Gate> activeGates;
  final String instrument;
  final String? planImagePath;
  final VoidCallback onPickPlanImage;
  final VoidCallback onClearPlanImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Plan chart attachment ──────────────────────────────
        _Card(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.image_outlined,
                    size: 18,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pre-trade chart',
                    style: TextStyle(
                      color: context.c.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (planImagePath != null)
                    TextButton.icon(
                      onPressed: onClearPlanImage,
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Clear'),
                      style: TextButton.styleFrom(
                        foregroundColor: context.c.textSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Snapshot your HTF setup before entry. Attached here, it auto-fills as the HTF chart on the journal entry.',
                style: TextStyle(
                  color: context.c.textTertiary,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              if (planImagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(planImagePath!),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: context.c.surfaceRaised,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onPickPlanImage,
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label: Text(
                    planImagePath == null
                        ? 'Attach plan screenshot'
                        : 'Replace screenshot',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Progress
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  value: activeGates.isEmpty
                      ? 0.0
                      : passedCount / activeGates.length,
                  backgroundColor: context.c.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.green,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$passedCount/${activeGates.length}',
              style: TextStyle(color: context.c.textSecondary, fontSize: 13),
            ),
          ],
        ),
        if (activeGates.length < kGates.length) ...[
          const SizedBox(height: 6),
          Text(
            'Showing ${activeGates.length} of ${kGates.length} gates relevant to $instrument.',
            style: TextStyle(color: context.c.textTertiary, fontSize: 11),
          ),
        ],
        const SizedBox(height: 16),

        // Gates list
        ...activeGates.map((gate) {
          final passed = gate.auto
              ? (autoChecks[gate.id] ?? false)
              : (controller.state.checks[gate.id] ?? false);
          final proof = controller.state.gateProofs[gate.id] ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _Card(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: gate.auto
                            ? Icon(
                                passed
                                    ? Icons.check_circle
                                    : Icons.cancel_outlined,
                                size: 20,
                                color: passed ? AppTheme.green : AppTheme.red,
                              )
                            : InkWell(
                                onTap: () => _showGateProofModal(
                                  context,
                                  controller,
                                  gate,
                                  proof,
                                ),
                                child: Icon(
                                  passed
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 22,
                                  color: passed
                                      ? AppTheme.green
                                      : context.c.textTertiary,
                                ),
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: gate.auto
                              ? null
                              : () => _showGateProofModal(
                                  context,
                                  controller,
                                  gate,
                                  proof,
                                ),
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
                      ),
                      if (gate.auto)
                        _Pill(
                          label: passed ? 'Auto ✓' : 'Blocked',
                          tone: passed ? AppTheme.green : AppTheme.red,
                        )
                      else if (!passed)
                        _Pill(label: 'Add proof', tone: AppTheme.amber),
                    ],
                  ),
                  if (!gate.auto && passed && proof.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.green.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.green.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.format_quote,
                            size: 14,
                            color: AppTheme.green,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              proof,
                              style: TextStyle(
                                color: context.c.textSecondary,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
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
        }),
      ],
    );
  }

  /// Modal that demands the trader writes (or attaches) proof before the gate
  /// turns green. Empty text un-passes the gate.
  Future<void> _showGateProofModal(
    BuildContext context,
    TradingScreenViewModel controller,
    Gate gate,
    String existingProof,
  ) async {
    final ctrl = TextEditingController(text: existingProof);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.c.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(gate.label, style: Theme.of(sheetCtx).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                gate.sub,
                style: TextStyle(color: context.c.textTertiary, fontSize: 12),
              ),
              const SizedBox(height: 14),
              Text(
                'Write your evidence',
                style: TextStyle(
                  color: context.c.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: ctrl,
                autofocus: true,
                maxLines: 4,
                minLines: 2,
                textInputAction: TextInputAction.done,
                style: TextStyle(color: context.c.text, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. HTF bearish per Daily H&S; M5 BOS at 2398.40',
                  hintStyle: TextStyle(
                    color: context.c.textTertiary,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: context.c.surfaceRaised,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.c.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.c.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.accent),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No empty ticks. Type one line of proof or clear it to un-pass this gate.',
                style: TextStyle(color: context.c.textTertiary, fontSize: 11),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetCtx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.c.textSecondary,
                        side: BorderSide(color: context.c.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(sheetCtx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (saved == true) {
      HapticFeedback.selectionClick();
      await controller.setGateProof(gate.id, ctrl.text);
    }
    ctrl.dispose();
  }
}

class _SizeStep extends StatelessWidget {
  const _SizeStep({
    super.key,
    required this.instrument,
    required this.slCtrl,
    required this.entriesCtrl,
    required this.tpCtrl,
    required this.lot,
    required this.risk,
    required this.riskCap,
    required this.takeProfit,
    required this.onInstrumentChange,
    required this.onInputChange,
  });
  final String instrument;
  final TextEditingController slCtrl;
  final TextEditingController entriesCtrl;
  final TextEditingController tpCtrl;
  final double lot;
  final double risk;
  final double riskCap;
  final double takeProfit;
  final ValueChanged<String> onInstrumentChange;
  final VoidCallback onInputChange;

  @override
  Widget build(BuildContext context) {
    final meta = kInstruments[instrument]!;
    final sl = double.tryParse(slCtrl.text) ?? 0;
    final minTp = sl * 2;
    final hasTp = takeProfit > 0;
    final rrOk = !hasTp || takeProfit >= minTp;
    final rrRatio = hasTp && sl > 0 ? takeProfit / sl : 0;
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
                tone: risk <= riskCap ? AppTheme.green : AppTheme.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                label: hasTp ? 'R:R' : 'Min TP',
                value: hasTp
                    ? '1:${rrRatio.toStringAsFixed(1)}'
                    : minTp.toStringAsFixed(1),
                tone: hasTp
                    ? (rrOk ? AppTheme.green : AppTheme.red)
                    : AppTheme.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Risk cap: \$${riskCap.toStringAsFixed(0)} per trade · '
          'Adjustable in Settings → Risk Management.',
          style: TextStyle(color: context.c.textTertiary, fontSize: 11),
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
          controller: tpCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Take profit (${meta.unit})',
            helperText: hasTp
                ? (rrOk
                      ? 'R:R 1:${rrRatio.toStringAsFixed(1)} ✓'
                      : 'Below 1:2 minimum — increase target')
                : 'Optional. Suggested ≥ ${minTp.toStringAsFixed(1)} for 1:2 R:R',
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
    required this.dailyCap,
  });
  final TradingScreenViewModel controller;
  final double lot;
  final double risk;
  final int dailyCap;

  @override
  Widget build(BuildContext context) {
    final trades = controller.getTodayTrades().length;
    final locked = controller.state.lock || trades >= dailyCap;
    final session = controller.getSessionInfo();
    final cap = controller.riskCapUsd;

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
            '$trades / $dailyCap',
            trades < dailyCap ? AppTheme.green : AppTheme.amber,
          ),
          _StatusRow(
            'Lot size',
            '${lot.toStringAsFixed(2)} lots',
            AppTheme.accent,
          ),
          _StatusRow(
            'Risk',
            '\$${risk.toStringAsFixed(0)}',
            risk <= cap ? AppTheme.green : AppTheme.red,
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
