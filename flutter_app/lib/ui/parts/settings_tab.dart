// GENERATED-BY-SPLIT - do not import this file directly.
part of '../trading_screen.dart';

// ═══════════════════════════════════════════════════════════════════════
//  TAB 4: SETTINGS
// ═══════════════════════════════════════════════════════════════════════

class _SettingsTab extends StatefulWidget {
  const _SettingsTab({required this.controller});
  final TradingScreenViewModel controller;

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  late final balanceCtrl = TextEditingController(
    text: widget.controller.state.balance.toStringAsFixed(2),
  );
  late final startCtrl = TextEditingController(
    text: widget.controller.state.startDate,
  );
  late final priorCtrl = TextEditingController(
    text: widget.controller.state.priorPnl.toStringAsFixed(2),
  );
  late final importCtrl = TextEditingController();

  @override
  void dispose() {
    balanceCtrl.dispose();
    startCtrl.dispose();
    priorCtrl.dispose();
    importCtrl.dispose();
    super.dispose();
  }

  Future<void> _exportData(String format, TradingScreenViewModel c) async {
    try {
      String content;
      if (format == 'json') {
        content = c.exportAsJson();
      } else {
        content = c.exportAsCsv();
      }
      await Clipboard.setData(ClipboardData(text: content));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${format.toUpperCase()} data copied.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Export failed.')));
      }
    }
  }

  Future<void> _confirmRotateKey(
    BuildContext context,
    TradingScreenViewModel c,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.c.surface,
        title: const Text('Reset encryption key?'),
        content: const Text(
          'A new AES-256 key will be generated and your existing trade '
          'history will be re-encrypted with it. No data is lost. This '
          'cannot be undone — exported backups created with the old key '
          'are still readable; only the on-device key changes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset key'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await c.rotateEncryptionKey();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Encryption key rotated.')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to rotate key: $e')));
    }
  }

  Future<ImportResult?> _importDialog(
    BuildContext context,
    TradingScreenViewModel c,
  ) async {
    importCtrl.clear();
    var format = 'json';
    var merge = true;
    var isBusy = false;
    ImportResult? result;
    ImportResult? preview;
    var previewSignature = '';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Future<void> runPreview() async {
            final raw = importCtrl.text.trim();
            if (raw.isEmpty) {
              setDialogState(() {
                preview = const ImportResult(
                  ok: false,
                  message: 'Import payload is empty.',
                  dryRun: true,
                );
                previewSignature = '';
              });
              return;
            }

            setDialogState(() => isBusy = true);
            final next = format == 'json'
                ? await c.importJsonData(raw, merge: merge, dryRun: true)
                : await c.importCsvData(raw, merge: merge, dryRun: true);
            if (!ctx.mounted) return;
            setDialogState(() {
              preview = next;
              previewSignature = '$format|$merge|$raw';
              isBusy = false;
            });
          }

          final raw = importCtrl.text.trim();
          final currentSignature = '$format|$merge|$raw';
          final canImport =
              !isBusy &&
              raw.isNotEmpty &&
              preview?.ok == true &&
              previewSignature == currentSignature;

          return AlertDialog(
            backgroundColor: context.c.surface,
            title: const Text('Import Data'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'json', label: Text('JSON')),
                      ButtonSegment(value: 'csv', label: Text('CSV')),
                    ],
                    selected: {format},
                    onSelectionChanged: (s) {
                      setDialogState(() {
                        format = s.first;
                        preview = null;
                        previewSignature = '';
                      });
                    },
                    showSelectedIcon: false,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    value: merge,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Merge with existing history'),
                    subtitle: Text(
                      merge
                          ? 'Keeps existing data and adds imported rows.'
                          : 'Replaces existing trade history with imported rows.',
                      style: TextStyle(color: context.c.textSecondary),
                    ),
                    onChanged: (v) => setDialogState(() {
                      merge = v;
                      preview = null;
                      previewSignature = '';
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: importCtrl,
                    maxLines: 12,
                    onChanged: (_) {
                      setDialogState(() {
                        preview = null;
                        previewSignature = '';
                      });
                    },
                    decoration: InputDecoration(
                      hintText: format == 'json'
                          ? 'Paste exported JSON content here'
                          : 'Paste CSV with header row here',
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isBusy) const LinearProgressIndicator(minHeight: 3),
                  if (preview != null) ...[
                    const SizedBox(height: 10),
                    _buildImportSummaryPanel(context, preview!),
                  ] else ...[
                    Text(
                      'Tap Preview to validate rows and see import impact before applying.',
                      style: TextStyle(color: context.c.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isBusy ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              OutlinedButton(
                onPressed: isBusy ? null : runPreview,
                child: const Text('Preview'),
              ),
              FilledButton(
                onPressed: canImport
                    ? () async {
                        setDialogState(() => isBusy = true);
                        result = format == 'json'
                            ? await c.importJsonData(raw, merge: merge)
                            : await c.importCsvData(raw, merge: merge);
                        if (ctx.mounted) Navigator.pop(ctx);
                      }
                    : null,
                child: const Text('Import'),
              ),
            ],
          );
        },
      ),
    );

    return result;
  }

  Widget _buildImportSummaryPanel(BuildContext context, ImportResult result) {
    final preview = result.preview;
    final tone = result.ok ? AppTheme.green : AppTheme.red;

    if (preview == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: tone.withValues(alpha: 0.25)),
        ),
        child: Text(
          result.message,
          style: TextStyle(color: context.c.textSecondary),
        ),
      );
    }

    final mode = preview.merge ? 'Merge' : 'Replace';
    final dateRange = (preview.fromDate != null && preview.toDate != null)
        ? '${preview.fromDate} to ${preview.toDate}'
        : 'N/A';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tone.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.ok ? 'Preview ready' : 'Preview failed',
            style: TextStyle(fontWeight: FontWeight.w700, color: tone),
          ),
          const SizedBox(height: 8),
          _buildImportMetricRow('Format', preview.format.toUpperCase()),
          _buildImportMetricRow('Mode', mode),
          _buildImportMetricRow('Current trades', '${preview.currentCount}'),
          _buildImportMetricRow('Incoming rows', '${preview.incomingCount}'),
          _buildImportMetricRow('Valid rows', '${preview.importedCount}'),
          _buildImportMetricRow('Skipped rows', '${preview.skippedCount}'),
          _buildImportMetricRow('Duplicate IDs', '${preview.duplicateCount}'),
          _buildImportMetricRow(
            'Resulting trades',
            '${preview.resultingCount}',
          ),
          _buildImportMetricRow('Date range', dateRange),
          const SizedBox(height: 8),
          Text(
            result.message,
            style: TextStyle(color: context.c.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildImportMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: context.c.textSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.c.text,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImportReportDialog(
    BuildContext context,
    ImportResult result,
  ) async {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.c.surface,
        title: Text(result.ok ? 'Import Report' : 'Import Failed'),
        content: _buildImportSummaryPanel(context, result),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text(
          'Settings',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          'Challenge configuration & data',
          style: TextStyle(color: context.c.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _ThemeModeSelector(controller: c),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Challenge', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 14),
              TextField(
                controller: balanceCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Starting balance',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: startCtrl,
                decoration: const InputDecoration(
                  labelText: 'Start date (YYYY-MM-DD)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priorCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Prior P&L (USD)'),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => c.updateState(
                    balance:
                        double.tryParse(balanceCtrl.text) ?? c.state.balance,
                    startDate: startCtrl.text.trim().isEmpty
                        ? c.state.startDate
                        : startCtrl.text.trim(),
                    priorPnl:
                        double.tryParse(priorCtrl.text) ?? c.state.priorPnl,
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          tone: context.c.positive,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: context.c.positive,
                    size: 20,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    'Security',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  _Pill(
                    label: c.encryptionEnabled ? 'AES-256' : 'OFF',
                    tone: c.encryptionEnabled
                        ? context.c.positive
                        : context.c.negative,
                    dense: true,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                c.encryptionEnabled
                    ? 'Trade history is encrypted at rest. The key is stored in the device keychain (Keystore on Android).'
                    : 'Encryption is unavailable. Data is stored in plaintext.',
                style: TextStyle(
                  color: context.c.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: c.encryptionEnabled
                        ? () => _confirmRotateKey(context, c)
                        : null,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reset encryption key'),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Trade screenshots remain stored in app-private storage and are protected by device encryption.',
                style: TextStyle(
                  color: context.c.textTertiary,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Data', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => _guardedResetToday(context, c),
                    child: const Text('Reset today'),
                  ),
                  OutlinedButton(
                    onPressed: () => _guardedResetAll(context, c),
                    child: const Text('Full reset'),
                  ),
                  OutlinedButton(
                    onPressed: () => _exportData('json', c),
                    child: const Text('Export JSON'),
                  ),
                  OutlinedButton(
                    onPressed: () => _exportData('csv', c),
                    child: const Text('Export CSV'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final result = await _importDialog(context, c);
                      if (!context.mounted || result == null) return;
                      await _showImportReportDialog(context, result);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(result.message)));
                    },
                    child: const Text('Import JSON/CSV'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _IntegrityLogCard(controller: c),
        const SizedBox(height: 12),
        _AccountsCard(controller: c),
        const SizedBox(height: 12),
        _PropFirmRulesCard(controller: c),
        const SizedBox(height: 12),
        _WeeklyRiskBudgetSettingsCard(controller: c),
        const SizedBox(height: 12),
        _NewsBlackoutCard(controller: c),
        const SizedBox(height: 12),
        _CloudBackupCard(controller: c),
        const SizedBox(height: 12),
        _LocalOnlyAiCard(controller: c),
        const SizedBox(height: 12),
        _DailyTradeCapCard(controller: c),
        const SizedBox(height: 12),
        _NotificationsCard(controller: c),
        const SizedBox(height: 12),
        _TearSheetCard(controller: c),
      ],
    );
  }

  // ── Reset guards ────────────────────────────────────────────────────────
  /// Locked-down "Reset today":
  ///   1. 24-hour cooldown enforced
  ///   2. Biometric reauth required
  ///   3. Tilt-prone warning if 3+ resets in 30 days
  ///   4. Action permanently logged in the Integrity Log
  Future<void> _guardedResetToday(
    BuildContext context,
    TradingScreenViewModel c,
  ) async {
    if (c.isInResetCooldown()) {
      final remaining = c.resetCooldownRemainingMs();
      _showSnack(
        context,
        'Reset cooldown active — try again in ${_fmtRemaining(remaining)}.',
      );
      return;
    }

    final tiltCount = c.recentResetCount();
    final tiltWarning = tiltCount >= 2; // 3rd reset → flag

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Reset today?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This permanently clears today's trades, gate checks, and lock. "
              "It will be recorded in your Integrity Log forever.",
            ),
            const SizedBox(height: 12),
            const Text(
              '• 24-hour cooldown applies after reset.\n'
              '• Biometric authentication required.',
              style: TextStyle(fontSize: 12),
            ),
            if (tiltWarning) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.amber.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '⚠ Tilt-prone signal: $tiltCount reset(s) in the last 30 '
                  'days. Resetting again won\'t change what happened — it '
                  'only hides it from your stats. Sit out instead.',
                  style: const TextStyle(fontSize: 12, color: AppTheme.amber),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final ok = await c.authenticateBiometric(
      reason: 'Authorize Reset Today',
      ignoreSetting: true,
    );
    if (!ok) {
      if (context.mounted) {
        _showSnack(context, 'Biometric authentication failed — reset blocked.');
      }
      return;
    }

    await c.resetToday();
    if (context.mounted) {
      _showSnack(context, 'Today reset & logged in Integrity Log.');
    }
  }

  Future<void> _guardedResetAll(
    BuildContext context,
    TradingScreenViewModel c,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Full reset?'),
        content: const Text(
          'This wipes ALL trades, settings, and gate proofs. The Integrity '
          'Log is preserved as a permanent audit trail. This cannot be '
          'undone. Biometric authentication is required.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Wipe everything'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final ok = await c.authenticateBiometric(
      reason: 'Authorize Full Reset',
      ignoreSetting: true,
    );
    if (!ok) {
      if (context.mounted) {
        _showSnack(context, 'Biometric authentication failed — reset blocked.');
      }
      return;
    }

    await c.resetAll();
    if (context.mounted) {
      _showSnack(context, 'Full reset complete. Logged in Integrity Log.');
    }
  }

  static void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  static String _fmtRemaining(int ms) {
    final h = ms ~/ Duration.millisecondsPerHour;
    final m =
        (ms % Duration.millisecondsPerHour) ~/ Duration.millisecondsPerMinute;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m';
    return '<1m';
  }
}

/// Permanent audit trail of resets, lock overrides, and balance changes.
/// Cannot be cleared — that's the point.
class _IntegrityLogCard extends StatelessWidget {
  const _IntegrityLogCard({required this.controller});
  final TradingScreenViewModel controller;

  @override
  Widget build(BuildContext context) {
    final log = controller.integrityLog;
    final tiltCount = controller.recentResetCount();
    final isTiltProne = tiltCount >= 3;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Activity History',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (isTiltProne)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppTheme.red.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text(
                    'TILT-PRONE',
                    style: TextStyle(
                      color: AppTheme.red,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Permanent audit trail. Trade adds/edits/deletes, resets, and '
            'balance changes are recorded here forever — they cannot be deleted.',
            style: TextStyle(
              color: context.c.textTertiary,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          if (log.isEmpty)
            Text(
              'No events yet — keep it clean.',
              style: TextStyle(
                color: context.c.textTertiary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Column(
              children: [
                for (final ev in log.reversed.take(20))
                  _IntegrityEventRow(event: ev),
                if (log.length > 20)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '+ ${log.length - 20} older event(s)',
                      style: TextStyle(
                        color: context.c.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _IntegrityEventRow extends StatelessWidget {
  const _IntegrityEventRow({required this.event});
  final IntegrityEvent event;

  Color _toneFor(BuildContext context) {
    switch (event.type) {
      case 'reset_all':
        return AppTheme.red;
      case 'reset_today':
        return AppTheme.amber;
      case 'balance_changed':
        return AppTheme.accent;
      case 'trade_deleted':
        return AppTheme.red;
      case 'trade_edited':
        return AppTheme.amber;
      case 'trade_added':
        return AppTheme.green;
      default:
        return context.c.textSecondary;
    }
  }

  String _labelFor() {
    switch (event.type) {
      case 'reset_all':
        return 'Full reset';
      case 'reset_today':
        return 'Reset today';
      case 'balance_changed':
        return 'Balance changed';
      case 'lock_override':
        return 'Lock override';
      case 'trade_added':
        return 'Trade added';
      case 'trade_edited':
        return 'Trade edited';
      case 'trade_deleted':
        return 'Trade deleted';
      case 'restored_backup':
        return 'Restored backup';
      case 'account_created':
        return 'Account created';
      case 'account_switched':
        return 'Account switched';
      case 'account_deleted':
        return 'Account deleted';
      default:
        return event.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tone = _toneFor(context);
    final dt = DateTime.fromMillisecondsSinceEpoch(event.timestamp);
    final stamp =
        '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _labelFor(),
                      style: TextStyle(
                        color: tone,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      stamp,
                      style: TextStyle(
                        color: context.c.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (event.detail.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      event.detail,
                      style: TextStyle(
                        color: context.c.textSecondary,
                        fontSize: 11,
                      ),
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

/// Sprint 4.1 — Prop-firm rules editor. Lets the trader opt in to
/// prop-firm-style drawdown limits and configure their daily/total caps.
class _PropFirmRulesCard extends StatefulWidget {
  const _PropFirmRulesCard({required this.controller});
  final TradingScreenViewModel controller;

  @override
  State<_PropFirmRulesCard> createState() => _PropFirmRulesCardState();
}

class _PropFirmRulesCardState extends State<_PropFirmRulesCard> {
  late TextEditingController _firmCtrl;
  late TextEditingController _dailyCtrl;
  late TextEditingController _totalCtrl;

  @override
  void initState() {
    super.initState();
    final r = widget.controller.propFirmRules;
    _firmCtrl = TextEditingController(text: r.firmName);
    _dailyCtrl = TextEditingController(
      text: r.maxDailyDrawdown > 0 ? r.maxDailyDrawdown.toStringAsFixed(0) : '',
    );
    _totalCtrl = TextEditingController(
      text: r.maxTotalDrawdown > 0 ? r.maxTotalDrawdown.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _firmCtrl.dispose();
    _dailyCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final next = PropFirmRules(
      enabled: true,
      firmName: _firmCtrl.text.trim(),
      maxDailyDrawdown: double.tryParse(_dailyCtrl.text.trim()) ?? 0,
      maxTotalDrawdown: double.tryParse(_totalCtrl.text.trim()) ?? 0,
    );
    await widget.controller.setPropFirmRules(next);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Prop-firm rules saved.')));
    }
  }

  Future<void> _disable() async {
    await widget.controller.setPropFirmRules(
      widget.controller.propFirmRules.copyWith(enabled: false),
    );
    if (mounted) setState(() {});
  }

  /// Sprint 6.4 — Apply a known prop-firm preset.
  Future<void> _applyPreset(_PropFirmPreset p) async {
    setState(() {
      _firmCtrl.text = p.firmName;
      _dailyCtrl.text = p.maxDailyDrawdown > 0
          ? p.maxDailyDrawdown.toStringAsFixed(0)
          : '';
      _totalCtrl.text = p.maxTotalDrawdown > 0
          ? p.maxTotalDrawdown.toStringAsFixed(0)
          : '';
    });
    await widget.controller.setPropFirmRules(
      PropFirmRules(
        enabled: true,
        firmName: p.firmName,
        maxDailyDrawdown: p.maxDailyDrawdown,
        maxTotalDrawdown: p.maxTotalDrawdown,
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${p.firmName} preset applied.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.controller.propFirmRules;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel, color: context.c.textSecondary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Prop-Firm Drawdown Rules',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Switch.adaptive(
                value: r.enabled,
                onChanged: (v) async {
                  if (v) {
                    await _save();
                  } else {
                    await _disable();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Mirror your prop firm\'s rules. Dashboard will warn when 70%+ '
            'of any limit is consumed.',
            style: TextStyle(color: context.c.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Text(
            'Presets',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.c.textTertiary,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _PropFirmPreset.presets.map((p) {
              final selected =
                  r.firmName.toLowerCase() == p.firmName.toLowerCase();
              return ActionChip(
                label: Text(p.firmName),
                avatar: selected
                    ? const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppTheme.accent,
                      )
                    : null,
                backgroundColor: selected
                    ? AppTheme.accent.withValues(alpha: 0.15)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: selected ? AppTheme.accent : context.c.border,
                    width: selected ? 1.2 : 1,
                  ),
                ),
                onPressed: () => _applyPreset(p),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _firmCtrl,
            decoration: const InputDecoration(
              labelText: 'Firm name (optional)',
              hintText: 'e.g. FTMO, MFF, Topstep',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _dailyCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Max daily loss (USD)',
              hintText: 'e.g. 1000',
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _totalCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Max total / trailing drawdown (USD)',
              hintText: 'e.g. 2000',
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Save rules'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sprint 4.2 — Weekly risk budget editor. Lets the trader opt in to
/// R-budget enforcement, configure 1R size and weekly budget in R-units.
class _WeeklyRiskBudgetSettingsCard extends StatefulWidget {
  const _WeeklyRiskBudgetSettingsCard({required this.controller});
  final TradingScreenViewModel controller;

  @override
  State<_WeeklyRiskBudgetSettingsCard> createState() =>
      _WeeklyRiskBudgetSettingsCardState();
}

class _WeeklyRiskBudgetSettingsCardState
    extends State<_WeeklyRiskBudgetSettingsCard> {
  late TextEditingController _rUnitCtrl;
  late TextEditingController _budgetCtrl;

  @override
  void initState() {
    super.initState();
    final b = widget.controller.weeklyRiskBudget;
    _rUnitCtrl = TextEditingController(text: b.rUnitUsd.toStringAsFixed(0));
    _budgetCtrl = TextEditingController(
      text: b.weeklyBudgetR.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _rUnitCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _save({required bool enabled}) async {
    final next = WeeklyRiskBudget(
      enabled: enabled,
      rUnitUsd: double.tryParse(_rUnitCtrl.text.trim()) ?? 0,
      weeklyBudgetR: double.tryParse(_budgetCtrl.text.trim()) ?? 0,
    );
    await widget.controller.setWeeklyRiskBudget(next);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Weekly risk budget enabled.'
                : 'Weekly risk budget disabled.',
          ),
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.controller.weeklyRiskBudget;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: context.c.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Weekly Risk Budget',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Switch.adaptive(
                value: b.enabled,
                onChanged: (v) => _save(enabled: v),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Think in R-units per week, not per trade. When the budget hits '
            '100%, new trades auto-log as paper-only until next Monday.',
            style: TextStyle(color: context.c.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _rUnitCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: '1R size (USD)',
                    prefixText: '\$ ',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _budgetCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Budget (R / week)',
                    suffixText: 'R',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => _save(enabled: true),
              child: const Text('Save budget'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sprint 4.4 — News blackout toggle. When enabled, the journal log button
/// blocks new trades within ±15 min of a high-impact economic event.
class _NewsBlackoutCard extends StatelessWidget {
  const _NewsBlackoutCard({required this.controller});
  final TradingScreenViewModel controller;

  @override
  Widget build(BuildContext context) {
    final on = controller.blockTradesAroundNews;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign, color: context.c.textSecondary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Block trades around news',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Switch.adaptive(
                value: on,
                onChanged: (v) async {
                  await controller.setBlockTradesAroundNews(v);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          v
                              ? 'News blackout enabled (±15 min).'
                              : 'News blackout disabled.',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Uses Forex Factory\'s free high-impact calendar. New trades will '
            'be blocked within ±15 minutes of NFP, CPI, FOMC, etc.',
            style: TextStyle(color: context.c.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Sprint 5.2 — Encrypted local-file backup.
/// Exports the entire AppState as a PIN-encrypted blob (AES-GCM /
/// PBKDF2-HMAC-SHA256 200k) and hands it to the OS share sheet so the
/// user can save it to Drive/iCloud/email — $0/month, no OAuth.
class _CloudBackupCard extends StatelessWidget {
  const _CloudBackupCard({required this.controller});
  final TradingScreenViewModel controller;

  Future<void> _exportBackup(BuildContext context) async {
    final pin = await _askPin(
      context,
      title: 'Set backup PIN',
      message:
          'Pick a PIN (≥4 chars). You will need it to restore. We do NOT store this PIN — if you forget it, the backup is unrecoverable.',
    );
    if (pin == null) return;
    try {
      await CloudBackupService().exportEncryptedBackup(
        state: controller.state,
        pin: pin,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup ready — share it to Drive/iCloud.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Backup failed: $e')));
      }
    }
  }

  Future<void> _restoreBackup(BuildContext context) async {
    final result = await fp.FilePicker.pickFiles(
      type: fp.FileType.any,
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) return;
    if (!context.mounted) return;

    final pin = await _askPin(
      context,
      title: 'Enter backup PIN',
      message: 'Type the PIN you used when creating this backup.',
    );
    if (pin == null) return;
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Replace local data?'),
        content: const Text(
          'This will overwrite your current trades, settings, and balance with '
          'the backup contents. The integrity log is preserved and a '
          '"Restored backup" event will be appended.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final restored = await CloudBackupService().importEncryptedBackup(
        file: File(result.files.single.path!),
        pin: pin,
      );
      await controller.restoreFromBackup(restored);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Backup restored.')));
      }
    } on BackupAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
      }
    }
  }

  Future<String?> _askPin(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final ctrl = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'PIN',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (pin == null || pin.length < 4) return null;
    return pin;
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                color: context.c.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Encrypted Backup',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Export an AES-GCM-encrypted snapshot of your trades + settings. '
            'Save it to your own Drive/iCloud via the share sheet. Restore '
            'with the same PIN. Zero servers, zero subscriptions.',
            style: TextStyle(color: context.c.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _exportBackup(context),
                  icon: const Icon(Icons.ios_share, size: 16),
                  label: const Text('Export'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _restoreBackup(context),
                  icon: const Icon(Icons.restore, size: 16),
                  label: const Text('Restore'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sprint 5.3 — Local-only AI mode toggle. When ON, no Gemini cloud
/// calls are made; AI Coach + weekly digest fall back to rule-based
/// insights computed entirely on-device.
class _LocalOnlyAiCard extends StatelessWidget {
  const _LocalOnlyAiCard({required this.controller});
  final TradingScreenViewModel controller;

  @override
  Widget build(BuildContext context) {
    final on = controller.localOnlyAiMode;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                on ? Icons.shield : Icons.shield_outlined,
                color: on ? AppTheme.green : context.c.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Privacy: Local-Only AI Mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Switch(
                value: on,
                onChanged: (v) async {
                  await controller.setLocalOnlyAiMode(v);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          v
                              ? 'Local-only AI ON. No trades will be sent to Google.'
                              : 'Local-only AI OFF. AI Coach + weekly digest can now use Gemini.',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            on
                ? 'No cloud AI calls. AI Coach + weekly digest run on-device using rule-based insights only. Your trades never leave this phone.'
                : 'AI Coach + weekly digest may send compressed trade data to Gemini for phrasing. Turn this ON to keep all data local.',
            style: TextStyle(color: context.c.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Sprint 5.4 — Institutional PDF tear sheet export.
/// User picks a date range, app generates a PDF with KPIs + equity
/// curve + trade log and hands it to the OS share sheet.
class _TearSheetCard extends StatefulWidget {
  const _TearSheetCard({required this.controller});
  final TradingScreenViewModel controller;

  @override
  State<_TearSheetCard> createState() => _TearSheetCardState();
}

class _TearSheetCardState extends State<_TearSheetCard> {
  late DateTimeRange _range = _defaultRange();
  bool _busy = false;

  DateTimeRange _defaultRange() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month - 1, now.day),
      end: now,
    );
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      await const PdfReportService().exportTearSheet(
        state: widget.controller.state,
        startDate: _fmt(_range.start),
        endDate: _fmt(_range.end),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tear sheet ready — share it.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.picture_as_pdf_outlined,
                color: context.c.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Performance Tear Sheet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Institutional PDF report: KPIs (win rate, profit factor, max '
            'drawdown, Sharpe), equity curve, full trade log. Save or email '
            'to accountants/investors.',
            style: TextStyle(color: context.c.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _busy ? null : _pickRange,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: context.c.border),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.date_range,
                    size: 16,
                    color: context.c.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_fmt(_range.start)}  →  ${_fmt(_range.end)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    'Change',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _busy ? null : _export,
              icon: _busy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share, size: 16),
              label: Text(_busy ? 'Generating…' : 'Export tear sheet'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sprint 6.3 — Configurable daily trade cap.
/// Exposes a 1/2/3/5 segmented selector. The cap drives auto-gate G8,
/// the readiness score, the "max trades reached" insight, the lock-on-2-losses
/// rule, and the dashboard chip.
class _DailyTradeCapCard extends StatelessWidget {
  const _DailyTradeCapCard({required this.controller});
  final TradingScreenViewModel controller;

  @override
  Widget build(BuildContext context) {
    final current = controller.dailyTradeCap;
    const choices = [1, 2, 3, 5];
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_list_numbered,
                color: context.c.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Daily Trade Limit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$current/day',
                style: TextStyle(
                  color: context.c.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Caps how many trades you can log per day. Drives the readiness '
            'score, the trade-slot gate, and the lock-after-consecutive-losses '
            'rule. Default 2 — pros can raise it.',
            style: TextStyle(color: context.c.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: choices.map((n) {
              final selected = n == current;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: n == choices.last ? 0 : 8),
                  child: InkWell(
                    onTap: () async {
                      if (selected) return;
                      await controller.setDailyTradeCap(n);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Daily cap set to $n trades.'),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.accent.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? AppTheme.accent : context.c.border,
                          width: selected ? 1.4 : 1.0,
                        ),
                      ),
                      child: Text(
                        '$n',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: selected ? AppTheme.accent : context.c.text,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Sprint 6.4 \u2014 Prop firm preset.
/// Common challenge defaults for one-tap configuration. The user can
/// still override every field manually after applying.
class _PropFirmPreset {
  const _PropFirmPreset({
    required this.firmName,
    required this.maxDailyDrawdown,
    required this.maxTotalDrawdown,
  });

  final String firmName;
  final double maxDailyDrawdown;
  final double maxTotalDrawdown;

  /// Built-in presets sized for the canonical 100k challenge.
  /// Numbers reflect the public rule pages as of 2026-Q1; users with
  /// different account sizes should tap the preset and edit the values.
  static const List<_PropFirmPreset> presets = [
    _PropFirmPreset(
      firmName: 'FTMO',
      maxDailyDrawdown: 5000,
      maxTotalDrawdown: 10000,
    ),
    _PropFirmPreset(
      firmName: 'Topstep',
      maxDailyDrawdown: 2000,
      maxTotalDrawdown: 3000,
    ),
    _PropFirmPreset(
      firmName: 'MyForexFunds',
      maxDailyDrawdown: 5000,
      maxTotalDrawdown: 12000,
    ),
    _PropFirmPreset(
      firmName: 'The5ers',
      maxDailyDrawdown: 5000,
      maxTotalDrawdown: 10000,
    ),
    _PropFirmPreset(
      firmName: 'Custom',
      maxDailyDrawdown: 0,
      maxTotalDrawdown: 0,
    ),
  ];
}

/// Sprint 6.5 — Multi-account management.
/// Lists every account the user has created, marks the active one, and
/// exposes switch / rename / delete / "add account" actions. Each account
/// owns its own trades, balance, lock, drawdown rules, and risk budget.
class _AccountsCard extends StatelessWidget {
  const _AccountsCard({required this.controller});
  final TradingScreenViewModel controller;

  Future<void> _addAccount(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Each account has its own trades, balance, lock, and drawdown '
              'rules. Your current state will be preserved as "Personal" the '
              'first time you create a second account.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Account name',
                hintText: 'e.g. FTMO 100k',
                border: OutlineInputBorder(),
              ),
              maxLength: 30,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    nameCtrl.dispose();
    if (name == null || name.isEmpty) return;
    await controller.createAccount(name);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Switched to "$name".')));
    }
  }

  Future<void> _renameAccount(BuildContext context, TradingAccount a) async {
    final ctrl = TextEditingController(text: a.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename account'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Account name',
            border: OutlineInputBorder(),
          ),
          maxLength: 30,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (name == null || name.isEmpty || name == a.name) return;
    await controller.renameAccount(a.id, name);
  }

  Future<void> _deleteAccount(BuildContext context, TradingAccount a) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${a.name}"?'),
        content: Text(
          'This permanently removes the account and its '
          '${a.allTrades.length} trade${a.allTrades.length == 1 ? '' : 's'}. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await controller.deleteAccount(a.id);
  }

  @override
  Widget build(BuildContext context) {
    final accounts = controller.accounts;
    final activeId = controller.activeAccountId;
    final hasMulti = accounts.isNotEmpty;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: context.c.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Accounts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (hasMulti)
                Text(
                  '${accounts.length}',
                  style: TextStyle(
                    color: context.c.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            hasMulti
                ? 'Switch between accounts. Each one has its own trades, '
                      'balance, lock, drawdown rules, and risk budget.'
                : 'Run multiple challenges side-by-side. Tap "Add account" '
                      'to create a separate slot — your current state will be '
                      'preserved as "Personal".',
            style: TextStyle(color: context.c.textSecondary, fontSize: 12),
          ),
          if (hasMulti) ...[
            const SizedBox(height: 12),
            ...accounts.map((a) {
              final selected = a.id == activeId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  onTap: selected
                      ? null
                      : () async {
                          await controller.switchAccount(a.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Switched to "${a.name}".'),
                              ),
                            );
                          }
                        },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.accent.withValues(alpha: 0.10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected ? AppTheme.accent : context.c.border,
                        width: selected ? 1.3 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: selected
                              ? AppTheme.accent
                              : context.c.textTertiary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '\$${a.balance.toStringAsFixed(0)} · ${a.allTrades.length} trade${a.allTrades.length == 1 ? '' : 's'}'
                                '${a.lock ? ' · locked' : ''}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.c.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          tooltip: 'Rename',
                          onPressed: () => _renameAccount(context, a),
                        ),
                        if (!selected)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            tooltip: 'Delete',
                            onPressed: () => _deleteAccount(context, a),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _addAccount(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add account'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Local-notification preferences. Master kill-switch + per-category
/// toggles for every reactive and recurring push the app produces.
class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard({required this.controller});
  final TradingScreenViewModel controller;

  Future<void> _save(NotificationPrefs next) async {
    await controller.setNotificationPrefs(next);
    // Re-apply recurring schedules whenever prefs change.
    if (next.master && next.moodReminder) {
      await NotificationCenter.instance.scheduleDailyMoodReminder();
    } else {
      await NotificationCenter.instance.cancelMoodReminder();
    }
    if (next.master && next.backupReminder) {
      await NotificationCenter.instance.scheduleSundayBackupReminder();
    } else {
      await NotificationCenter.instance.cancelBackupReminder();
    }
    if (!next.master) {
      await NotificationCenter.instance.cancelAllReactive();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = controller.state.notificationPrefs;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: context.c.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Switch.adaptive(
                value: p.master,
                onChanged: (v) async {
                  if (v) {
                    await NotificationCenter.instance.requestPermissions();
                  }
                  await _save(p.copyWith(master: v));
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'All notifications are on-device. Nothing is sent to a server.',
            style: TextStyle(color: context.c.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Opacity(
            opacity: p.master ? 1.0 : 0.45,
            child: IgnorePointer(
              ignoring: !p.master,
              child: Column(
                children: [
                  _NotificationToggle(
                    title: 'Drawdown danger',
                    subtitle: 'Fires when daily/total drawdown crosses 70%.',
                    value: p.drawdown,
                    onChanged: (v) => _save(p.copyWith(drawdown: v)),
                  ),
                  _NotificationToggle(
                    title: 'Weekly risk budget',
                    subtitle: 'Warns at 80% used, alerts again at 100%.',
                    value: p.riskBudget,
                    onChanged: (v) => _save(p.copyWith(riskBudget: v)),
                  ),
                  _NotificationToggle(
                    title: 'Account locked',
                    subtitle: 'Confirms when auto-lock engages after losses.',
                    value: p.lock,
                    onChanged: (v) => _save(p.copyWith(lock: v)),
                  ),
                  _NotificationToggle(
                    title: 'Loss streak',
                    subtitle: '3+ losers in a row → step away.',
                    value: p.streak,
                    onChanged: (v) => _save(p.copyWith(streak: v)),
                  ),
                  _NotificationToggle(
                    title: 'Daily trade cap',
                    subtitle: 'Tells you when you\'ve hit your trade limit.',
                    value: p.dailyCap,
                    onChanged: (v) => _save(p.copyWith(dailyCap: v)),
                  ),
                  _NotificationToggle(
                    title: 'High-impact news',
                    subtitle: 'Heads-up before NFP / CPI / FOMC prints.',
                    value: p.newsImminent,
                    onChanged: (v) => _save(p.copyWith(newsImminent: v)),
                  ),
                  const Divider(height: 24),
                  _NotificationToggle(
                    title: 'Morning mood check-in',
                    subtitle: 'Daily 08:30 EAT reminder to log your state.',
                    value: p.moodReminder,
                    onChanged: (v) => _save(p.copyWith(moodReminder: v)),
                  ),
                  _NotificationToggle(
                    title: 'Weekly backup reminder',
                    subtitle: 'Sunday 19:00 EAT — export an encrypted backup.',
                    value: p.backupReminder,
                    onChanged: (v) => _save(p.copyWith(backupReminder: v)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: context.c.textSecondary, fontSize: 12),
      ),
      dense: true,
    );
  }
}
