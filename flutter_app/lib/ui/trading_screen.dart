import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models.dart';
import '../logic/trading_controller.dart';
import 'app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════
//  INTELLIGENCE ENGINE — smart insights derived from live state
// ═══════════════════════════════════════════════════════════════════════

class _Insight {
  const _Insight(this.icon, this.text, this.tone);
  final IconData icon;
  final String text;
  final Color tone;
}

List<_Insight> _computeInsights(TradingController c) {
  final insights = <_Insight>[];
  final session = c.getSessionInfo();
  final today = c.getTodayPnl();
  final trades = c.getTodayTrades();
  final autoGates = c.computeAutoGates();
  final passedCount = kGates.where((g) {
    if (g.auto) return autoGates[g.id] ?? false;
    return c.state.checks[g.id] ?? false;
  }).length;

  // Session intelligence
  if (!session.ok) {
    insights.add(_Insight(
      Icons.block,
      'No-trade zone active. ${session.detail}',
      AppTheme.red,
    ));
  } else {
    insights.add(_Insight(
      Icons.check_circle_outline,
      '${session.label} — execution window open.',
      AppTheme.green,
    ));
  }

  // Risk intelligence
  if (today < -100) {
    insights.add(_Insight(
      Icons.warning_amber_rounded,
      'Down ${today.abs().toStringAsFixed(0)} USD today. Protect remaining capital.',
      AppTheme.red,
    ));
  } else if (today > 200) {
    insights.add(_Insight(
      Icons.trending_up,
      'Strong day at +${today.toStringAsFixed(0)} USD. Consider locking profit.',
      AppTheme.green,
    ));
  }

  // Trade count intelligence
  if (trades.length >= 2) {
    insights.add(_Insight(
      Icons.do_not_disturb,
      'Max daily trades reached. Review journal and stop.',
      AppTheme.amber,
    ));
  } else if (trades.length == 1 && trades.first.pnl < 0) {
    insights.add(_Insight(
      Icons.psychology,
      'First trade was a loss. Stay disciplined on the second.',
      AppTheme.amber,
    ));
  }

  // Checklist readiness
  if (passedCount < kGates.length && session.ok) {
    final remaining = kGates.length - passedCount;
    insights.add(_Insight(
      Icons.checklist,
      '$remaining gate${remaining == 1 ? '' : 's'} still pending before entry.',
      AppTheme.accent,
    ));
  } else if (passedCount == kGates.length && session.ok && trades.length < 2) {
    insights.add(_Insight(
      Icons.rocket_launch_outlined,
      'All gates passed. You are cleared to execute.',
      AppTheme.green,
    ));
  }

  // Lock intelligence
  if (c.state.lock) {
    insights.add(_Insight(
      Icons.lock_outline,
      'Account locked after consecutive losses. Rest and reset.',
      AppTheme.red,
    ));
  }

  return insights;
}

int _readinessScore(TradingController c) {
  int score = 0;
  final session = c.getSessionInfo();
  final auto = c.computeAutoGates();
  final total = kGates.length;
  final passed = kGates.where((g) {
    if (g.auto) return auto[g.id] ?? false;
    return c.state.checks[g.id] ?? false;
  }).length;

  if (session.ok) score += 30;
  score += ((passed / total) * 50).round();
  if (!c.state.lock) score += 10;
  if (c.getTodayTrades().length < 2) score += 10;
  return score.clamp(0, 100);
}

Color _scoreColor(int score) {
  if (score >= 80) return AppTheme.green;
  if (score >= 50) return AppTheme.amber;
  return AppTheme.red;
}

// ═══════════════════════════════════════════════════════════════════════
//  MAIN SCREEN
// ═══════════════════════════════════════════════════════════════════════

