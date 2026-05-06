import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'schema_migration.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@freezed
abstract class Trade with _$Trade {
  const factory Trade({
    required String id,
    required String date,
    required String time,
    @Default('XAUUSD') String sym,
    @Default('buy') String dir,
    @Default(0.0) double lots,
    @Default(0.0) double pnl,
    @Default('') String note,
    @Default([]) List<String> violations,
    @Default([]) List<String> tags,
    String? htfImage,
    String? ltfImage,
    @Default(false) bool isHypothetical,

    /// Mandatory setup grade for new trades. One of: A+, B, C.
    /// Nullable so historical trades imported before Sprint 2.1 still load.
    String? setupQuality,

    /// Mandatory trigger that caused the trade. One of:
    /// Plan, FOMO, Revenge, Boredom, News, Other.
    String? trigger,

    /// Optional 30-second post-trade reflection (Sprint 2.2).
    TradeReflection? reflection,

    /// Sprint 4.3 — planned $ risk at entry (from calculator). Nullable
    /// so older trades still deserialize.
    double? plannedRisk,
  }) = _Trade;

  factory Trade.fromJson(Map<String, dynamic> json) => _$TradeFromJson(json);
}

/// 30-second post-trade reflection captured immediately after a trade is
/// logged. Builds the trader's behavioral fingerprint over time.
@freezed
abstract class TradeReflection with _$TradeReflection {
  const factory TradeReflection({
    required bool followedPlan,

    /// One of: TP, SL, Manual, Time.
    required String exitReason,

    /// 1 (terrible) — 10 (locked-in).
    required int emotionalState,
  }) = _TradeReflection;

  factory TradeReflection.fromJson(Map<String, dynamic> json) =>
      _$TradeReflectionFromJson(json);
}

/// 1-tap mood check-in captured on first app open of the day.
/// Lets the engine correlate emotional state with trade outcomes.
@freezed
abstract class DailyMood with _$DailyMood {
  const factory DailyMood({
    /// One of: Tired, Neutral, Sharp, Frustrated, Hyped.
    required String mood,
    @Default('') String note,
    required int timestamp, // ms since epoch
  }) = _DailyMood;

  factory DailyMood.fromJson(Map<String, dynamic> json) =>
      _$DailyMoodFromJson(json);
}

/// Sunday evening 3-bullet digest produced by Gemini once per week.
@freezed
abstract class WeeklyDigest with _$WeeklyDigest {
  const factory WeeklyDigest({
    required String weekId, // ISO week label e.g. "2026-W18"
    required int generatedAt, // ms since epoch
    required String win, // "Your A+ setups produced +$340 this week."
    required String worstHabit, // "60% of trades were FOMO. Worst day: Wed."
    required String oneFix, // "Skip trades after 2 losses..."
    @Default(false) bool seen,
  }) = _WeeklyDigest;

  factory WeeklyDigest.fromJson(Map<String, dynamic> json) =>
      _$WeeklyDigestFromJson(json);
}

/// Sprint 4.1 — Prop-firm drawdown rules. Null/zero values disable the
/// corresponding limit. All amounts in account currency (USD).
@freezed
abstract class PropFirmRules with _$PropFirmRules {
  const factory PropFirmRules({
    /// Max single-day loss the firm tolerates (e.g. $1000 on a $25k account).
    @Default(0.0) double maxDailyDrawdown,

    /// Max trailing drawdown from peak balance (e.g. $2000).
    @Default(0.0) double maxTotalDrawdown,

    /// Optional firm name for display ("FTMO", "MyForexFunds", etc).
    @Default('') String firmName,

    /// Whether the user has opted in to prop-firm enforcement.
    @Default(false) bool enabled,
  }) = _PropFirmRules;

  factory PropFirmRules.fromJson(Map<String, dynamic> json) =>
      _$PropFirmRulesFromJson(json);
}

/// Sprint 4.2 — Weekly risk budget. Resets every Monday (EAT).
/// `rUnitUsd` is the dollar size of 1R; `weeklyBudgetR` is how many R the
/// trader is allowed to lose per week.
@freezed
abstract class WeeklyRiskBudget with _$WeeklyRiskBudget {
  const factory WeeklyRiskBudget({
    @Default(false) bool enabled,
    @Default(125.0) double rUnitUsd,
    @Default(10.0) double weeklyBudgetR,
  }) = _WeeklyRiskBudget;

  factory WeeklyRiskBudget.fromJson(Map<String, dynamic> json) =>
      _$WeeklyRiskBudgetFromJson(json);
}

