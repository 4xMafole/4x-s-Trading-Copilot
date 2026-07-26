import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models.dart';
import '../logic/cubits/trading_core_cubit.dart';
import '../services/supabase/auth_service.dart';
import '../services/supabase/trade_repository.dart';

/// Post-signup onboarding: quick quiz → pick strategy template → setup.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});
  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  // Quiz answers
  String? _experience;
  String? _primaryMarket;
  String? _strategyTemplate;
  String _timezone = 'UTC';
  final Set<String> _selectedInstruments = {};
  // Step 5: Risk management
  final _balanceCtrl = TextEditingController();
  String _currency = 'USD';
  final _riskPctCtrl = TextEditingController(text: '1');
  final _riskUsdCtrl = TextEditingController();
  bool _useRiskPct = true; // toggle between % and fixed USD

  @override
  void dispose() {
    _balanceCtrl.dispose();
    _riskPctCtrl.dispose();
    _riskUsdCtrl.dispose();
    super.dispose();
  }

  static const _experiences = [
    ('beginner', 'Beginner', 'Less than 1 year trading'),
    ('intermediate', 'Intermediate', '1-3 years experience'),
    ('advanced', 'Advanced', '3+ years, consistent results'),
  ];

  static const _markets = [
    ('forex_majors', 'Forex', 'Currency pairs (EUR/USD, GBP/USD...)'),
    ('indices', 'Indices', 'NAS100, S&P500, DAX...'),
    ('crypto', 'Crypto', 'BTC, ETH, SOL...'),
    ('commodities', 'Commodities', 'Gold, Oil, Silver...'),
    ('stocks', 'Stocks', 'AAPL, TSLA, NVDA...'),
  ];

  static const _strategies = [
    ('ICT', 'ICT / Inner Circle', '8 gates: liquidity, MSS, OTE, killzones'),
    ('SMC', 'Smart Money Concepts', '8 gates: CHoCH, POI, inducement, FVG'),
    (
      'Supply/Demand',
      'Supply & Demand',
      '7 gates: fresh zones, trend, arrival',
    ),
    (
      'Price Action',
      'Price Action',
      '7 gates: key levels, signals, confluence',
    ),
    ('Custom', 'Build My Own', 'Start blank — create your own gates'),
  ];

  void _next() {
    if (_page < 4) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _page++);
    } else {
      _finish();
    }
  }

  bool get _canAdvance {
    switch (_page) {
      case 0:
        return _experience != null;
      case 1:
        return _primaryMarket != null;
      case 2:
        return _strategyTemplate != null;
      case 3:
        return true; // timezone always valid
      case 4:
        final balance = double.tryParse(_balanceCtrl.text) ?? 0;
        if (balance <= 0) return false;
        if (_useRiskPct) {
          final pct = double.tryParse(_riskPctCtrl.text) ?? 0;
          return pct > 0 && pct <= 10;
        } else {
          final usd = double.tryParse(_riskUsdCtrl.text) ?? 0;
          return usd > 0;
        }
      default:
        return false;
    }
  }

  Future<void> _finish() async {
    final balance = double.tryParse(_balanceCtrl.text) ?? 0;
    double riskCapUsd;
    if (_useRiskPct) {
      final pct = double.tryParse(_riskPctCtrl.text) ?? 1;
      riskCapUsd = balance * (pct / 100);
    } else {
      riskCapUsd = double.tryParse(_riskUsdCtrl.text) ?? 100;
    }
    riskCapUsd = riskCapUsd.clamp(1, 100000).toDouble();

    // ── 1. Wire choices into LOCAL AppState (drives the UI) ──
    final cubit = context.read<TradingCoreCubit>();

    await cubit.setUserTimezone(_timezone);
    await cubit.setUserInstruments(
      _instrumentsForMarket(_primaryMarket ?? 'forex_majors'),
    );
    if (_strategyTemplate != null && _strategyTemplate != 'Custom') {
      await cubit.setUserGates(_gatesForStrategy(_strategyTemplate!));
    }
    await cubit.setRiskCapUsd(riskCapUsd);
    // Set balance
    final today = DateTime.now();
    final startDate =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    await cubit.updateState(balance: balance, startDate: startDate);

    // ── 2. Try to save to Supabase (non-blocking) ──
    try {
      await AuthService.instance.updateProfile({
        'experience_level': _experience,
        'primary_market': _primaryMarket,
        'timezone': _timezone,
        'onboarding_completed': true,
      });

      if (_strategyTemplate != null && _strategyTemplate != 'Custom') {
        await TradeRepository.instance.createStrategy(
          name: _strategyTemplate!,
          templateSource: _strategyTemplate,
        );
      } else {
        await TradeRepository.instance.createStrategy(name: 'My Strategy');
      }
    } catch (e) {
      debugPrint('Onboarding DB error (non-fatal): $e');
    }

    widget.onComplete();
  }

  // ── Helpers: map onboarding choices to local data ──

  static Map<String, Instrument> _instrumentsForMarket(String market) {
    switch (market) {
      case 'forex_majors':
        return const {
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
        };
      case 'indices':
        return const {
          'NAS100': Instrument(
            unit: 'points',
            pipVal: 1,
            desc: 'Nasdaq 100 Index',
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
        };
      case 'crypto':
        return const {
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
        };
      case 'commodities':
        return const {
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
        };
      case 'stocks':
        return const {
          'AAPL': Instrument(
            unit: r'$ price move',
            pipVal: 1,
            desc: 'Apple Inc.',
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
          'MSFT': Instrument(
            unit: r'$ price move',
            pipVal: 1,
            desc: 'Microsoft Corp.',
            category: 'stocks',
          ),
        };
      default:
        return const {
          'EURUSD': Instrument(
            unit: 'pips',
            pipVal: 1,
            desc: 'Euro / US Dollar',
            category: 'forex_major',
          ),
          'XAUUSD': Instrument(
            unit: r'$ price move',
            pipVal: 1,
            desc: 'Gold / US Dollar',
            category: 'commodities',
          ),
          'NAS100': Instrument(
            unit: 'points',
            pipVal: 1,
            desc: 'Nasdaq 100 Index',
            category: 'indices',
          ),
          'BTCUSD': Instrument(
            unit: r'$ price move',
            pipVal: 1,
            desc: 'Bitcoin / US Dollar',
            category: 'crypto',
          ),
        };
    }
  }

  static List<UserGate> _gatesForStrategy(String template) {
    const templates = {
      'ICT': [
        (
          'HTF bias confirmed (H4/Daily)',
          'Identified and written — not from memory',
        ),
        ('Killzone window active', 'London or NY session, not dead zone'),
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
      'Supply/Demand': [
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

    final items = templates[template];
    if (items == null) return [];

    return items.asMap().entries.map((e) {
      return UserGate(
        id: 'tpl_${template.replaceAll('/', '_')}_${e.key}',
        label: e.value.$1,
        sub: e.value.$2,
        sortOrder: e.key,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: List.generate(5, (i) {
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: i <= _page
                            ? theme.colorScheme.primary
                            : theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),

            // ── Pages ──
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _QuizPage(
                    title: 'Your experience level',
                    subtitle:
                        'This helps us calibrate difficulty and suggestions.',
                    options: _experiences,
                    selected: _experience,
                    onSelect: (v) => setState(() => _experience = v),
                  ),
                  _QuizPage(
                    title: 'Primary market',
                    subtitle: 'Which instruments do you trade most?',
                    options: _markets,
                    selected: _primaryMarket,
                    onSelect: (v) => setState(() => _primaryMarket = v),
                  ),
                  _QuizPage(
                    title: 'Pre-trade strategy',
                    subtitle: 'Pick a gate template or start custom.',
                    options: _strategies,
                    selected: _strategyTemplate,
                    onSelect: (v) => setState(() => _strategyTemplate = v),
                  ),
                  _TimezonePage(
                    timezone: _timezone,
                    onChanged: (v) => setState(() => _timezone = v),
                  ),
                  _RiskSetupPage(
                    balanceCtrl: _balanceCtrl,
                    currency: _currency,
                    onCurrencyChanged: (v) => setState(() => _currency = v),
                    riskPctCtrl: _riskPctCtrl,
                    riskUsdCtrl: _riskUsdCtrl,
                    useRiskPct: _useRiskPct,
                    onToggleRiskMode: (v) => setState(() => _useRiskPct = v),
                    onChanged: () => setState(() {}),
                  ),
                ],
              ),
            ),

            // ── Navigation ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  if (_page > 0)
                    TextButton(
                      onPressed: () {
                        _pageCtrl.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() => _page--);
                      },
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _canAdvance ? _next : null,
                    child: Text(_page < 4 ? 'Continue' : 'Get Started'),
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

class _QuizPage extends StatelessWidget {
  const _QuizPage({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onSelect,
  });
  final String title;
  final String subtitle;
  final List<(String id, String label, String desc)> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withAlpha(150),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ...options.map((opt) {
            final isSelected = selected == opt.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSelect(opt.$1),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected
                        ? theme.colorScheme.primary.withAlpha(15)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opt.$2,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              opt.$3,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withAlpha(
                                  130,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TimezonePage extends StatefulWidget {
  const _TimezonePage({required this.timezone, required this.onChanged});
  final String timezone;
  final ValueChanged<String> onChanged;

  static const _timezones = [
    ('UTC', 'UTC', 'Coordinated Universal Time'),
    ('America/New_York', 'New York', 'EST / UTC-5'),
    ('America/Chicago', 'Chicago', 'CST / UTC-6'),
    ('America/Los_Angeles', 'Los Angeles', 'PST / UTC-8'),
    ('Europe/London', 'London', 'GMT / UTC+0'),
    ('Europe/Berlin', 'Berlin', 'CET / UTC+1'),
    ('Europe/Moscow', 'Moscow', 'MSK / UTC+3'),
    ('Africa/Nairobi', 'Nairobi', 'EAT / UTC+3'),
    ('Africa/Lagos', 'Lagos', 'WAT / UTC+1'),
    ('Africa/Johannesburg', 'Johannesburg', 'SAST / UTC+2'),
    ('Asia/Dubai', 'Dubai', 'GST / UTC+4'),
    ('Asia/Kolkata', 'Mumbai', 'IST / UTC+5:30'),
    ('Asia/Singapore', 'Singapore', 'SGT / UTC+8'),
    ('Asia/Tokyo', 'Tokyo', 'JST / UTC+9'),
    ('Asia/Shanghai', 'Shanghai', 'CST / UTC+8'),
    ('Australia/Sydney', 'Sydney', 'AEDT / UTC+11'),
    ('Pacific/Auckland', 'Auckland', 'NZST / UTC+12'),
  ];

  @override
  State<_TimezonePage> createState() => _TimezonePageState();
}

class _TimezonePageState extends State<_TimezonePage> {
  late final FixedExtentScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    final idx = _TimezonePage._timezones.indexWhere(
      (t) => t.$1 == widget.timezone,
    );
    _scrollCtrl = FixedExtentScrollController(initialItem: idx < 0 ? 0 : idx);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            'Your timezone',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Trade timestamps and notifications use this.',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withAlpha(150),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Drum-roll picker
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Selection highlight band
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.primary.withAlpha(80),
                      width: 1.5,
                    ),
                  ),
                ),
                // Top fade
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.scaffoldBackgroundColor,
                            theme.scaffoldBackgroundColor.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Bottom fade
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            theme.scaffoldBackgroundColor,
                            theme.scaffoldBackgroundColor.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Wheel
                ListWheelScrollView.useDelegate(
                  controller: _scrollCtrl,
                  itemExtent: 56,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (i) {
                    widget.onChanged(_TimezonePage._timezones[i].$1);
                  },
                  childDelegate: ListWheelChildListDelegate(
                    children: _TimezonePage._timezones.asMap().entries.map((
                      entry,
                    ) {
                      final i = entry.key;
                      final tz = entry.value;
                      final isSelected = widget.timezone == tz.$1;
                      return AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: isSelected ? 17 : 14,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withAlpha(120),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(tz.$2),
                            Text(
                              tz.$3,
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? theme.colorScheme.primary.withAlpha(180)
                                    : theme.colorScheme.onSurface.withAlpha(70),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STEP 5: Risk Management Setup
// ─────────────────────────────────────────────

class _RiskSetupPage extends StatelessWidget {
  const _RiskSetupPage({
    required this.balanceCtrl,
    required this.currency,
    required this.onCurrencyChanged,
    required this.riskPctCtrl,
    required this.riskUsdCtrl,
    required this.useRiskPct,
    required this.onToggleRiskMode,
    required this.onChanged,
  });

  final TextEditingController balanceCtrl;
  final String currency;
  final ValueChanged<String> onCurrencyChanged;
  final TextEditingController riskPctCtrl;
  final TextEditingController riskUsdCtrl;
  final bool useRiskPct;
  final ValueChanged<bool> onToggleRiskMode;
  final VoidCallback onChanged;

  static const _currencies = [
    'USD',
    'EUR',
    'GBP',
    'CAD',
    'AUD',
    'ZAR',
    'NGN',
    'KES',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balance = double.tryParse(balanceCtrl.text) ?? 0;
    final riskPct = double.tryParse(riskPctCtrl.text) ?? 1;
    final calculatedRisk = balance * (riskPct / 100);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            'Risk management',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your starting balance and per-trade risk limit. You can change these anytime in Settings.',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withAlpha(150),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),

          // Balance + currency
          Text(
            'Account balance',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 12),

          // Quick-pick chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final amount in [
                '500',
                '1000',
                '5000',
                '10000',
                '25000',
                '50000',
                '100000',
              ])
                _BalanceChip(
                  label: _formatBalanceChip(amount, currency),
                  selected: balanceCtrl.text == amount,
                  onTap: () {
                    balanceCtrl.text = amount;
                    onChanged();
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Custom amount row
          Row(
            children: [
              // Currency picker
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currency,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    items: _currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) onCurrencyChanged(v);
                      onChanged();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: balanceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Custom amount',
                    prefixText: _currencySymbol(currency),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),
          Text(
            'Risk per trade',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),

          // Toggle % vs fixed
          Row(
            children: [
              ChoiceChip(
                label: const Text('% of balance'),
                selected: useRiskPct,
                onSelected: (_) {
                  onToggleRiskMode(true);
                  onChanged();
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text('Fixed $currency'),
                selected: !useRiskPct,
                onSelected: (_) {
                  onToggleRiskMode(false);
                  onChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (useRiskPct)
            TextField(
              controller: riskPctCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                hintText: '1',
                suffixText: '%',
                helperText: balance > 0
                    ? 'Max risk per trade: ${_currencySymbol(currency)}${calculatedRisk.toStringAsFixed(0)}'
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => onChanged(),
            )
          else
            TextField(
              controller: riskUsdCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                hintText: '100',
                prefixText: _currencySymbol(currency),
                helperText: 'Fixed amount lost max per trade',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => onChanged(),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _currencySymbol(String c) {
    switch (c) {
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '$c ';
    }
  }

  String _formatBalanceChip(String amount, String currency) {
    final sym = _currencySymbol(currency);
    final n = int.tryParse(amount) ?? 0;
    if (n >= 1000) return '$sym${n ~/ 1000}k';
    return '$sym$n';
  }
}

// ── Balance quick-pick chip ───────────────────────────────────────────

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
            width: selected ? 2 : 1,
          ),
          color: selected ? theme.colorScheme.primary.withAlpha(15) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