class TradingScreen extends StatefulWidget {
  const TradingScreen({super.key, required this.controller});
  final TradingController controller;

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  static const _walkthroughKey = 'walkthrough_v2';
  final GlobalKey<_JournalTabState> _journalTabKey =
      GlobalKey<_JournalTabState>();

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
        action: () => widget.controller.setActiveTab(0),
        actionLabel: 'Go to Dashboard',
      ),
      _WalkthroughStep(
        icon: Icons.calculate_outlined,
        title: 'Trade Flow',
        body: 'Plan → Size → Execute in order. The checklist blocks you from '
            'entering trades until every gate passes. The calculator sizes '
            'your lots automatically.',
        action: () => widget.controller.setActiveTab(1),
        actionLabel: 'Open Trade Flow',
      ),
      _WalkthroughStep(
        icon: Icons.edit_note,
        title: 'Journal',
        body:
            'Log every trade immediately after execution. Violations are tracked '
            'to build your discipline score over time.',
        action: () => widget.controller.setActiveTab(2),
        actionLabel: 'Open Journal',
      ),
      _WalkthroughStep(
        icon: Icons.insights_outlined,
        title: 'Edge Map',
        body:
            'Your personal performance data. Shows which instruments, sessions, '
            'and patterns actually make you money.',
        action: () => widget.controller.setActiveTab(3),
        actionLabel: 'View Edge',
      ),
      _WalkthroughStep(
        icon: Icons.tune,
        title: 'Settings',
        body: 'Configure your challenge parameters, export/import data, '
            'and reset state when needed.',
        action: () => widget.controller.setActiveTab(4),
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
                        child:
                            Icon(step.icon, color: AppTheme.accent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(step.title,
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      Text(
                        '${current + 1}/${steps.length}',
                        style: TextStyle(
                            color: context.c.textTertiary, fontSize: 13),
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
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final c = widget.controller;
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
              duration: const Duration(milliseconds: 200),
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
          bottomNavigationBar: NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: c.setActiveTab,
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

// ═══════════════════════════════════════════════════════════════════════
//  TAB 0: DASHBOARD — the intelligent home screen
// ═══════════════════════════════════════════════════════════════════════

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({required this.controller, required this.onWalkthrough});
  final TradingController controller;
  final Future<void> Function({bool markSeen}) onWalkthrough;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final session = c.getSessionInfo();
    final score = _readinessScore(c);
    final insights = _computeInsights(c);
    final todayTrades = c.getTodayTrades();
    final allTrades = c.getAllTradesDesc();
    final challenge = c.getChallengePnl();
    final today = c.getTodayPnl();
    final allPnl = allTrades.fold<double>(0, (sum, t) => sum + t.pnl);
    final wins = allTrades.where((t) => t.pnl > 0).length;
    final winRate = allTrades.isEmpty ? 0.0 : (wins / allTrades.length) * 100;
    final balance = c.state.balance + challenge;
    final progress = (challenge / 1250).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        // ── Header row ──
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('4x Trades',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontSize: 24)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD740), Color(0xFFFFA000)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('PREMIUM',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _eatTime(c.nowEAT),
                    style:
                        TextStyle(color: context.c.textTertiary, fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => onWalkthrough(),
              icon: Icon(Icons.help_outline,
                  color: context.c.textTertiary, size: 22),
              tooltip: 'Walkthrough',
            ),
            _ThemeToggleButton(controller: c),
          ],
        ),

        const SizedBox(height: 24),

        // ── Readiness Score ──
        _Card(
          child: Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CustomPaint(
                  painter: _ScoreRingPainter(
                      score, _scoreColor(score), context.c.border),
                  child: Center(
                    child: Text(
                      '$score',
                      style: TextStyle(
                        color: _scoreColor(score),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Readiness Score',
                        style: TextStyle(
                            color: context.c.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      score >= 80
                          ? 'Conditions are favorable. Execute with discipline.'
                          : score >= 50
                              ? 'Partial readiness. Complete remaining gates.'
                              : 'Not ready. Wait for better conditions.',
                      style: TextStyle(
                          color: context.c.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Key metrics row ──
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: 'Balance',
                value: _compact(balance),
                tone: context.c.text,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                label: 'Today',
                value: _signed(today),
                tone: today >= 0 ? AppTheme.green : AppTheme.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                label: 'Target',
                value: '${(progress * 100).toStringAsFixed(0)}%',
                tone: AppTheme.accent,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ── Overall metrics row ──
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: 'All Trades',
                value: '${allTrades.length}',
                tone: context.c.text,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                label: 'All-Time',
                value: _signed(allPnl),
                tone: allPnl >= 0 ? AppTheme.green : AppTheme.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                label: 'Win Rate',
                value: '${winRate.toStringAsFixed(0)}%',
                tone: AppTheme.accent,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Session status ──
        _Card(
          child: Row(
            children: [
              Container(
                width: 8,
                height: 44,
                decoration: BoxDecoration(
                  color: _sessionTone(context, session.type),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.label,
                        style: TextStyle(
                          color: _sessionTone(context, session.type),
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 2),
                    Text(
                        'Day ${c.getDayNumber()} · ${todayTrades.length}/2 today · ${allTrades.length} total',
                        style: TextStyle(
                            color: context.c.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              _Pill(
                label:
                    c.state.lock ? 'Locked' : (session.ok ? 'Open' : 'Closed'),
                tone: c.state.lock
                    ? AppTheme.red
                    : (session.ok ? AppTheme.green : context.c.textTertiary),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Smart insights ──
        Text('INSIGHTS',
            style: TextStyle(
                color: context.c.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2)),
        const SizedBox(height: 10),
        ...insights.map((ins) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Card(
                child: Row(
                  children: [
                    Icon(ins.icon, color: ins.tone, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(ins.text,
                          style:
                              TextStyle(color: context.c.text, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            )),

        const SizedBox(height: 16),

        // ── Quick action ──
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => controller.setActiveTab(1),
            child: const Text('Start Trade Flow →'),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  TAB 1: TRADE FLOW — Plan → Size → Execute
// ═══════════════════════════════════════════════════════════════════════

class _TradeFlowTab extends StatefulWidget {
  const _TradeFlowTab({required this.controller});
  final TradingController controller;

  @override
  State<_TradeFlowTab> createState() => _TradeFlowTabState();
}

class _TradeFlowTabState extends State<_TradeFlowTab> {
  int step = 0;
  String instrument = 'XAUUSD';
  final slCtrl = TextEditingController(text: '7');
  final entriesCtrl = TextEditingController(text: '1');

  @override
  void dispose() {
    slCtrl.dispose();
    entriesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final autoChecks = c.computeAutoGates();
    final passedCount = kGates.where((g) {
      if (g.auto) return autoChecks[g.id] ?? false;
      return c.state.checks[g.id] ?? false;
    }).length;

    final stopLoss = double.tryParse(slCtrl.text) ?? 0;
    final entries = int.tryParse(entriesCtrl.text) ?? 1;
    final meta = kInstruments[instrument]!;
    var lot = 0.0;
    if (stopLoss > 0 && meta.pipVal > 0 && entries > 0) {
      lot = (125 / entries) / (stopLoss * meta.pipVal * 10);
    }
    final risk =
        (lot * entries * stopLoss * meta.pipVal * 10).clamp(0, 125).toDouble();

    final stepLabels = ['Plan', 'Size', 'Execute'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        // ── Title ──
        Text('Trade Flow',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: 24)),
        const SizedBox(height: 4),
        Text('Step ${step + 1} of 3 — ${stepLabels[step]}',
            style: TextStyle(color: context.c.textSecondary, fontSize: 13)),

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
                onTap: () => setState(() => step = i),
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
                    Text(stepLabels[i],
                        style: TextStyle(
                          color: tone,
                          fontSize: 12,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w400,
                        )),
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
              ),
            1 => _SizeStep(
                key: const ValueKey('size'),
                instrument: instrument,
                slCtrl: slCtrl,
                entriesCtrl: entriesCtrl,
                lot: lot,
                risk: risk,
                onInstrumentChange: (v) => setState(() => instrument = v),
                onInputChange: () => setState(() {}),
              ),
            _ => _ExecuteStep(
                key: const ValueKey('exec'),
                controller: c,
                lot: lot,
                risk: risk,
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
                  onPressed: () => setState(() => step--),
                  child: const Text('Back'),
                ),
              ),
            if (step > 0) const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  if (step < 2) {
                    setState(() => step++);
                  } else {
                    c.setActiveTab(2);
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
  });
  final TradingController controller;
  final Map<String, bool> autoChecks;
  final int passedCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  value: passedCount / kGates.length,
                  backgroundColor: context.c.border,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.green),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('$passedCount/${kGates.length}',
                style: TextStyle(color: context.c.textSecondary, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 16),

        // Gates list
        ...kGates.map((gate) {
          final passed = gate.auto
              ? (autoChecks[gate.id] ?? false)
              : (controller.state.checks[gate.id] ?? false);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _Card(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: gate.auto
                        ? Icon(
                            passed ? Icons.check_circle : Icons.cancel_outlined,
                            size: 20,
                            color: passed ? AppTheme.green : AppTheme.red,
                          )
                        : Checkbox(
                            value: passed,
                            onChanged: (_) => controller.toggleCheck(gate.id),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(gate.label,
                            style: TextStyle(
                              color: passed
                                  ? context.c.text
                                  : context.c.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            )),
                        Text(gate.sub,
                            style: TextStyle(
                                color: context.c.textTertiary, fontSize: 11)),
                      ],
                    ),
                  ),
                  if (gate.auto)
                    _Pill(
                      label: passed ? 'Auto ✓' : 'Blocked',
                      tone: passed ? AppTheme.green : AppTheme.red,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _SizeStep extends StatelessWidget {
  const _SizeStep({
    super.key,
    required this.instrument,
    required this.slCtrl,
    required this.entriesCtrl,
    required this.lot,
    required this.risk,
    required this.onInstrumentChange,
    required this.onInputChange,
  });
  final String instrument;
  final TextEditingController slCtrl;
  final TextEditingController entriesCtrl;
  final double lot;
  final double risk;
  final ValueChanged<String> onInstrumentChange;
  final VoidCallback onInputChange;

  @override
  Widget build(BuildContext context) {
    final meta = kInstruments[instrument]!;
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
                    tone: AppTheme.accent)),
            const SizedBox(width: 8),
            Expanded(
                child: _MetricTile(
                    label: 'Risk',
                    value: '\$${risk.toStringAsFixed(0)}',
                    tone: risk <= 125 ? AppTheme.green : AppTheme.red)),
            const SizedBox(width: 8),
            Expanded(
                child: _MetricTile(
                    label: 'Min TP',
                    value: ((double.tryParse(slCtrl.text) ?? 0) * 2)
                        .toStringAsFixed(1),
                    tone: AppTheme.amber)),
          ],
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
  });
  final TradingController controller;
  final double lot;
  final double risk;

  @override
  Widget build(BuildContext context) {
    final trades = controller.getTodayTrades().length;
    final locked = controller.state.lock || trades >= 2;
    final session = controller.getSessionInfo();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Execution Check',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          _StatusRow('Session', session.ok ? 'Open' : 'Closed',
              session.ok ? AppTheme.green : AppTheme.red),
          _StatusRow('Trades', '$trades / 2',
              trades < 2 ? AppTheme.green : AppTheme.amber),
          _StatusRow(
              'Lot size', '${lot.toStringAsFixed(2)} lots', AppTheme.accent),
          _StatusRow('Risk', '\$${risk.toStringAsFixed(0)}',
              risk <= 125 ? AppTheme.green : AppTheme.red),
          _StatusRow('System', locked ? 'Locked' : 'Ready',
              locked ? AppTheme.red : AppTheme.green),
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

// ═══════════════════════════════════════════════════════════════════════
//  TAB 2: JOURNAL
// ═══════════════════════════════════════════════════════════════════════

class _JournalTab extends StatefulWidget {
  const _JournalTab({super.key, required this.controller});
  final TradingController controller;

  @override
  State<_JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends State<_JournalTab> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _lastImagePickError;
  String? selectedDate;

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
      final imageDir =
          Directory('${docsDir.path}${Platform.pathSeparator}journal_images');
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

  Future<void> openLogTradeSheet() async {
    final c = widget.controller;
    final todayTrades = c.getTodayTrades();
    final locked = c.state.lock || todayTrades.length >= 2;
    if (locked) {
      _snack(context, 'Session closed.');
      return;
    }

    var sheetSym = 'XAUUSD';
    var sheetDir = 'buy';
    final sheetViolations = <String>{};
    String? sheetHtfImagePath;
    String? sheetLtfImagePath;
    final sheetLotsCtrl = TextEditingController();
    final sheetPnlCtrl = TextEditingController();
    final sheetNoteCtrl = TextEditingController();

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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Log trade',
                                style: Theme.of(ctx).textTheme.titleMedium),
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
                                value: 'XAUUSD', child: Text('XAUUSD')),
                            DropdownMenuItem(value: 'NQ', child: Text('NQ100')),
                            DropdownMenuItem(
                                value: 'EURUSD', child: Text('EURUSD')),
                          ],
                          onChanged: (v) {
                            setSheetState(() => sheetSym = v ?? 'XAUUSD');
                          },
                          decoration:
                              const InputDecoration(labelText: 'Instrument'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: sheetDir,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'buy', child: Text('Buy')),
                                  DropdownMenuItem(
                                      value: 'sell', child: Text('Sell')),
                                ],
                                onChanged: (v) {
                                  setSheetState(() => sheetDir = v ?? 'buy');
                                },
                                decoration: const InputDecoration(
                                    labelText: 'Direction'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: sheetLotsCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration:
                                    const InputDecoration(labelText: 'Lots'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: sheetPnlCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'P&L (USD)'),
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
                          decoration: const InputDecoration(labelText: 'Notes'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => attachImage(true),
                                icon: const Icon(Icons.image, size: 18),
                                label: Text(sheetHtfImagePath != null
                                    ? 'HTF ✓'
                                    : 'HTF Chart'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => attachImage(false),
                                icon: const Icon(Icons.image, size: 18),
                                label: Text(sheetLtfImagePath != null
                                    ? 'LTF ✓'
                                    : 'LTF Chart'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () async {
                              final pnl =
                                  double.tryParse(sheetPnlCtrl.text.trim());
                              if (pnl == null) {
                                _snack(context, 'Enter valid P&L.');
                                return;
                              }

                              await c.addTrade(
                                sym: sheetSym,
                                dir: sheetDir,
                                lots: double.tryParse(
                                        sheetLotsCtrl.text.trim()) ??
                                    0,
                                pnl: pnl,
                                note: sheetNoteCtrl.text,
                                violations: sheetViolations.toList(),
                                htfImage: sheetHtfImagePath,
                                ltfImage: sheetLtfImagePath,
                              );

                              if (ctx.mounted) Navigator.pop(ctx);
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
              );
            },
          );
        },
      );
    } finally {
      sheetLotsCtrl.dispose();
      sheetPnlCtrl.dispose();
      sheetNoteCtrl.dispose();
    }
  }

  Future<void> _confirmDeleteTrade(Trade t) async {
    final confirmed = await showDialog<bool>(
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
    final displayTrades = selectedDate != null
        ? c.getTradesByDate(selectedDate!)
        : c.getAllTradesDesc();
    final locked = c.state.lock || todayTrades.length >= 2;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text('Journal',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
            selectedDate == null
                ? '${c.state.allTrades.length} trade${c.state.allTrades.length == 1 ? '' : 's'} total'
                : '${displayTrades.length} trade${displayTrades.length == 1 ? '' : 's'} on $selectedDate',
            style: TextStyle(color: context.c.textSecondary, fontSize: 13)),

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
                Text('Trade History',
                    style: Theme.of(context).textTheme.titleMedium),
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
                                () => selectedDate = selected ? date : null),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // ── Trade list ──
        if (displayTrades.isEmpty)
          _Card(
            child: Column(
              children: [
                Icon(Icons.inbox_outlined,
                    size: 32, color: context.c.textTertiary),
                const SizedBox(height: 8),
                Text(
                    selectedDate == null
                        ? 'No trades yet'
                        : 'No trades on $selectedDate',
                    style: TextStyle(color: context.c.textSecondary)),
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
                              Text('${t.sym} ${t.dir.toUpperCase()}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              Text(
                                  '${t.time} · ${t.lots.toStringAsFixed(2)} lots',
                                  style: TextStyle(
                                      color: context.c.textTertiary,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(
                          _signed(t.pnl),
                          style: TextStyle(
                              color: tone,
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _confirmDeleteTrade(t),
                          icon: Icon(Icons.close,
                              size: 16, color: context.c.textTertiary),
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
                                  Text('HTF',
                                      style: TextStyle(
                                          color: context.c.textTertiary,
                                          fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color: context.c.border, width: 1),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
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
                                  Text('LTF',
                                      style: TextStyle(
                                          color: context.c.textTertiary,
                                          fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color: context.c.border, width: 1),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
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
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (t.note.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(t.note,
                          style: TextStyle(
                              color: context.c.textTertiary, fontSize: 12)),
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
}

// ═══════════════════════════════════════════════════════════════════════
//  TAB 3: EDGE MAP
// ═══════════════════════════════════════════════════════════════════════

class _EdgeTab extends StatelessWidget {
  const _EdgeTab({required this.controller});
  final TradingController controller;

  @override
  Widget build(BuildContext context) {
    final trades = controller.state.allTrades;
    final live = _LiveStats.compute(trades);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text('Edge Map',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: 24)),
        const SizedBox(height: 4),
        Text('What actually makes you money',
            style: TextStyle(color: context.c.textSecondary, fontSize: 13)),

        // ── Section 1: Personal Account Overview ──────────────────
        const SizedBox(height: 24),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Personal account overview — 572 trades · Jul 2025 – Mar 2026',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 14),
              _statGrid(const [
                _StatBox(
                    label: 'Total trades', value: '572', tone: AppTheme.accent),
                _StatBox(
                    label: 'Net P&L', value: '+\$301.06', tone: AppTheme.green),
                _StatBox(
                    label: 'Overall win rate',
                    value: '32.4%',
                    tone: AppTheme.amber),
                _StatBox(
                    label: 'Avg R:R achieved',
                    value: '2.71',
                    tone: AppTheme.green),
                _StatBox(
                    label: 'Avg win', value: '+\$38.48', tone: AppTheme.green),
                _StatBox(
                    label: 'Avg loss', value: '-\$14.19', tone: AppTheme.red),
              ]),
              const SizedBox(height: 14),
              _AlertBox(
                tone: AppTheme.accent,
                title: 'THE PARADOX',
                body:
                    '32.4% win rate but still net profitable. Your average win (\$38.48) is 2.71× your average loss (\$14.19). The system has positive expectancy — it only needs discipline applied on top.',
              ),
            ],
          ),
        ),

        // ── Section 1b: Live Challenge Stats ──────────────────────
        if (trades.isNotEmpty) ...[
          const SizedBox(height: 12),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Live challenge — ${live.total} trades',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 14),
                _statGrid([
                  _StatBox(
                      label: 'Trades',
                      value: '${live.total}',
                      tone: AppTheme.accent),
                  _StatBox(
                    label: 'Net P&L',
                    value: _signed(live.netPnl),
                    tone: live.netPnl >= 0 ? AppTheme.green : AppTheme.red,
                  ),
                  _StatBox(
                    label: 'Win rate',
                    value: '${live.winRate.toStringAsFixed(1)}%',
                    tone: live.winRate >= 40 ? AppTheme.green : AppTheme.amber,
                  ),
                  _StatBox(
                    label: 'Avg win',
                    value: live.avgWin > 0
                        ? '+\$${live.avgWin.toStringAsFixed(2)}'
                        : '—',
                    tone: AppTheme.green,
                  ),
                  _StatBox(
                    label: 'Avg loss',
                    value: live.avgLoss < 0
                        ? '\$${live.avgLoss.toStringAsFixed(2)}'
                        : '—',
                    tone: AppTheme.red,
                  ),
                ]),
                if (live.total >= 5) ...[
                  const SizedBox(height: 14),
                  // Per-symbol breakdown
                  ...live.bySymbol.entries.map((e) {
                    final s = e.value;
                    return _EdgeRow(
                      label: e.key,
                      sub: '${s.total} trades',
                      val: '${s.winRate.toStringAsFixed(1)}% WR',
                      valSub: _signed(s.netPnl),
                      valColor: s.netPnl >= 0 ? AppTheme.green : AppTheme.red,
                      percent: s.winRate,
                    );
                  }),
                ],
              ],
            ),
          ),
        ],

        // ── Section 2: Symbol Performance ─────────────────────────
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Symbol performance — where your edge lives',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              _sectionLabel(context, 'Your top instruments'),
              const _EdgeRow(
                label: 'XAUUSD',
                sub: '19 trades · Primary instrument',
                val: '47% WR',
                valSub: '+\$406.90',
                valColor: AppTheme.green,
                percent: 47,
              ),
              const _EdgeRow(
                label: 'NQ100',
                sub: '16 trades · Secondary instrument',
                val: '44% WR',
                valSub: '+\$49.10',
                valColor: AppTheme.green,
                percent: 44,
              ),
              const _EdgeRow(
                label: 'EURUSD',
                sub: '40 trades · Conditional only',
                val: '25% WR',
                valSub: '+\$50.70',
                valColor: AppTheme.amber,
                percent: 25,
              ),
              const SizedBox(height: 20),
              _sectionLabel(context, 'Avoid completely'),
              const _EdgeRow(
                label: 'XAGUSD',
                sub: '3 trades',
                val: '0% WR',
                valSub: '-\$179.05',
                valColor: AppTheme.red,
                percent: 0,
              ),
              const _EdgeRow(
                label: 'BTCUSD / ETHUSD',
                sub: '11 trades combined',
                val: '18% WR',
                valSub: '-\$55.56',
                valColor: AppTheme.red,
                percent: 18,
              ),
              const _EdgeRow(
                label: 'GBPUSD',
                sub: '15 trades',
                val: '33% WR',
                valSub: '-\$60.22',
                valColor: AppTheme.red,
                percent: 33,
              ),
            ],
          ),
        ),

        // ── Section 3: Session Timing ─────────────────────────────
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Session timing — your confirmed windows (EAT)',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              const _EdgeRow(
                label: '09:00–10:30 EAT — dead zone',
                labelColor: AppTheme.red,
                sub: 'EURUSD: 24 trades, 23 straight losses',
                val: '4.2% WR',
                valSub: '-\$71.17',
                valColor: AppTheme.red,
                active: true,
              ),
              const _EdgeRow(
                label: '10:30–13:00 EAT — mid London',
                sub: 'EU sells valid. Small sample but promising',
                val: '66.7% WR',
                valSub: '+\$15.27',
                valColor: AppTheme.green,
              ),
              const _EdgeRow(
                label: '13:00–15:00 EAT — late London',
                sub: 'All three instruments. Best EU + XAUUSD zone',
                val: 'Prime window',
                valColor: AppTheme.green,
              ),
              const _EdgeRow(
                label: '15:00–16:30 EAT — blackout',
                labelColor: AppTheme.red,
                sub: 'XAUUSD: identical WR inside and outside — coin flip',
                val: '45.5% WR',
                valSub: 'No edge',
                valColor: AppTheme.red,
                active: true,
              ),
              const _EdgeRow(
                label: '16:30–18:30 EAT — NY open',
                sub: 'NQ primary. XAUUSD continuation',
                val: 'Prime window',
                valColor: AppTheme.green,
              ),
              const _EdgeRow(
                label: '20:00+ EAT — NY late',
                labelColor: AppTheme.red,
                sub: 'Thin liquidity, asymmetric losses',
                val: '50% WR',
                valSub: '-\$29.60',
                valColor: AppTheme.red,
                active: true,
              ),
            ],
          ),
        ),

        // ── Section 4: EURUSD Deep Dive ──────────────────────────
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EURUSD deep dive — direction bias confirmed',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _BiasCard(
                      title: 'Buying EURUSD',
                      tone: AppTheme.red,
                      trades: '29 trades',
                      wr: '13.8% WR',
                      net: 'Net: -\$6.05',
                      footnote: '25 of 29 buys hit SL',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _BiasCard(
                      title: 'Selling EURUSD',
                      tone: AppTheme.green,
                      trades: '11 trades',
                      wr: '54.5% WR',
                      net: 'Net: +\$56.75',
                      footnote: 'Your real EU edge',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _sectionLabel(context, 'EU day-of-week breakdown'),
              const _EdgeRow(
                label: 'Thursday',
                sub: '9 trades',
                val: '44.4% WR · +\$72.07',
                valColor: AppTheme.green,
                percent: 44,
              ),
              const _EdgeRow(
                label: 'Monday',
                sub: '5 trades',
                val: '20% WR · +\$41.22',
                valColor: AppTheme.green,
                percent: 20,
              ),
              const _EdgeRow(
                label: 'Tuesday',
                sub: '19 trades',
                val: '26.3% WR · +\$20.61',
                valColor: AppTheme.amber,
                percent: 26,
              ),
              const _EdgeRow(
                label: 'Wednesday',
                labelColor: AppTheme.red,
                sub: '5 trades',
                val: '0% WR · -\$44.30',
                valColor: AppTheme.red,
                percent: 0,
                active: true,
              ),
              const _EdgeRow(
                label: 'Friday',
                labelColor: AppTheme.red,
                sub: '2 trades',
                val: '0% WR · -\$38.90',
                valColor: AppTheme.red,
                percent: 0,
                active: true,
              ),
              const SizedBox(height: 14),
              const _AlertBox(
                tone: AppTheme.amber,
                title: 'EU ENTRY RULE — ALL 4 REQUIRED',
                body:
                    'Thursday or Monday · 13:00–16:30 EAT · HTF bearish (sell only) · Single entry only. Missing even one condition = no trade.',
              ),
            ],
          ),
        ),

        // ── Section 5: Stacking vs Single Entry ──────────────────
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Stacking vs single entry — the definitive case',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _BiasCard(
                      title: 'Single entry days',
                      tone: AppTheme.green,
                      trades: '',
                      wr: '50% WR',
                      net: '+\$103.61 · 16 days',
                      footnote: 'One entry with conviction — the math works',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _BiasCard(
                      title: 'Stacked days',
                      tone: AppTheme.red,
                      trades: '',
                      wr: '8.3% WR',
                      net: '-\$52.91 · 6 days',
                      footnote:
                          'Re-entering after loss — not finding new setups',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Section 6: Behavioural Flags ─────────────────────────
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Behavioural flags — confirmed patterns',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 14),
              const _AlertBox(
                tone: AppTheme.red,
                title: 'STACKING (CRITICAL)',
                body:
                    'Personal account: 3–56 trades per day. EU stacked days: 8.3% WR. Single entry days: 50% WR. After any losing trade, wait 60 minutes minimum before re-entry on same instrument.',
              ),
              const SizedBox(height: 10),
              const _AlertBox(
                tone: AppTheme.red,
                title: 'EARLY LONDON EXECUTION',
                body:
                    '09:00–10:30 EAT: 23 consecutive EURUSD losses. 4.2% WR. Hard no-trade zone — treat it as a second blackout.',
              ),
              const SizedBox(height: 10),
              const _AlertBox(
                tone: AppTheme.amber,
                title: 'EU BUY BIAS',
                body:
                    '29 buys → 13.8% WR · 11 sells → 54.5% WR. Default to sells until macro structure shifts bullish on H4/Daily.',
              ),
              const SizedBox(height: 10),
              const _AlertBox(
                tone: AppTheme.amber,
                title: 'LOT SIZE INCONSISTENCY',
                body:
                    'Personal account: 0.01 to 1.8 lots with no formula. Use the Calculator tab before every trade — 30 seconds, no exceptions.',
              ),
            ],
          ),
        ),

        // ── Section 7: XAUUSD Blackout Zone ──────────────────────
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('XAUUSD blackout zone — the confirmed verdict',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 14),
              _statGrid(const [
                _StatBox(
                    label: 'WR inside blackout',
                    value: '45.5%',
                    tone: AppTheme.amber),
                _StatBox(
                    label: 'WR after blackout',
                    value: '45.5%',
                    tone: AppTheme.amber),
                _StatBox(
                    label: 'Net inside (raw)',
                    value: '+\$259',
                    tone: AppTheme.amber),
                _StatBox(
                    label: 'Net (remove outlier)',
                    value: '-\$67.19',
                    tone: AppTheme.red),
              ]),
              const SizedBox(height: 14),
              const _AlertBox(
                tone: AppTheme.red,
                title: 'THE +\$192.60 OUTLIER',
                body:
                    'The entire positive P&L inside the blackout is carried by one trade on Jan 20. Remove it and the window returns -\$67 on 10 trades. That is not an edge — it is lottery trading. The blackout stands.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Edge tab helper widgets ──────────────────────────────────────────

Widget _sectionLabel(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: context.c.textTertiary,
      ),
    ),
  );
}

class _StatBox extends StatelessWidget {
  const _StatBox(
      {required this.label, required this.value, required this.tone});
  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.c.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: context.c.textTertiary)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    letterSpacing: -0.5,
                    color: tone)),
          ),
        ],
      ),
    );
  }
}