/// Audit-trail entry for irreversible / accountability-relevant actions
/// (resets, lock overrides, balance changes). Lives forever — never pruned —
/// so the trader can always see their own behavioural history.
@freezed
abstract class IntegrityEvent with _$IntegrityEvent {
  const factory IntegrityEvent({
    required String id,
    required int timestamp, // ms since epoch
    required String
    type, // reset_today | reset_all | balance_changed | lock_override
    @Default('') String detail,
  }) = _IntegrityEvent;

  factory IntegrityEvent.fromJson(Map<String, dynamic> json) =>
      _$IntegrityEventFromJson(json);
}

/// Sprint 6.5 — Snapshot of one inactive trading account.
@freezed
abstract class TradingAccount with _$TradingAccount {
  const factory TradingAccount({
    required String id,
    required String name,
    @Default(25000.0) double balance,
    @Default('2026-04-20') String startDate,
    @Default(0.0) double priorPnl,
    @Default([]) List<Trade> allTrades,
    @Default(false) bool lock,
    int? lockUntil,
    @Default(PropFirmRules()) PropFirmRules propFirmRules,
    @Default(WeeklyRiskBudget()) WeeklyRiskBudget weeklyRiskBudget,
    @Default(2) int dailyTradeCap,
  }) = _TradingAccount;

  factory TradingAccount.fromJson(Map<String, dynamic> json) =>
      _$TradingAccountFromJson(json);
}

/// Per-category notification toggles. Lives on [AppState] so user
/// preferences survive across launches like every other setting.
@freezed
abstract class NotificationPrefs with _$NotificationPrefs {
  const factory NotificationPrefs({
    /// Master kill-switch. When false, every category is suppressed
    /// regardless of its individual flag.
    @Default(true) bool master,
    @Default(true) bool drawdown,
    @Default(true) bool riskBudget,
    @Default(true) bool lock,
    @Default(true) bool streak,
    @Default(true) bool dailyCap,
    @Default(true) bool newsImminent,
    @Default(true) bool moodReminder,
    @Default(true) bool backupReminder,
  }) = _NotificationPrefs;

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) =>
      _$NotificationPrefsFromJson(json);
}

@freezed
abstract class AppState with _$AppState {
  const AppState._(); // Added for custom methods

  const factory AppState({
    @Default(kCurrentSchemaVersion) int schemaVersion,
    @Default(25000.0) double balance,
    @Default('2026-04-20') String startDate,
    @Default(0.0) double priorPnl,
    @Default({}) Map<String, bool> checks,
    @Default({}) Map<String, String> gateProofs,
    @Default([]) List<Trade> allTrades,
    @Default(false) bool lock,
    int? lockUntil,
    @Default(false) bool preloaded,
    @Default([]) List<IntegrityEvent> integrityLog,
    int? lastResetAt,

    /// Map of `YYYY-MM-DD` (EAT) → mood check-in for that day.
    @Default({}) Map<String, DailyMood> dailyMoods,

    /// Most recent generated weekly digests (newest first). Capped at ~12.
    @Default([]) List<WeeklyDigest> weeklyDigests,

    /// Sprint 4.1 — optional prop-firm drawdown rules.
    @Default(PropFirmRules()) PropFirmRules propFirmRules,

    /// Sprint 4.2 — optional weekly risk budget (R-units per week).
    @Default(WeeklyRiskBudget()) WeeklyRiskBudget weeklyRiskBudget,

    /// Sprint 4.4 — block trade logging within ±15 min of high-impact news.
    @Default(false) bool blockTradesAroundNews,

    /// Sprint 5.3 — Local-only AI mode. When true, all Gemini cloud calls
    /// are short-circuited and rule-based fallbacks are used instead.
    @Default(false) bool localOnlyAiMode,

    /// Sprint 6.3 — User-configurable daily trade cap (default 2).
    /// Allowed values: 1, 2, 3, 5.
    @Default(2) int dailyTradeCap,

    /// Sprint 6.5 — Multi-account support. Snapshots of inactive accounts.
    /// The currently-active account always lives in the top-level fields
    /// above; switching packs current values into `accounts` and unpacks
    /// the target snapshot in their place.
    @Default([]) List<TradingAccount> accounts,
    String? activeAccountId,

    /// Post-Tier-1 — per-category local-notification toggles.
    @Default(NotificationPrefs()) NotificationPrefs notificationPrefs,
  }) = _AppState;

