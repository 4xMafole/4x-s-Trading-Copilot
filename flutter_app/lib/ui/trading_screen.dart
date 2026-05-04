import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:path_provider/path_provider.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models.dart';
import '../services/mt5_parser.dart';
import '../logic/cubits/settings_cubit.dart';
import '../logic/cubits/settings_state.dart';
import '../logic/cubits/trading_core_cubit.dart';
import '../logic/cubits/trading_core_state.dart';
import '../logic/cubits/ai_coach_cubit.dart';
import '../logic/cubits/ai_coach_state.dart';
import '../services/ai_service.dart';
import '../logic/intelligence_engine.dart';
import 'app_theme.dart';
import 'tokens.dart';
import 'trading_screen_view_model.dart';

part 'parts/dashboard_tab.dart';
part 'parts/trade_flow_tab.dart';
part 'parts/journal_tab.dart';
part 'parts/edge_tab.dart';
part 'parts/settings_tab.dart';
part 'parts/widgets.dart';
part 'parts/helpers.dart';

// ═══════════════════════════════════════════════════════════════════════
//  MAIN SCREEN
// ═══════════════════════════════════════════════════════════════════════

class TradingScreen extends StatefulWidget {
  const TradingScreen({super.key});

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  static const _walkthroughKey = 'walkthrough_v2';
  final GlobalKey<_JournalTabState> _journalTabKey =
      GlobalKey<_JournalTabState>();
  int _activeTab = 0;

  void _setActiveTab(int i) {
    if (!mounted) return;
    setState(() => _activeTab = i);
  }

  TradingScreenViewModel _vm() => TradingScreenViewModel(
    trading: context.read<TradingCoreCubit>(),
    settings: context.read<SettingsCubit>(),
    activeTab: _activeTab,
    setActiveTab: _setActiveTab,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoWalkthrough());
  }

  Future<void> _autoWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_walkthroughKey) ?? false) && mounted) {
      await _showWalkthrough(markSeen: true);
    }
  }

  // ── Interactive walkthrough ──────────────────────────────────────────
  Future<void> _showWalkthrough({bool markSeen = false}) async {
    if (markSeen) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_walkthroughKey, true);
    }
    if (!mounted) return;

    final steps = <_WalkthroughStep>[
      _WalkthroughStep(
        icon: Icons.dashboard_outlined,
        title: 'Dashboard',
        body:
            'Your command center. The readiness score tells you instantly if conditions are right. '
            'Smart insights update in real-time based on session, risk, and trade count.',
        action: () => _setActiveTab(0),
        actionLabel: 'Go to Dashboard',
      ),
      _WalkthroughStep(
        icon: Icons.calculate_outlined,
        title: 'Trade Flow',
        body:
            'Plan → Size → Execute in order. The checklist blocks you from '
            'entering trades until every gate passes. The calculator sizes '
            'your lots automatically.',
        action: () => _setActiveTab(1),
        actionLabel: 'Open Trade Flow',
      ),
      _WalkthroughStep(
        icon: Icons.edit_note,
        title: 'Journal',
        body:
            'Log every trade immediately after execution. Violations are tracked '
            'to build your discipline score over time.',
        action: () => _setActiveTab(2),
        actionLabel: 'Open Journal',
      ),
      _WalkthroughStep(
        icon: Icons.insights_outlined,
        title: 'Edge Map',
        body:
            'Your personal performance data. Shows which instruments, sessions, '
            'and patterns actually make you money.',
        action: () => _setActiveTab(3),
        actionLabel: 'View Edge',
      ),
      _WalkthroughStep(
        icon: Icons.tune,
        title: 'Settings',
        body:
            'Configure your challenge parameters, export/import data, '
            'and reset state when needed.',
        action: () => _setActiveTab(4),
        actionLabel: 'Open Settings',
      ),
    ];

    var current = 0;
    final pageCtrl = PageController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) {
          final step = steps[current];
          final isLast = current == steps.length - 1;
          return SafeArea(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.c.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.c.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          step.icon,
                          color: AppTheme.accent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        '${current + 1}/${steps.length}',
                        style: TextStyle(
                          color: context.c.textTertiary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Body
                  SizedBox(
                    height: 100,
                    child: PageView.builder(
                      controller: pageCtrl,
                      itemCount: steps.length,
                      onPageChanged: (i) => setS(() => current = i),
                      itemBuilder: (_, i) => Text(
                        steps[i].body,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress dots
                  Row(
                    children: List.generate(steps.length, (i) {
                      final active = i == current;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 6),
                        width: active ? 24 : 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: active
                              ? AppTheme.accent
                              : AppTheme.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  // Action + nav buttons
                  if (step.action != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            step.action!();
                            setS(() {});
                          },
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: Text(step.actionLabel ?? 'Try it'),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Skip'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            if (!isLast) {
                              await pageCtrl.nextPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              );
                            } else {
                              if (ctx.mounted) Navigator.pop(ctx);
                            }
                          },
                          child: Text(isLast ? 'Done' : 'Next'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradingCoreCubit, TradingCoreState>(
      builder: (context, _) {
        return BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, __) {
            return _buildScaffold(context);
          },
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Builder(
      builder: (context) {
        final c = _vm();
        final pages = <Widget>[
          _DashboardTab(controller: c, onWalkthrough: _showWalkthrough),
          _TradeFlowTab(controller: c),
          _JournalTab(key: _journalTabKey, controller: c),
          _EdgeTab(controller: c),
          _SettingsTab(controller: c),
        ];
        final tab = c.activeTab < pages.length ? c.activeTab : 0;

        return Scaffold(
          backgroundColor: context.c.bg,
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: AppMotion.base,
              switchInCurve: AppMotion.standard,
              switchOutCurve: AppMotion.standard,
              child: KeyedSubtree(key: ValueKey(tab), child: pages[tab]),
            ),
          ),
          floatingActionButton: tab == 2
              ? FloatingActionButton.extended(
                  onPressed: () {
                    _journalTabKey.currentState?.openLogTradeSheet();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Log Trade'),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: context.c.divider, width: 1),
              ),
            ),
            child: NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (i) {
                HapticFeedback.lightImpact();
                c.setActiveTab(i);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.space_dashboard_outlined),
                  selectedIcon: Icon(Icons.space_dashboard),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.route_outlined),
                  selectedIcon: Icon(Icons.route),
                  label: 'Trade',
                ),
                NavigationDestination(
                  icon: Icon(Icons.edit_note_outlined),
                  selectedIcon: Icon(Icons.edit_note),
                  label: 'Journal',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights),
                  label: 'Edge',
                ),
                NavigationDestination(
                  icon: Icon(Icons.tune_outlined),
                  selectedIcon: Icon(Icons.tune),
                  label: 'Setup',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WalkthroughStep {
  const _WalkthroughStep({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
    this.actionLabel,
  });
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? action;
  final String? actionLabel;
}
