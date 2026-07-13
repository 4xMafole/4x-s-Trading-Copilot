import 'package:flutter/material.dart';

import '../data/models.dart';

/// Screen for managing pre-trade gates (CRUD, reorder, template selection).
class GateManagementScreen extends StatefulWidget {
  const GateManagementScreen({
    super.key,
    required this.currentGates,
    required this.onSave,
  });

  final List<UserGate> currentGates;
  final ValueChanged<List<UserGate>> onSave;

  @override
  State<GateManagementScreen> createState() => _GateManagementScreenState();
}

class _GateManagementScreenState extends State<GateManagementScreen> {
  late List<UserGate> _gates;

  @override
  void initState() {
    super.initState();
    _gates = List.of(widget.currentGates);
    if (_gates.isEmpty) {
      // Convert legacy kGates to UserGate format
      _gates = kGates.asMap().entries.map((e) {
        final g = e.value;
        return UserGate(
          id: g.id,
          auto: g.auto,
          label: g.label,
          sub: g.sub,
          symbols: g.symbols,
          sortOrder: e.key,
        );
      }).toList();
    }
  }

  void _addGate() {
    final id = 'ug_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _gates.add(
        UserGate(
          id: id,
          label: 'New gate',
          sub: 'Describe the rule...',
          sortOrder: _gates.length,
        ),
      );
    });
    _editGate(_gates.length - 1);
  }

  void _editGate(int index) async {
    final gate = _gates[index];
    final result = await showDialog<UserGate>(
      context: context,
      builder: (ctx) => _GateEditDialog(gate: gate),
    );
    if (result != null) {
      setState(() => _gates[index] = result);
    }
  }

  void _deleteGate(int index) {
    setState(() => _gates.removeAt(index));
  }

  void _applyTemplate(String templateName) {
    final template = _templates[templateName];
    if (template == null) return;
    setState(() {
      _gates = template.asMap().entries.map((e) {
        final g = e.value;
        return UserGate(
          id: 'tpl_${templateName}_${e.key}',
          auto: false,
          label: g.$1,
          sub: g.$2,
          sortOrder: e.key,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pre-Trade Gates'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.dashboard_customize),
            tooltip: 'Load template',
            onSelected: _applyTemplate,
            itemBuilder: (ctx) => _templates.keys
                .map((k) => PopupMenuItem(value: k, child: Text(k)))
                .toList(),
          ),
          TextButton(
            onPressed: () {
              widget.onSave(_gates);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGate,
        child: const Icon(Icons.add),
      ),
      body: _gates.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.checklist,
                    size: 48,
                    color: theme.colorScheme.onSurface.withAlpha(80),
                  ),
                  const SizedBox(height: 12),
                  const Text('No gates configured'),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: _addGate,
                    child: const Text('Add your first gate'),
                  ),
                ],
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: _gates.length,
              onReorder: (old, newIdx) {
                setState(() {
                  if (newIdx > old) newIdx--;
                  final item = _gates.removeAt(old);
                  _gates.insert(newIdx, item);
                  // Re-assign sort orders
                  for (int i = 0; i < _gates.length; i++) {
                    _gates[i] = _gates[i].copyWith(sortOrder: i);
                  }
                });
              },
              itemBuilder: (context, i) {
                final gate = _gates[i];
                return Dismissible(
                  key: ValueKey(gate.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.red.withAlpha(40),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  onDismissed: (_) => _deleteGate(i),
                  child: Card(
                    key: ValueKey('card_${gate.id}'),
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      leading: Icon(
                        gate.auto
                            ? Icons.auto_awesome
                            : Icons.check_box_outlined,
                        color: gate.auto
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.primary,
                        size: 20,
                      ),
                      title: Text(
                        gate.label,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: gate.sub.isNotEmpty
                          ? Text(
                              gate.sub,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface.withAlpha(
                                  120,
                                ),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      trailing: ReorderableDragStartListener(
                        index: i,
                        child: const Icon(Icons.drag_handle),
                      ),
                      onTap: () => _editGate(i),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _GateEditDialog extends StatefulWidget {
  const _GateEditDialog({required this.gate});
  final UserGate gate;

  @override
  State<_GateEditDialog> createState() => _GateEditDialogState();
}

class _GateEditDialogState extends State<_GateEditDialog> {
  late final TextEditingController _labelCtrl;
  late final TextEditingController _subCtrl;
  late final TextEditingController _symbolsCtrl;
  late bool _auto;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.gate.label);
    _subCtrl = TextEditingController(text: widget.gate.sub);
    _symbolsCtrl = TextEditingController(
      text: widget.gate.symbols?.join(', ') ?? '',
    );
    _auto = widget.gate.auto;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _subCtrl.dispose();
    _symbolsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Gate'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _labelCtrl,
              decoration: const InputDecoration(labelText: 'Gate label'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _symbolsCtrl,
              decoration: const InputDecoration(
                labelText: 'Symbols (optional)',
                hintText: 'XAUUSD, EURUSD (blank = all)',
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Auto-evaluated'),
              subtitle: const Text('System checks this automatically'),
              value: _auto,
              onChanged: (v) => setState(() => _auto = v),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final symbolsText = _symbolsCtrl.text.trim();
            final symbols = symbolsText.isEmpty
                ? null
                : symbolsText
                      .split(RegExp(r'[,\s]+'))
                      .map((s) => s.trim().toUpperCase())
                      .where((s) => s.isNotEmpty)
                      .toList();
            Navigator.pop(
              context,
              widget.gate.copyWith(
                label: _labelCtrl.text.trim(),
                sub: _subCtrl.text.trim(),
                symbols: symbols,
                auto: _auto,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Built-in gate templates matching the Supabase seed data.
const Map<String, List<(String, String)>> _templates = {
  'ICT': [
    (
      'HTF bias confirmed (H4/Daily)',
      'Identified and written — not from memory',
    ),
    ('Killzone window active', 'London or NY session, not Asian or dead zone'),
    ('Liquidity sweep confirmed', 'Price swept significant high/low'),
    ('Market structure shift on LTF', 'M5 or M15 BOS — not just a wick'),
    ('OTE zone reached (0.618-0.786)', 'Price in optimal trade entry zone'),
    (
      'FVG / Order Block identified',
      'Entry point has institutional confluence',
    ),
    ('Risk calculated', 'Used calculator — lot size confirmed'),
    ('R:R minimum 1:2', 'Reward-to-risk ratio confirmed before entry'),
  ],
  'SMC': [
    ('HTF trend identified', 'Clear trend on H4 or Daily'),
    ('Change of Character (CHoCH)', 'Confirmed structural break'),
    ('Point of Interest (POI) marked', 'OB, FVG, or liquidity zone'),
    ('Inducement taken', 'Liquidity grab before reversal'),
    ('LTF confirmation', 'Entry trigger on M5/M15'),
    ('Risk per trade calculated', 'Within daily risk budget'),
    ('TP set at opposing liquidity', 'Target at next significant level'),
    ('No upcoming high-impact news', 'Clear news window 15+ min'),
  ],
  'Supply & Demand': [
    ('Fresh zone identified', 'Untested supply or demand zone'),
    ('Trend alignment', 'Zone aligns with higher-TF trend'),
    ('Arrival pattern confirmed', 'Strong momentum into zone'),
    ('Zone quality rated', 'Strength of departure + time at level'),
    ('Entry at zone edge', 'Not chasing — entering at zone boundary'),
    ('SL beyond zone', 'Stop placed outside the zone boundary'),
    ('R:R minimum 1:2', 'Target at opposing zone or key level'),
  ],
  'Price Action': [
    ('Key level identified', 'Support/resistance on H4 or Daily'),
    ('Candlestick signal at level', 'Pin bar, engulfing, or inside bar'),
    ('Trend alignment', 'Signal aligns with higher-TF direction'),
    ('Volume confirmation', 'Above-average volume on signal candle'),
    ('No immediate resistance/support', 'Clear path to target'),
    ('Risk calculated and sized', 'Position size matches risk budget'),
    ('Entry on pullback or retest', 'Not chasing breakout'),
  ],
};