/// Arranges stat boxes in a uniform 2-column grid so they fit neatly.
Widget _statGrid(List<Widget> items) {
  const spacing = 8.0;
  final rows = <Widget>[];
  for (var i = 0; i < items.length; i += 2) {
    final left = items[i];
    final right = i + 1 < items.length ? items[i + 1] : const SizedBox.shrink();
    rows.add(Padding(
      padding: EdgeInsets.only(bottom: i + 2 < items.length ? spacing : 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: left),
            const SizedBox(width: spacing),
            Expanded(child: right),
          ],
        ),
      ),
    ));
  }
  return Column(children: rows);
}

class _EdgeRow extends StatelessWidget {
  const _EdgeRow({
    required this.label,
    required this.sub,
    required this.val,
    required this.valColor,
    this.valSub,
    this.percent,
    this.labelColor,
    this.active = false,
  });
  final String label;
  final String sub;
  final String val;
  final String? valSub;
  final Color valColor;
  final double? percent;
  final Color? labelColor;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: active ? 14 : 0),
      decoration: active
          ? BoxDecoration(
              color: AppTheme.red.withValues(alpha: 0.06),
              border: Border(left: BorderSide(color: AppTheme.red, width: 3)),
              borderRadius: BorderRadius.circular(4),
            )
          : BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: context.c.border, width: 0.5)),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: labelColor ?? context.c.text,
                    )),
                const SizedBox(height: 2),
                Text(sub,
                    style:
                        TextStyle(fontSize: 11, color: context.c.textTertiary)),
              ],
            ),
          ),
          if (percent != null) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(1),
                    child: LinearProgressIndicator(
                      value: (percent! / 100).clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: context.c.border,
                      color: valColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(val,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valColor,
                  )),
              if (valSub != null) ...[
                const SizedBox(height: 2),
                Text(valSub!,
                    style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: context.c.textTertiary)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BiasCard extends StatelessWidget {
  const _BiasCard({
    required this.title,
    required this.tone,
    required this.trades,
    required this.wr,
    required this.net,
    required this.footnote,
  });
  final String title;
  final Color tone;
  final String trades;
  final String wr;
  final String net;
  final String footnote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tone.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: tone)),
          if (trades.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(trades,
                style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: tone.withValues(alpha: 0.7))),
          ],
          const SizedBox(height: 4),
          Text(wr,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  letterSpacing: -0.5,
                  color: tone)),
          const SizedBox(height: 2),
          Text(net,
              style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: tone.withValues(alpha: 0.7))),
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border:
                  Border(top: BorderSide(color: tone.withValues(alpha: 0.2))),
            ),
            child: Text(footnote.toUpperCase(),
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: tone.withValues(alpha: 0.5))),
          ),
        ],
      ),
    );
  }
}

