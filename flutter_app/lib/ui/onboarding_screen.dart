import 'package:flutter/material.dart';
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
  String? _experience; // beginner, intermediate, advanced
  String? _primaryMarket; // forex_majors, indices, crypto, commodities, stocks
  String? _strategyTemplate; // ICT, SMC, Supply/Demand, Price Action, Custom
  String _timezone = 'UTC';
  final Set<String> _selectedInstruments = {};

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
    if (_page < 3) {
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
        return true;
      default:
        return false;
    }
  }

  Future<void> _finish() async {
    // ── 1. Wire choices into LOCAL AppState (drives the UI) ──
    final cubit = context.read<TradingCoreCubit>();

    await cubit.setUserTimezone(_timezone);
    await cubit.setUserInstruments(
      _instrumentsForMarket(_primaryMarket ?? 'forex_majors'),
    );

    if (_strategyTemplate != null && _strategyTemplate != 'Custom') {
      await cubit.setUserGates(_gatesForStrategy(_strategyTemplate!));
    }

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
                children: List.generate(4, (i) {
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
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
                    child: Text(_page < 3 ? 'Continue' : 'Get Started'),
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

class _TimezonePage extends StatelessWidget {
  const _TimezonePage({required this.timezone, required this.onChanged});
  final String timezone;
  final ValueChanged<String> onChanged;

  static const _commonTimezones = [
    'America/New_York',
    'America/Chicago',
    'America/Los_Angeles',
    'Europe/London',
    'Europe/Berlin',
    'Europe/Moscow',
    'Africa/Nairobi',
    'Africa/Lagos',
    'Africa/Johannesburg',
    'Asia/Dubai',
    'Asia/Kolkata',
    'Asia/Singapore',
    'Asia/Tokyo',
    'Asia/Shanghai',
    'Australia/Sydney',
    'Pacific/Auckland',
    'UTC',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Auto-detect as default
    final detected = DateTime.now().timeZoneName;

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
            'We use this for session timing, blackout windows, and trade timestamps. '
            'Detected: $detected',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withAlpha(150),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _commonTimezones.contains(timezone) ? timezone : 'UTC',
            decoration: const InputDecoration(
              labelText: 'Timezone',
              prefixIcon: Icon(Icons.public),
            ),
            items: _commonTimezones
                .map(
                  (tz) => DropdownMenuItem(
                    value: tz,
                    child: Text(tz.replaceAll('_', ' ')),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
