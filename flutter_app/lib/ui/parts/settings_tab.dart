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
                    onPressed: c.resetToday,
                    child: const Text('Reset today'),
                  ),
                  OutlinedButton(
                    onPressed: c.resetAll,
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
      ],
    );
  }
}