class _AlertBox extends StatelessWidget {
  const _AlertBox(
      {required this.tone, required this.title, required this.body});
  final Color tone;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tone.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: tone)),
          const SizedBox(height: 6),
          Text(body,
              style: TextStyle(
                  fontSize: 12, height: 1.5, color: context.c.textSecondary)),
        ],
      ),
    );
  }
}

/// Live stats computed from challenge trades.
class _LiveStats {
  final int total;
  final int wins;
  final double netPnl;
  final double winRate;
  final double avgWin;
  final double avgLoss;
  final Map<String, _SymbolStats> bySymbol;

  _LiveStats({
    required this.total,
    required this.wins,
    required this.netPnl,
    required this.winRate,
    required this.avgWin,
    required this.avgLoss,
    required this.bySymbol,
  });

  factory _LiveStats.compute(List<Trade> trades) {
    if (trades.isEmpty) {
      return _LiveStats(
        total: 0,
        wins: 0,
        netPnl: 0,
        winRate: 0,
        avgWin: 0,
        avgLoss: 0,
        bySymbol: {},
      );
    }

    final wins = trades.where((t) => t.pnl > 0).toList();
    final losses = trades.where((t) => t.pnl < 0).toList();
    final netPnl = trades.fold<double>(0, (s, t) => s + t.pnl);
    final avgWin = wins.isEmpty
        ? 0.0
        : wins.fold<double>(0, (s, t) => s + t.pnl) / wins.length;
    final avgLoss = losses.isEmpty
        ? 0.0
        : losses.fold<double>(0, (s, t) => s + t.pnl) / losses.length;

    final Map<String, List<Trade>> grouped = {};
    for (final t in trades) {
      grouped.putIfAbsent(t.sym, () => []).add(t);
    }
    final bySymbol =
        grouped.map((sym, list) => MapEntry(sym, _SymbolStats.compute(list)));

    return _LiveStats(
      total: trades.length,
      wins: wins.length,
      netPnl: netPnl,
      winRate: (wins.length / trades.length) * 100,
      avgWin: avgWin,
      avgLoss: avgLoss,
      bySymbol: bySymbol,
    );
  }
}

