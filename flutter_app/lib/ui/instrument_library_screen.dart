import 'package:flutter/material.dart';

import '../data/models.dart';

/// Full instrument catalog with categories. Users pick instruments to add
/// to their personal watchlist (stored in AppState.userInstruments).
class InstrumentLibraryScreen extends StatefulWidget {
  const InstrumentLibraryScreen({
    super.key,
    required this.currentInstruments,
    required this.onSave,
  });

  /// Currently selected instrument symbols.
  final Map<String, Instrument> currentInstruments;

  /// Called with the updated instrument map when the user taps Save.
  final ValueChanged<Map<String, Instrument>> onSave;

  @override
  State<InstrumentLibraryScreen> createState() =>
      _InstrumentLibraryScreenState();
}

class _InstrumentLibraryScreenState extends State<InstrumentLibraryScreen> {
  late final Map<String, Instrument> _selected;
  String _search = '';
  String? _activeCategory;

  @override
  void initState() {
    super.initState();
    _selected = Map.of(widget.currentInstruments);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _activeCategory != null
        ? _allInstruments.entries
              .where((e) => e.value.category == _activeCategory)
              .toList()
        : _allInstruments.entries.toList();

    final searchFiltered = _search.isEmpty
        ? filtered
        : filtered
              .where(
                (e) =>
                    e.key.toLowerCase().contains(_search.toLowerCase()) ||
                    e.value.desc.toLowerCase().contains(_search.toLowerCase()),
              )
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instrument Library'),
        actions: [
          TextButton(
            onPressed: () {
              widget.onSave(_selected);
              Navigator.pop(context);
            },
            child: Text('Save (${_selected.length})'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search instruments...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(height: 8),

          // Category chips
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip(
                  label: 'All',
                  selected: _activeCategory == null,
                  onTap: () => setState(() => _activeCategory = null),
                ),
                ..._categories.map(
                  (cat) => _CategoryChip(
                    label: cat.label,
                    selected: _activeCategory == cat.id,
                    onTap: () => setState(() => _activeCategory = cat.id),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Instrument list
          Expanded(
            child: ListView.builder(
              itemCount: searchFiltered.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, i) {
                final entry = searchFiltered[i];
                final sym = entry.key;
                final inst = entry.value;
                final isSelected = _selected.containsKey(sym);
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withAlpha(80),
                  ),
                  title: Text(
                    sym,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    inst.desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withAlpha(120),
                    ),
                  ),
                  trailing: Text(
                    inst.category,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withAlpha(80),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selected.remove(sym);
                      } else {
                        _selected[sym] = inst;
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _InstrumentCategory {
  const _InstrumentCategory(this.id, this.label);
  final String id;
  final String label;
}

const _categories = [
  _InstrumentCategory('forex_major', 'Forex Majors'),
  _InstrumentCategory('forex_minor', 'Forex Minors'),
  _InstrumentCategory('forex_exotic', 'Forex Exotics'),
  _InstrumentCategory('indices', 'Indices'),
  _InstrumentCategory('commodities', 'Commodities'),
  _InstrumentCategory('crypto', 'Crypto'),
  _InstrumentCategory('stocks', 'Stocks'),
];

/// Master catalog of instruments available in LocoTrader.
const Map<String, Instrument> _allInstruments = {
  // ── Forex Majors ──
  'EURUSD': Instrument(
    unit: 'pips',
    pipVal: 1,
    desc: 'Euro / US Dollar',
    category: 'forex_major',
  ),
  'GBPUSD': Instrument(
    unit: 'pips',
    pipVal: 1,
    desc: 'British Pound / US Dollar',
    category: 'forex_major',
  ),
  'USDJPY': Instrument(
    unit: 'pips',
    pipVal: 0.67,
    desc: 'US Dollar / Japanese Yen',
    category: 'forex_major',
  ),
  'USDCHF': Instrument(
    unit: 'pips',
    pipVal: 1,
    desc: 'US Dollar / Swiss Franc',
    category: 'forex_major',
  ),
  'AUDUSD': Instrument(
    unit: 'pips',
    pipVal: 1,
    desc: 'Australian Dollar / US Dollar',
    category: 'forex_major',
  ),
  'USDCAD': Instrument(
    unit: 'pips',
    pipVal: 0.73,
    desc: 'US Dollar / Canadian Dollar',
    category: 'forex_major',
  ),
  'NZDUSD': Instrument(
    unit: 'pips',
    pipVal: 1,
    desc: 'New Zealand Dollar / US Dollar',
    category: 'forex_major',
  ),

  // ── Forex Minors ──
  'EURGBP': Instrument(
    unit: 'pips',
    pipVal: 1.27,
    desc: 'Euro / British Pound',
    category: 'forex_minor',
  ),
  'EURJPY': Instrument(
    unit: 'pips',
    pipVal: 0.67,
    desc: 'Euro / Japanese Yen',
    category: 'forex_minor',
  ),
  'GBPJPY': Instrument(
    unit: 'pips',
    pipVal: 0.67,
    desc: 'British Pound / Japanese Yen',
    category: 'forex_minor',
  ),
  'EURCHF': Instrument(
    unit: 'pips',
    pipVal: 1,
    desc: 'Euro / Swiss Franc',
    category: 'forex_minor',
  ),
  'EURAUD': Instrument(
    unit: 'pips',
    pipVal: 0.65,
    desc: 'Euro / Australian Dollar',
    category: 'forex_minor',
  ),
  'GBPAUD': Instrument(
    unit: 'pips',
    pipVal: 0.65,
    desc: 'British Pound / Australian Dollar',
    category: 'forex_minor',
  ),
  'GBPCAD': Instrument(
    unit: 'pips',
    pipVal: 0.73,
    desc: 'British Pound / Canadian Dollar',
    category: 'forex_minor',
  ),
  'AUDCAD': Instrument(
    unit: 'pips',
    pipVal: 0.73,
    desc: 'Australian Dollar / Canadian Dollar',
    category: 'forex_minor',
  ),
  'AUDNZD': Instrument(
    unit: 'pips',
    pipVal: 0.60,
    desc: 'Australian Dollar / New Zealand Dollar',
    category: 'forex_minor',
  ),
  'CADJPY': Instrument(
    unit: 'pips',
    pipVal: 0.67,
    desc: 'Canadian Dollar / Japanese Yen',
    category: 'forex_minor',
  ),

  // ── Forex Exotics ──
  'USDMXN': Instrument(
    unit: 'pips',
    pipVal: 0.05,
    desc: 'US Dollar / Mexican Peso',
    category: 'forex_exotic',
  ),
  'USDZAR': Instrument(
    unit: 'pips',
    pipVal: 0.05,
    desc: 'US Dollar / South African Rand',
    category: 'forex_exotic',
  ),
  'USDTRY': Instrument(
    unit: 'pips',
    pipVal: 0.03,
    desc: 'US Dollar / Turkish Lira',
    category: 'forex_exotic',
  ),
  'EURTRY': Instrument(
    unit: 'pips',
    pipVal: 0.03,
    desc: 'Euro / Turkish Lira',
    category: 'forex_exotic',
  ),

  // ── Indices ──
  'NAS100': Instrument(
    unit: 'points',
    pipVal: 1,
    desc: 'Nasdaq 100 Index',
    category: 'indices',
  ),
  'NQ': Instrument(
    unit: 'points',
    pipVal: 2,
    desc: 'Nasdaq 100 (NQ Futures)',
    category: 'indices',
  ),
  'US500': Instrument(
    unit: 'points',
    pipVal: 1,
    desc: 'S&P 500 Index',
    category: 'indices',
  ),
  'US30': Instrument(
    unit: 'points',
    pipVal: 1,
    desc: 'Dow Jones 30',
    category: 'indices',
  ),
  'GER40': Instrument(
    unit: 'points',
    pipVal: 1,
    desc: 'DAX 40 (Germany)',
    category: 'indices',
  ),
  'UK100': Instrument(
    unit: 'points',
    pipVal: 1,
    desc: 'FTSE 100 (UK)',
    category: 'indices',
  ),
  'JPN225': Instrument(
    unit: 'points',
    pipVal: 0.67,
    desc: 'Nikkei 225 (Japan)',
    category: 'indices',
  ),

  // ── Commodities ──
  'XAUUSD': Instrument(
    unit: r'$ price move',
    pipVal: 1,
    desc: 'Gold / US Dollar',
    category: 'commodities',
  ),
  'XAGUSD': Instrument(
    unit: r'$ price move',
    pipVal: 50,
    desc: 'Silver / US Dollar',
    category: 'commodities',
  ),
  'USOIL': Instrument(
    unit: r'$ price move',
    pipVal: 10,
    desc: 'Crude Oil (WTI)',
    category: 'commodities',
  ),
  'UKOIL': Instrument(
    unit: r'$ price move',
    pipVal: 10,
    desc: 'Crude Oil (Brent)',
    category: 'commodities',
  ),
  'NATGAS': Instrument(
    unit: r'$ price move',
    pipVal: 10,
    desc: 'Natural Gas',
    category: 'commodities',
  ),

  // ── Crypto ──
  'BTCUSD': Instrument(
    unit: r'$ price move',
    pipVal: 1,
    desc: 'Bitcoin / US Dollar',
    category: 'crypto',
  ),
  'ETHUSD': Instrument(
    unit: r'$ price move',
    pipVal: 1,
    desc: 'Ethereum / US Dollar',
    category: 'crypto',
  ),
  'SOLUSD': Instrument(
    unit: r'$ price move',
    pipVal: 1,
    desc: 'Solana / US Dollar',
    category: 'crypto',
  ),
  'XRPUSD': Instrument(
    unit: r'$ price move',
    pipVal: 1,
    desc: 'Ripple / US Dollar',
    category: 'crypto',
  ),
  'BNBUSD': Instrument(
    unit: r'$ price move',
    pipVal: 1,
    desc: 'BNB / US Dollar',
    category: 'crypto',
  ),
  'ADAUSD': Instrument(
    unit: r'$ price move',
    pipVal: 1,
    desc: 'Cardano / US Dollar',
    category: 'crypto',
  ),
  'DOGEUSD': Instrument(
    unit: r'$ price move',
    pipVal: 1,
    desc: 'Dogecoin / US Dollar',
    category: 'crypto',
  ),

  // ── Stocks ──
  'AAPL': Instrument(
    unit: r'$ price move',
    pipVal: 1,
    desc: 'Apple Inc.',
    category: 'stocks',
  ),
  'MSFT': Instrument(
    unit: r'$ price move',
    pipVal: 1,
    desc: 'Microsoft Corp.',
    category: 'stocks',
  ),
  'GOOGL': Instrument(
    unit: r'$ price move',
    pipVal: 1,
    desc: 'Alphabet (Google)',
    category: 'stocks',
  ),
  'AMZN': Instrument(
    unit: r'$ price move',
    pipVal: 1,
    desc: 'Amazon.com Inc.',
    category: 'stocks',
  ),
  'TSLA': Instrument(
    unit: r'$ price move',
    pipVal: 1,
    desc: 'Tesla Inc.',
    category: 'stocks',
  ),
  'NVDA': Instrument(
    unit: r'$ price move',
    pipVal: 1,
    desc: 'NVIDIA Corp.',
    category: 'stocks',
  ),
  'META': Instrument(
    unit: r'$ price move',
    pipVal: 1,
    desc: 'Meta Platforms',
    category: 'stocks',
  ),
};
