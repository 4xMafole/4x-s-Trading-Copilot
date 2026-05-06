import 'dart:async';
import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:path_provider/path_provider.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models.dart';
import '../services/mt5_parser.dart';
import '../services/screenshot_ocr_service.dart';
import '../services/trade_extractor.dart';
import '../services/notification_center.dart';
import '../services/weekly_digest_service.dart';
import '../services/economic_calendar_service.dart';
import '../services/cloud_backup_service.dart';
import '../services/pdf_report_service.dart';
import '../logic/cubits/settings_cubit.dart';
import '../logic/cubits/settings_state.dart';
import '../logic/cubits/trading_core_cubit.dart';
import '../logic/cubits/trading_core_state.dart';
import '../logic/cubits/ai_coach_cubit.dart';
import '../logic/cubits/ai_coach_state.dart';
import '../services/ai_service.dart';
import '../logic/intelligence_engine.dart';
import '../logic/personal_edge_engine.dart';
import '../logic/drawdown_engine.dart';
import '../logic/risk_budget_engine.dart';
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
  static const _walkthroughKey = 'walkthrough_v3';
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
    // After walkthrough (or skipped), prompt for today's mood if missing.
    if (mounted) await _autoMoodCheckIn();
    // Then check whether last week's AI digest needs to be generated.
    if (mounted) await _autoWeeklyDigest();
  }

  /// Sprint 3.2: generates last-week digest if Sun/Mon and not already cached.
  /// Also schedules the recurring Sunday 18:00 EAT push if not yet scheduled.
  Future<void> _autoWeeklyDigest() async {
    if (!mounted) return;
    final c = _vm();
    try {
      // Schedule (idempotent — flutter_local_notifications will replace).
      unawaited(WeeklyDigestService().scheduleSundayReminder());
      // Generate if due.
      await c.generateWeeklyDigestIfDue();
    } catch (e) {
      debugPrint('Weekly digest auto-run failed: $e');
    }
    // Also (re)apply user notification preferences for recurring reminders.
    try {
      final prefs = c.state.notificationPrefs;
      if (prefs.master && prefs.moodReminder) {
        unawaited(NotificationCenter.instance.scheduleDailyMoodReminder());
      } else {
        unawaited(NotificationCenter.instance.cancelMoodReminder());
      }
      if (prefs.master && prefs.backupReminder) {
        unawaited(NotificationCenter.instance.scheduleSundayBackupReminder());
      } else {
        unawaited(NotificationCenter.instance.cancelBackupReminder());
      }
    } catch (e) {
      debugPrint('Recurring notification schedule failed: $e');
    }
  }

  /// Sprint 2.3: First-open-of-the-day mood check-in. Shown once per EAT day.
  Future<void> _autoMoodCheckIn() async {
    final c = _vm();
    if (c.getTodayMood() != null) return;
    if (!mounted) return;
    await _showMoodCheckInSheet(c);
  }

  Future<void> _showMoodCheckInSheet(TradingScreenViewModel c) async {
    String? selected;
    final noteCtrl = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: context.c.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 18,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How are you today?',
                    style: Theme.of(sheetCtx).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A 1-tap check-in. Your mood is correlated with your trades.',
                    style: TextStyle(
                      color: context.c.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kMoodOptions.map((m) {
                      final isSel = selected == m.id;
                      return InkWell(
                        onTap: () => setSheetState(() => selected = m.id),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 92,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppTheme.accent.withValues(alpha: 0.12)
                                : context.c.surfaceRaised,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? AppTheme.accent : context.c.border,
                              width: isSel ? 1.4 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                m.emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                m.label,
                                style: TextStyle(
                                  color: isSel
                                      ? AppTheme.accent
                                      : context.c.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: noteCtrl,
                    maxLines: 2,
                    minLines: 1,
                    style: TextStyle(color: context.c.text, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Optional note (slept well, news anxiety, …)',
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
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetCtx),
                          child: const Text('Skip'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selected == null
                              ? null
                              : () async {
                                  await c.setTodayMood(
                                    selected!,
                                    note: noteCtrl.text,
                                  );
                                  if (sheetCtx.mounted) {
                                    Navigator.pop(sheetCtx);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: Colors.white,
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
      },
    );
    noteCtrl.dispose();
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
        icon: Icons.auto_awesome,
        title: 'What’s New',
        body:
            'Welcome to 4x Trades. New since last release: • OCR screenshot import for MT5 statements  • AI Coach with edge analysis  • Weekly Sunday digest  • Drawdown + weekly risk-budget guards  • Forex Factory news blackout  • Encrypted backups + PDF tear sheets  • Local-only AI mode for full privacy.',
        action: () => _setActiveTab(0),
        actionLabel: 'Tour the app',
      ),
      _WalkthroughStep(
        icon: Icons.dashboard_outlined,
        title: 'Dashboard',
        body:
            'Your command center. Readiness score tells you if conditions are right. '
            'New cards: weekly digest banner, news-impact warning, distance-from-bust drawdown gauge, weekly risk-budget meter.',
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
            'Log every trade immediately after execution — or use the camera button to import a broker screenshot via on-device OCR. '
            'Mood check-ins and post-trade reflections are captured here. Violations build your discipline score.',
        action: () => _setActiveTab(2),
        actionLabel: 'Open Journal',
      ),
      _WalkthroughStep(
        icon: Icons.insights_outlined,
        title: 'Edge Map & AI Coach',
        body:
            'Your personal performance data plus a ruthless AI coach. Tap “Analyze Logged Edge” for strengths, leaks, and a harsh-truth verdict — or import an MT5 CSV for the same on broker data. Local-only mode is one toggle away.',
        action: () => _setActiveTab(3),
        actionLabel: 'View Edge',
      ),
      _WalkthroughStep(
        icon: Icons.tune,
        title: 'Settings',
        body:
            'Configure prop-firm rules, weekly risk budget, news blackout, and privacy. '
            'Export an encrypted backup to Drive/iCloud or a PDF tear sheet for accountants. Activity History shows every state change.',
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
                    height: 140,
                    child: PageView.builder(
                      controller: pageCtrl,
                      itemCount: steps.length,
                      onPageChanged: (i) => setS(() => current = i),
                      itemBuilder: (_, i) => SingleChildScrollView(
                        child: Text(
                          steps[i].body,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
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