class _SymbolStats {
  final int total;
  final double winRate;
  final double netPnl;

  _SymbolStats(
      {required this.total, required this.winRate, required this.netPnl});

  factory _SymbolStats.compute(List<Trade> trades) {
    final wins = trades.where((t) => t.pnl > 0).length;
    final net = trades.fold<double>(0, (s, t) => s + t.pnl);
    return _SymbolStats(
      total: trades.length,
      winRate: trades.isEmpty ? 0 : (wins / trades.length) * 100,
      netPnl: net,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  TAB 4: SETTINGS
// ═══════════════════════════════════════════════════════════════════════

class _SettingsTab extends StatefulWidget {
  const _SettingsTab({required this.controller});
  final TradingController controller;

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  late final balanceCtrl = TextEditingController(
      text: widget.controller.state.balance.toStringAsFixed(2));
  late final startCtrl =
      TextEditingController(text: widget.controller.state.startDate);
  late final priorCtrl = TextEditingController(
      text: widget.controller.state.priorPnl.toStringAsFixed(2));
  late final importCtrl = TextEditingController();

  @override
  void dispose() {
    balanceCtrl.dispose();
    startCtrl.dispose();
    priorCtrl.dispose();
    importCtrl.dispose();
    super.dispose();
  }

  Future<void> _exportData(String format, TradingController c) async {
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
              content: Text('Exported ${format.toUpperCase()} data copied.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed.')),
        );
      }
    }
  }

  Future<ImportResult?> _importDialog(
      BuildContext context, TradingController c) async {
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
          final canImport = !isBusy &&
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
              'Resulting trades', '${preview.resultingCount}'),
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
            child: Text(label,
                style: TextStyle(fontSize: 12, color: context.c.textSecondary)),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.c.text)),
        ],
      ),
    );
  }

  Future<void> _showImportReportDialog(
      BuildContext context, ImportResult result) async {
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
        Text('Settings',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: 24)),
        const SizedBox(height: 4),
        Text('Challenge configuration & data',
            style: TextStyle(color: context.c.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Appearance',
                  style: Theme.of(context).textTheme.titleMedium),
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    const InputDecoration(labelText: 'Starting balance'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: startCtrl,
                decoration:
                    const InputDecoration(labelText: 'Start date (YYYY-MM-DD)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priorCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result.message)),
                      );
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

// ═══════════════════════════════════════════════════════════════════════
//  SHARED PRIMITIVES — minimal, reusable components
// ═══════════════════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.c.border),
      ),
      child: child,
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile(
      {required this.label, required this.value, required this.tone});
  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: context.c.textTertiary, fontSize: 11)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: tone, fontWeight: FontWeight.w700, fontSize: 18)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.tone});
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              color: tone, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow(this.label, this.value, this.tone);
  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(color: context.c.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: tone, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

/// Radial score ring painted around the readiness number.
class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter(this.score, this.color, this.bgColor);
  final int score;
  final Color color;
  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect.deflate(2), -math.pi / 2, 2 * math.pi, false, bg);
    canvas.drawArc(
        rect.deflate(2), -math.pi / 2, 2 * math.pi * (score / 100), false, fg);
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter old) =>
      old.score != score || old.color != color || old.bgColor != bgColor;
}

