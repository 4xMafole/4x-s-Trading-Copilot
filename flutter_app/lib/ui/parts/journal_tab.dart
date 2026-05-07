// GENERATED-BY-SPLIT - do not import this file directly.
part of '../trading_screen.dart';

// ═══════════════════════════════════════════════════════════════════════
//  TAB 2: JOURNAL
// ═══════════════════════════════════════════════════════════════════════

class _JournalTab extends StatefulWidget {
  const _JournalTab({super.key, required this.controller});
  final TradingScreenViewModel controller;

  @override
  State<_JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends State<_JournalTab> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _lastImagePickError;
  String? selectedDate;
  String? selectedTag;

  static const _vList = [
    {'id': 'stacking', 'label': 'Stacking'},
    {'id': 'session', 'label': 'Session'},
    {'id': 'risk', 'label': 'Risk'},
    {'id': 'instrument', 'label': 'Instrument'},
    {'id': 'rr', 'label': 'R:R'},
  ];

  Future<String?> _pickImagePath() async {
    _lastImagePickError = null;
    try {
      final img = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 85,
      );
      if (img == null || img.path.isEmpty) return null;
      final copied = await _copyImageToAppStorage(img.path);
      if (copied == null) {
        _lastImagePickError =
            'Image selected but could not be saved in app storage.';
      }
      return copied;
    } catch (_) {
      _lastImagePickError = 'Image picker failed. Please try again.';
      return null;
    }
  }

  Future<String?> _copyImageToAppStorage(String sourcePath) async {
    try {
      final source = File(sourcePath);
      if (!await source.exists()) return null;

      final docsDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory(
        '${docsDir.path}${Platform.pathSeparator}journal_images',
      );
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      final ext = _fileExtension(source.path);
      final stamp = DateTime.now().microsecondsSinceEpoch;
      final fileName = 'trade_${stamp}_${math.Random().nextInt(100000)}$ext';
      final target = File('${imageDir.path}${Platform.pathSeparator}$fileName');
      await source.copy(target.path);
      return target.path;
    } catch (_) {
      return null;
    }
  }

  String _fileExtension(String path) {
    final idx = path.lastIndexOf('.');
    if (idx <= 0 || idx >= path.length - 1) return '.jpg';
    final raw = path.substring(idx);
    final clean = raw.length > 8 ? raw.substring(0, 8) : raw;
    return clean;
  }

  /// Computes the suggested lot text for the log sheet based on a wizard
  /// draft (instrument + SL pips + entries against the configured risk cap).
  String _prefillLotText(
    TradingScreenViewModel c,
    WizardDraft? d,
  ) {
    if (d == null) return '';
    final sl = double.tryParse(d.stopLoss) ?? 0;
    final entries = int.tryParse(d.entries) ?? 1;
    final meta = kInstruments[d.instrument];
    if (meta == null || sl <= 0 || meta.pipVal <= 0 || entries <= 0) return '';
    final cap = c.riskCapUsd;
    final lot = (cap / entries) / (sl * meta.pipVal * 10);
    return lot.toStringAsFixed(2);
  }

  /// Computes the suggested planned-risk text from a wizard draft.
  String _prefillRiskText(
    TradingScreenViewModel c,
    WizardDraft? d,
  ) {
    if (d == null) return '';
    final sl = double.tryParse(d.stopLoss) ?? 0;
    final entries = int.tryParse(d.entries) ?? 1;
    final meta = kInstruments[d.instrument];
    if (meta == null || sl <= 0 || meta.pipVal <= 0 || entries <= 0) return '';
    final cap = c.riskCapUsd;
    final lot = (cap / entries) / (sl * meta.pipVal * 10);
    final risk = (lot * entries * sl * meta.pipVal * 10).clamp(0, cap);
    return risk.toStringAsFixed(0);
  }

  /// Sprint 3.3 — Pre-trade streak warning modal.
  /// Returns true if the trader chooses to proceed despite the streak.
  Future<bool?> _showStreakWarningModal(
    BuildContext parentCtx,
    TradeStreak streak,
  ) async {
    final isWin = streak.kind == StreakKind.win;
    final title = isWin
        ? "You're on a ${streak.length}-win streak"
        : "You're on a ${streak.length}-loss streak";
    final body = isWin
        ? "Statistically, the next trade after a hot streak underperforms by ~60%. Overconfidence is the most common cause of give-back. Consider reducing size or skipping today."
        : "Revenge-trading after consecutive losses is the #1 account-killer. Your judgment is statistically impaired right now. Consider stopping for the day, or cutting size in half.";
    final tone = isWin ? Colors.amber.shade700 : Colors.redAccent;

    return showModalBottomSheet<bool>(
      context: parentCtx,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: parentCtx.c.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ctx.c.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      isWin ? Icons.local_fire_department : Icons.warning_amber,
                      color: tone,
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: Theme.of(
                    ctx,
                  ).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Skip this trade'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: tone),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Proceed anyway'),
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

  /// Mandatory 30-second post-trade reflection (Sprint 2.2).
  /// Shown immediately after a real (non-hypothetical) trade is logged.
  Future<void> _showPostTradeReflectionSheet(
    BuildContext parentCtx,
    TradingScreenViewModel c,
    Trade trade,
  ) async {
    bool? followedPlan;
    String? exitReason;
    int emotionalState = 5;

    final saved = await showModalBottomSheet<bool>(
      context: parentCtx,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: parentCtx.c.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            final canSave = followedPlan != null && exitReason != null;
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.psychology_alt_outlined,
                          color: AppTheme.accent,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '30-second reflection',
                            style: Theme.of(sheetCtx).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Three taps. They build your behavioural edge over time.',
                      style: TextStyle(
                        color: parentCtx.c.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '1. Did you follow your plan?',
                      style: TextStyle(
                        color: parentCtx.c.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ReflectionChoiceBtn(
                            label: 'Yes',
                            icon: Icons.check_circle,
                            tone: AppTheme.green,
                            selected: followedPlan == true,
                            onTap: () =>
                                setSheetState(() => followedPlan = true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ReflectionChoiceBtn(
                            label: 'No',
                            icon: Icons.cancel,
                            tone: AppTheme.red,
                            selected: followedPlan == false,
                            onTap: () =>
                                setSheetState(() => followedPlan = false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '2. What ended the trade?',
                      style: TextStyle(
                        color: parentCtx.c.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kExitReasons.map((r) {
                        return ChoiceChip(
                          label: Text(r),
                          selected: exitReason == r,
                          onSelected: (_) =>
                              setSheetState(() => exitReason = r),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '3. Emotional state during the trade',
                      style: TextStyle(
                        color: parentCtx.c.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Reactive',
                          style: TextStyle(
                            color: parentCtx.c.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$emotionalState / 10',
                          style: TextStyle(
                            color: parentCtx.c.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Locked-in',
                          style: TextStyle(
                            color: parentCtx.c.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: emotionalState.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: '$emotionalState',
                      onChanged: (v) =>
                          setSheetState(() => emotionalState = v.round()),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetCtx, false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Skip'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: canSave
                                ? () => Navigator.pop(sheetCtx, true)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Save reflection'),
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
      },
    );

    if (saved == true && followedPlan != null && exitReason != null) {
      await c.setReflection(
        trade.id,
        TradeReflection(
          followedPlan: followedPlan!,
          exitReason: exitReason!,
          emotionalState: emotionalState,
        ),
      );
    }
  }

  Future<void> openLogTradeSheet({WizardDraft? prefill}) async {
    final c = widget.controller;

    var sheetSym = prefill?.instrument ?? 'XAUUSD';
    var sheetDir = 'buy';
    final sheetViolations = <String>{};
    final sheetTags = <String>{};
    String? sheetHtfImagePath = prefill?.planImagePath;
    String? sheetLtfImagePath;
    DateTime? sheetDate;
    TimeOfDay? sheetTime;
    bool sheetIsHypothetical = false;
    String? sheetSetupQuality;
    String? sheetTrigger;
    final sheetLotsCtrl = TextEditingController(
      text: _prefillLotText(c, prefill),
    );
    final sheetPnlCtrl = TextEditingController();
    final sheetPlannedRiskCtrl = TextEditingController(
      text: _prefillRiskText(c, prefill),
    );
    final sheetNoteCtrl = TextEditingController();
    final sheetTagsCtrl = TextEditingController();

    // Aggregate previously-used tags to suggest as quick chips.
    final pastTags = <String>{};
    for (final t in c.state.allTrades) {
      pastTags.addAll(t.tags);
    }
    final tagSuggestions = pastTags.toList()..sort();

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setSheetState) {
              Future<void> attachImage(bool isHTF) async {
                final path = await _pickImagePath();
                if (!mounted || !ctx.mounted) return;
                if (path == null) {
                  _snack(context, _lastImagePickError ?? 'No image selected.');
                  return;
                }
                setSheetState(() {
                  if (isHTF) {
                    sheetHtfImagePath = path;
                  } else {
                    sheetLtfImagePath = path;
                  }
                });
              }

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    16 + MediaQuery.of(ctx).viewInsets.bottom,
                  ),
                  child: _Card(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Log trade',
                                style: Theme.of(ctx).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => Navigator.pop(ctx),
                                icon: const Icon(Icons.close),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: sheetSym,
                            items: const [
                              DropdownMenuItem(
                                value: 'XAUUSD',
                                child: Text('XAUUSD'),
                              ),
                              DropdownMenuItem(
                                value: 'NQ',
                                child: Text('NQ100'),
                              ),
                              DropdownMenuItem(
                                value: 'EURUSD',
                                child: Text('EURUSD'),
                              ),
                            ],
                            onChanged: (v) {
                              setSheetState(() => sheetSym = v ?? 'XAUUSD');
                            },
                            decoration: const InputDecoration(
                              labelText: 'Instrument',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: sheetDir,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'buy',
                                      child: Text('Buy'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'sell',
                                      child: Text('Sell'),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    setSheetState(() => sheetDir = v ?? 'buy');
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Direction',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: sheetLotsCtrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    labelText: 'Lots',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: sheetPnlCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'P&L (USD)',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: sheetPlannedRiskCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Planned risk (USD)',
                              hintText: 'From your calculator',
                              prefixText: '\$ ',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _vList.map((item) {
                              final id = item['id']!;
                              return FilterChip(
                                label: Text(item['label']!),
                                selected: sheetViolations.contains(id),
                                onSelected: (on) => setSheetState(() {
                                  on
                                      ? sheetViolations.add(id)
                                      : sheetViolations.remove(id);
                                }),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: sheetNoteCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: sheetTagsCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Tags',
                              hintText: 'fomo, A-Plus, news (comma-separated)',
                              prefixIcon: Icon(Icons.tag, size: 18),
                            ),
                            onChanged: (v) {
                              final parsed = v
                                  .split(RegExp(r'[,\s]+'))
                                  .map((s) => s.trim().replaceAll('#', ''))
                                  .where((s) => s.isNotEmpty)
                                  .toSet();
                              sheetTags
                                ..clear()
                                ..addAll(parsed);
                            },
                          ),
                          if (tagSuggestions.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: tagSuggestions.map((tag) {
                                final selected = sheetTags.contains(tag);
                                return FilterChip(
                                  label: Text('#$tag'),
                                  selected: selected,
                                  onSelected: (on) => setSheetState(() {
                                    if (on) {
                                      sheetTags.add(tag);
                                    } else {
                                      sheetTags.remove(tag);
                                    }
                                    sheetTagsCtrl.text = sheetTags.join(', ');
                                    sheetTagsCtrl.selection =
                                        TextSelection.collapsed(
                                          offset: sheetTagsCtrl.text.length,
                                        );
                                  }),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Text(
                            'Setup Quality *',
                            style: Theme.of(ctx).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: kSetupQualities.map((q) {
                              final selected = sheetSetupQuality == q;
                              return ChoiceChip(
                                label: Text(q),
                                selected: selected,
                                onSelected: (_) =>
                                    setSheetState(() => sheetSetupQuality = q),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Trigger *',
                            style: Theme.of(ctx).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: kTradeTriggers.map((t) {
                              final selected = sheetTrigger == t;
                              return ChoiceChip(
                                label: Text(t),
                                selected: selected,
                                onSelected: (_) =>
                                    setSheetState(() => sheetTrigger = t),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Both fields are required. They power your edge analytics.',
                            style: TextStyle(
                              color: Theme.of(
                                ctx,
                              ).extension<AppColors>()!.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Backfill / Hypothetical (Optional)',
                            style: Theme.of(ctx).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final d = await showDatePicker(
                                      context: ctx,
                                      initialDate: sheetDate ?? DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (d != null)
                                      setSheetState(() => sheetDate = d);
                                  },
                                  icon: const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                  ),
                                  label: Text(
                                    sheetDate != null
                                        ? '${sheetDate!.year}-${sheetDate!.month.toString().padLeft(2, '0')}-${sheetDate!.day.toString().padLeft(2, '0')}'
                                        : 'Set Date',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final t = await showTimePicker(
                                      context: ctx,
                                      initialTime: sheetTime ?? TimeOfDay.now(),
                                    );
                                    if (t != null)
                                      setSheetState(() => sheetTime = t);
                                  },
                                  icon: const Icon(Icons.access_time, size: 18),
                                  label: Text(
                                    sheetTime != null
                                        ? sheetTime!.format(ctx)
                                        : 'Set Time',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Hypothetical (What-if) Trade'),
                            subtitle: const Text('Excludes from Challenge P&L'),
                            value: sheetIsHypothetical,
                            onChanged: (v) =>
                                setSheetState(() => sheetIsHypothetical = v),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => attachImage(true),
                                  icon: const Icon(Icons.image, size: 18),
                                  label: Text(
                                    sheetHtfImagePath != null
                                        ? 'HTF ✓'
                                        : 'HTF Chart',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => attachImage(false),
                                  icon: const Icon(Icons.image, size: 18),
                                  label: Text(
                                    sheetLtfImagePath != null
                                        ? 'LTF ✓'
                                        : 'LTF Chart',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () async {
                                FocusScope.of(ctx).unfocus();

                                final pnl = double.tryParse(
                                  sheetPnlCtrl.text.trim(),
                                );
                                if (pnl == null) {
                                  _snack(context, 'Enter valid P&L.');
                                  return;
                                }
                                if (sheetSetupQuality == null) {
                                  _snack(
                                    context,
                                    'Pick a Setup Quality (A+/B/C).',
                                  );
                                  return;
                                }
                                if (sheetTrigger == null) {
                                  _snack(
                                    context,
                                    'Pick a Trigger (Plan/FOMO/etc).',
                                  );
                                  return;
                                }

                                // Sprint 3.3 — pre-trade streak warning.
                                if (!sheetIsHypothetical) {
                                  final streak =
                                      IntelligenceEngine.currentStreak(
                                        c.state.allTrades,
                                      );
                                  if (streak.shouldWarn) {
                                    final proceed =
                                        await _showStreakWarningModal(
                                          context,
                                          streak,
                                        );
                                    if (proceed != true) return;
                                  }
                                }

                                // Sprint 4.2 — weekly R-budget enforcement.
                                // If exhausted, force the trade to be
                                // logged as paper-only for the rest of week.
                                var enforcedHypothetical = sheetIsHypothetical;
                                if (!sheetIsHypothetical) {
                                  final b = c.weeklyRiskBudget;
                                  final lossUsd =
                                      RiskBudgetEngine.weeklyLossUsd(
                                        c.state.allTrades,
                                        c.nowEAT,
                                      );
                                  if (RiskBudgetEngine.isExhausted(
                                    lossUsd,
                                    b,
                                  )) {
                                    enforcedHypothetical = true;
                                    if (context.mounted) {
                                      _snack(
                                        context,
                                        'Weekly R-budget exhausted — logged as paper-only.',
                                      );
                                    }
                                  }
                                }

                                // Sprint 4.4 — high-impact news blackout.
                                if (!sheetIsHypothetical &&
                                    c.blockTradesAroundNews) {
                                  final events = await EconomicCalendarService()
                                      .getHighImpactEvents();
                                  final inBlackout =
                                      EconomicCalendarService.isInBlackout(
                                        events,
                                        DateTime.now(),
                                      );
                                  if (inBlackout) {
                                    if (context.mounted) {
                                      _snack(
                                        context,
                                        'Trade blocked: high-impact news within ±15 min.',
                                      );
                                    }
                                    return;
                                  }
                                }

                                final newTrade = await c.addTrade(
                                  sym: sheetSym,
                                  dir: sheetDir,
                                  lots:
                                      double.tryParse(
                                        sheetLotsCtrl.text.trim(),
                                      ) ??
                                      0,
                                  pnl: pnl,
                                  note: sheetNoteCtrl.text,
                                  violations: sheetViolations.toList(),
                                  tags: sheetTags.toList(),
                                  htfImage: sheetHtfImagePath,
                                  ltfImage: sheetLtfImagePath,
                                  date: sheetDate != null
                                      ? '${sheetDate!.year.toString().padLeft(4, '0')}-${sheetDate!.month.toString().padLeft(2, '0')}-${sheetDate!.day.toString().padLeft(2, '0')}'
                                      : null,
                                  time: sheetTime != null
                                      ? '${sheetTime!.hour.toString().padLeft(2, '0')}:${sheetTime!.minute.toString().padLeft(2, '0')} EAT'
                                      : null,
                                  isHypothetical: enforcedHypothetical,
                                  setupQuality: sheetSetupQuality,
                                  trigger: sheetTrigger,
                                  plannedRisk: double.tryParse(
                                    sheetPlannedRiskCtrl.text.trim(),
                                  ),
                                );

                                if (ctx.mounted) Navigator.pop(ctx);
                                // Clear the in-flight wizard draft so the
                                // Trade tab resets after a successful log.
                                await c.clearWizardDraft();
                                if (!enforcedHypothetical && mounted) {
                                  await _showPostTradeReflectionSheet(
                                    context,
                                    c,
                                    newTrade,
                                  );
                                }
                                if (mounted) {
                                  setState(() => selectedDate = null);
                                  _snack(context, 'Trade logged.');
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      // Defer disposal safely beyond any closing animations
      // to prevent "dependents.isEmpty" assertion errors.
      Future.delayed(const Duration(milliseconds: 500), () {
        sheetLotsCtrl.dispose();
        sheetPnlCtrl.dispose();
        sheetPlannedRiskCtrl.dispose();
        sheetNoteCtrl.dispose();
        sheetTagsCtrl.dispose();
      });
    }
  }

  Future<void> _confirmDeleteTrade(Trade t) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: context.c.surface,
            title: const Text('Delete trade?'),
            content: Text(
              '${t.sym} ${t.dir.toUpperCase()} · ${t.time}\nThis action cannot be undone.',
              style: TextStyle(color: context.c.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;
    await widget.controller.deleteTrade(t.id);
    if (mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Trade deleted.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              widget.controller.restoreTrade(t);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final todayTrades = c.getTodayTrades();
    final allDates = c.getAllTradeDates();
    final allTagsSet = <String>{};
    for (final t in c.state.allTrades) {
      allTagsSet.addAll(t.tags);
    }
    final allTags = allTagsSet.toList()..sort();
    var displayTrades = selectedDate != null
        ? c.getTradesByDate(selectedDate!)
        : c.getAllTradesDesc();
    if (selectedTag != null) {
      displayTrades = displayTrades
          .where((t) => t.tags.contains(selectedTag))
          .toList();
    }
    final locked = c.state.lock || todayTrades.length >= 2;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text(
          'Journal',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          selectedDate == null
              ? '${c.state.allTrades.length} trade${c.state.allTrades.length == 1 ? '' : 's'} total'
              : '${displayTrades.length} trade${displayTrades.length == 1 ? '' : 's'} on $selectedDate',
          style: TextStyle(color: context.c.textSecondary, fontSize: 13),
        ),

        const SizedBox(height: 12),
        _Card(
          child: Row(
            children: [
              Icon(Icons.add_circle_outline, color: AppTheme.accent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  locked
                      ? 'Session closed for new entries.'
                      : 'Use the + Log Trade button to add a new journal entry.',
                  style: TextStyle(color: context.c.textSecondary),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Date selector and history ──
        if (allDates.isNotEmpty)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trade History',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('All'),
                          selected: selectedDate == null,
                          onSelected: (selected) =>
                              setState(() => selectedDate = null),
                        ),
                      ),
                      ...allDates.map((date) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(date),
                            selected: selectedDate == date,
                            onSelected: (selected) => setState(
                              () => selectedDate = selected ? date : null,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

        if (allTags.isNotEmpty) ...[
          const SizedBox(height: 12),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tag, size: 16, color: context.c.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Filter by tag',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('All'),
                          selected: selectedTag == null,
                          onSelected: (_) => setState(() => selectedTag = null),
                        ),
                      ),
                      ...allTags.map((tag) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text('#$tag'),
                            selected: selectedTag == tag,
                            onSelected: (selected) => setState(
                              () => selectedTag = selected ? tag : null,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // ── Trade list ──
        if (displayTrades.isEmpty)
          _Card(
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 32,
                  color: context.c.textTertiary,
                ),
                const SizedBox(height: 8),
                Text(
                  selectedDate == null
                      ? 'No trades yet'
                      : 'No trades on $selectedDate',
                  style: TextStyle(color: context.c.textSecondary),
                ),
              ],
            ),
          )
        else
          ...displayTrades.map((t) {
            final tone = t.pnl >= 0 ? AppTheme.green : AppTheme.red;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 48,
                          decoration: BoxDecoration(
                            color: tone,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${t.sym} ${t.dir.toUpperCase()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (t.isHypothetical) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accent.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: AppTheme.accent.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'WHAT IF',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.accent,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                '${t.time} · ${t.lots.toStringAsFixed(2)} lots',
                                style: TextStyle(
                                  color: context.c.textTertiary,
                                  fontSize: 12,
                                ),
                              ),
                              if (t.plannedRisk != null &&
                                  t.plannedRisk! > 0 &&
                                  t.pnl < 0) ...[
                                const SizedBox(height: 4),
                                Builder(
                                  builder: (_) {
                                    final actual = -t.pnl;
                                    final delta = actual - t.plannedRisk!;
                                    final pct = (delta / t.plannedRisk! * 100)
                                        .round();
                                    final overshoot = delta > 0;
                                    return Text(
                                      'Plan \$${t.plannedRisk!.toStringAsFixed(0)} · '
                                      'Actual \$${actual.toStringAsFixed(0)} · '
                                      '${overshoot ? "+" : ""}$pct%',
                                      style: TextStyle(
                                        color: overshoot
                                            ? AppTheme.red
                                            : AppTheme.green,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          _signed(t.pnl),
                          style: TextStyle(
                            color: tone,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _confirmDeleteTrade(t),
                          icon: Icon(
                            Icons.close,
                            size: 16,
                            color: context.c.textTertiary,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    // Show images if available
                    if (t.htfImage != null || t.ltfImage != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (t.htfImage != null)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HTF',
                                    style: TextStyle(
                                      color: context.c.textTertiary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _openImageViewer(
                                      t.htfImage!,
                                      heroTag: 'htf-${t.id}',
                                    ),
                                    child: Hero(
                                      tag: 'htf-${t.id}',
                                      child: Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: context.c.border,
                                            width: 1,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: Image.file(
                                            File(t.htfImage!),
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.image_not_supported,
                                              color: context.c.textTertiary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (t.htfImage != null && t.ltfImage != null)
                            const SizedBox(width: 12),
                          if (t.ltfImage != null)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LTF',
                                    style: TextStyle(
                                      color: context.c.textTertiary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _openImageViewer(
                                      t.ltfImage!,
                                      heroTag: 'ltf-${t.id}',
                                    ),
                                    child: Hero(
                                      tag: 'ltf-${t.id}',
                                      child: Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: context.c.border,
                                            width: 1,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: Image.file(
                                            File(t.ltfImage!),
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.image_not_supported,
                                              color: context.c.textTertiary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (t.note.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        t.note,
                        style: TextStyle(
                          color: context.c.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (t.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: t.tags.map((tag) {
                          final active = selectedTag == tag;
                          return GestureDetector(
                            onTap: () => setState(
                              () => selectedTag = active ? null : tag,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppTheme.accent.withValues(alpha: 0.18)
                                    : AppTheme.accent.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppTheme.accent.withValues(
                                    alpha: active ? 0.6 : 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 96),
      ],
    );
  }

  void _snack(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openImageViewer(String path, {required String heroTag}) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (ctx, anim, _) =>
            _ImageViewerScreen(path: path, heroTag: heroTag),
      ),
    );
  }
}

class _ReflectionChoiceBtn extends StatelessWidget {
  const _ReflectionChoiceBtn({
    required this.label,
    required this.icon,
    required this.tone,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color tone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? tone.withValues(alpha: 0.12) : c.surfaceRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? tone : c.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? tone : c.textTertiary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? tone : c.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