  factory AppState.defaults() => const AppState();

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);

  String toPrettyJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }
}

/// Allowed setup-quality grades. Order is intentional (best → worst).
const List<String> kSetupQualities = <String>['A+', 'B', 'C'];

/// Allowed trade triggers. Order matches the picker layout in the log sheet.
const List<String> kTradeTriggers = <String>[
  'Plan',
  'FOMO',
  'Revenge',
  'Boredom',
  'News',
  'Other',
];

/// Canonical exit reasons for the post-trade reflection.
const List<String> kExitReasons = <String>['TP', 'SL', 'Manual', 'Time'];

/// Canonical mood options for the daily check-in.
class MoodOption {
  const MoodOption(this.id, this.emoji, this.label);
  final String id;
  final String emoji;
  final String label;
}

const List<MoodOption> kMoodOptions = <MoodOption>[
  MoodOption('Tired', '😴', 'Tired'),
  MoodOption('Neutral', '😐', 'Neutral'),
  MoodOption('Sharp', '😊', 'Sharp'),
  MoodOption('Frustrated', '😤', 'Frustrated'),
  MoodOption('Hyped', '🤩', 'Hyped'),
];

class Gate {
  const Gate({
    required this.id,
    required this.auto,
    required this.label,
    required this.sub,
  });

  final String id;
  final bool auto;
  final String label;
  final String sub;
}

const List<Gate> kGates = <Gate>[
  Gate(
    id: 'g1',
    auto: false,
    label: 'Instrument on watchlist',
    sub: 'XAUUSD, NQ100, or EURUSD only',
  ),
  Gate(
    id: 'g2',
    auto: true,
    label: 'Outside early London dead zone',
    sub: 'Must be outside 09:00-10:30 EAT (4.2% EU WR - hard no-trade)',
  ),
  Gate(
    id: 'g3',
    auto: true,
    label: 'Outside blackout zone',
    sub: 'Must be outside 15:00-16:30 EAT (coin-flip results)',
  ),
  Gate(
    id: 'g4',
    auto: false,
    label: 'HTF trend identified on H4 + Daily',
    sub: 'Written down - not from memory',
  ),
  Gate(
    id: 'g5',
    auto: false,
    label: 'Entry aligns with HTF direction',
    sub: 'No counter-trend trades',
  ),
  Gate(
    id: 'g6',
    auto: false,
    label: 'Liquidity sweep or zone tap confirmed',
    sub: 'Price swept significant high/low or tapped OB/FVG',
  ),
  Gate(
    id: 'g7',
    auto: false,
    label: 'LTF Break of Structure confirmed',
    sub: 'M5 or M15 BOS - not just a wick',
  ),
  Gate(
    id: 'g8',
    auto: true,
    label: 'Trade slots available',
    sub: 'Below your daily trade cap - lock not active',
  ),
  Gate(
    id: 'g9',
    auto: false,
    label: 'Lot size calculated - risk <= 125 USD',
    sub: 'Used the calculator, not guesswork',
  ),
  Gate(
    id: 'g10',
    auto: false,
    label: 'TP >= 2x SL (minimum 250 USD target)',
    sub: 'R:R confirmed 1:2 minimum before entry',
  ),
  Gate(
    id: 'g11',
    auto: true,
    label: 'Friday kill-switch clear',
    sub: 'If Friday: time is before 20:00 EAT',
  ),
  Gate(
    id: 'g12',
    auto: false,
    label: 'Single deployment - combined risk <= 125 USD',
    sub: 'All same-asset entries = one deployment',
  ),
];

class Instrument {
  const Instrument({
    required this.unit,
    required this.pipVal,
    required this.desc,
  });

  final String unit;
  final double pipVal;
  final String desc;
}

const Map<String, Instrument> kInstruments = <String, Instrument>{
  'XAUUSD': Instrument(
    unit: r'$ price move',
    pipVal: 1,
    desc: r'$ move in gold price',
  ),
  'NQ': Instrument(
    unit: 'index points',
    pipVal: 2,
    desc: 'NQ points (1pt = 2 USD per 0.1 lot)',
  ),
  'EURUSD': Instrument(
    unit: 'pips',
    pipVal: 1,
    desc: 'pips (1 pip = 1 USD per 0.1 lot)',
  ),
};

class SessionInfo {
  const SessionInfo({
    required this.label,
    required this.type,
    required this.ok,
    required this.detail,
  });

  final String label;
  final String type;
  final bool ok;
  final String detail;
}