// ═══════════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════════

Color _sessionTone(BuildContext context, String type) {
  switch (type) {
    case 'green':
      return AppTheme.green;
    case 'red':
      return AppTheme.red;
    case 'amber':
      return AppTheme.amber;
    default:
      return context.c.textTertiary;
  }
}

String _eatTime(DateTime dt) {
  return '${dt.toUtc().hour.toString().padLeft(2, '0')}:'
      '${dt.toUtc().minute.toString().padLeft(2, '0')}:'
      '${dt.toUtc().second.toString().padLeft(2, '0')} EAT';
}

String _compact(double v) {
  if (v.abs() >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}k';
  return '\$${v.toStringAsFixed(0)}';
}

String _signed(double v) {
  final s = v >= 0 ? '+' : '';
  return '$s\$${v.toStringAsFixed(0)}';
}

// -----------------------------------------------------------------------
//  THEME TOGGLE
// -----------------------------------------------------------------------

/// Quick icon button that cycles System ? Light ? Dark.
class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({required this.controller});
  final TradingController controller;

  IconData _iconFor(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }

  String _labelFor(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'Light theme';
      case ThemeMode.dark:
        return 'Dark theme';
      case ThemeMode.system:
        return 'System theme';
    }
  }

  ThemeMode _next(ThemeMode m) {
    switch (m) {
      case ThemeMode.system:
        return ThemeMode.light;
      case ThemeMode.light:
        return ThemeMode.dark;
      case ThemeMode.dark:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = controller.themeMode;
    return IconButton(
      onPressed: () => controller.setThemeMode(_next(mode)),
      icon: Icon(_iconFor(mode), color: context.c.textTertiary, size: 22),
      tooltip: _labelFor(mode),
    );
  }
}

/// 3-way segmented control for ThemeMode (Settings screen).
class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({required this.controller});
  final TradingController controller;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.brightness_auto_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.light_mode_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode_outlined),
        ),
      ],
      selected: {controller.themeMode},
      onSelectionChanged: (s) => controller.setThemeMode(s.first),
      showSelectedIcon: false,
    );
  }
}
