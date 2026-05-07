// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Trade _$TradeFromJson(Map<String, dynamic> json) => _Trade(
  id: json['id'] as String,
  date: json['date'] as String,
  time: json['time'] as String,
  sym: json['sym'] as String? ?? 'XAUUSD',
  dir: json['dir'] as String? ?? 'buy',
  lots: (json['lots'] as num?)?.toDouble() ?? 0.0,
  pnl: (json['pnl'] as num?)?.toDouble() ?? 0.0,
  note: json['note'] as String? ?? '',
  violations:
      (json['violations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  htfImage: json['htfImage'] as String?,
  ltfImage: json['ltfImage'] as String?,
  isHypothetical: json['isHypothetical'] as bool? ?? false,
  setupQuality: json['setupQuality'] as String?,
  trigger: json['trigger'] as String?,
  reflection: json['reflection'] == null
      ? null
      : TradeReflection.fromJson(json['reflection'] as Map<String, dynamic>),
  plannedRisk: (json['plannedRisk'] as num?)?.toDouble(),
  ticketId: json['ticketId'] as String?,
  openDate: json['openDate'] as String?,
  openTime: json['openTime'] as String?,
  openPrice: (json['openPrice'] as num?)?.toDouble(),
  closePrice: (json['closePrice'] as num?)?.toDouble(),
  stopLoss: (json['stopLoss'] as num?)?.toDouble(),
  takeProfit: (json['takeProfit'] as num?)?.toDouble(),
  commission: (json['commission'] as num?)?.toDouble(),
  swap: (json['swap'] as num?)?.toDouble(),
);

Map<String, dynamic> _$TradeToJson(_Trade instance) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date,
  'time': instance.time,
  'sym': instance.sym,
  'dir': instance.dir,
  'lots': instance.lots,
  'pnl': instance.pnl,
  'note': instance.note,
  'violations': instance.violations,
  'tags': instance.tags,
  'htfImage': instance.htfImage,
  'ltfImage': instance.ltfImage,
  'isHypothetical': instance.isHypothetical,
  'setupQuality': instance.setupQuality,
  'trigger': instance.trigger,
  'reflection': instance.reflection?.toJson(),
  'plannedRisk': instance.plannedRisk,
  'ticketId': instance.ticketId,
  'openDate': instance.openDate,
  'openTime': instance.openTime,
  'openPrice': instance.openPrice,
  'closePrice': instance.closePrice,
  'stopLoss': instance.stopLoss,
  'takeProfit': instance.takeProfit,
  'commission': instance.commission,
  'swap': instance.swap,
};

_TradeReflection _$TradeReflectionFromJson(Map<String, dynamic> json) =>
    _TradeReflection(
      followedPlan: json['followedPlan'] as bool,
      exitReason: json['exitReason'] as String,
      emotionalState: (json['emotionalState'] as num).toInt(),
    );

Map<String, dynamic> _$TradeReflectionToJson(_TradeReflection instance) =>
    <String, dynamic>{
      'followedPlan': instance.followedPlan,
      'exitReason': instance.exitReason,
      'emotionalState': instance.emotionalState,
    };

_WizardDraft _$WizardDraftFromJson(Map<String, dynamic> json) => _WizardDraft(
  step: (json['step'] as num?)?.toInt() ?? 0,
  instrument: json['instrument'] as String? ?? 'XAUUSD',
  stopLoss: json['stopLoss'] as String? ?? '7',
  entries: json['entries'] as String? ?? '1',
  takeProfit: json['takeProfit'] as String?,
  planImagePath: json['planImagePath'] as String?,
);

Map<String, dynamic> _$WizardDraftToJson(_WizardDraft instance) =>
    <String, dynamic>{
      'step': instance.step,
      'instrument': instance.instrument,
      'stopLoss': instance.stopLoss,
      'entries': instance.entries,
      'takeProfit': instance.takeProfit,
      'planImagePath': instance.planImagePath,
    };

_DailyMood _$DailyMoodFromJson(Map<String, dynamic> json) => _DailyMood(
  mood: json['mood'] as String,
  note: json['note'] as String? ?? '',
  timestamp: (json['timestamp'] as num).toInt(),
);

Map<String, dynamic> _$DailyMoodToJson(_DailyMood instance) =>
    <String, dynamic>{
      'mood': instance.mood,
      'note': instance.note,
      'timestamp': instance.timestamp,
    };

_WeeklyDigest _$WeeklyDigestFromJson(Map<String, dynamic> json) =>
    _WeeklyDigest(
      weekId: json['weekId'] as String,
      generatedAt: (json['generatedAt'] as num).toInt(),
      win: json['win'] as String,
      worstHabit: json['worstHabit'] as String,
      oneFix: json['oneFix'] as String,
      seen: json['seen'] as bool? ?? false,
    );

Map<String, dynamic> _$WeeklyDigestToJson(_WeeklyDigest instance) =>
    <String, dynamic>{
      'weekId': instance.weekId,
      'generatedAt': instance.generatedAt,
      'win': instance.win,
      'worstHabit': instance.worstHabit,
      'oneFix': instance.oneFix,
      'seen': instance.seen,
    };

_PropFirmRules _$PropFirmRulesFromJson(Map<String, dynamic> json) =>
    _PropFirmRules(
      maxDailyDrawdown: (json['maxDailyDrawdown'] as num?)?.toDouble() ?? 0.0,
      maxTotalDrawdown: (json['maxTotalDrawdown'] as num?)?.toDouble() ?? 0.0,
      firmName: json['firmName'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? false,
    );

Map<String, dynamic> _$PropFirmRulesToJson(_PropFirmRules instance) =>
    <String, dynamic>{
      'maxDailyDrawdown': instance.maxDailyDrawdown,
      'maxTotalDrawdown': instance.maxTotalDrawdown,
      'firmName': instance.firmName,
      'enabled': instance.enabled,
    };

_WeeklyRiskBudget _$WeeklyRiskBudgetFromJson(Map<String, dynamic> json) =>
    _WeeklyRiskBudget(
      enabled: json['enabled'] as bool? ?? false,
      rUnitUsd: (json['rUnitUsd'] as num?)?.toDouble() ?? 125.0,
      weeklyBudgetR: (json['weeklyBudgetR'] as num?)?.toDouble() ?? 10.0,
    );

Map<String, dynamic> _$WeeklyRiskBudgetToJson(_WeeklyRiskBudget instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'rUnitUsd': instance.rUnitUsd,
      'weeklyBudgetR': instance.weeklyBudgetR,
    };

_IntegrityEvent _$IntegrityEventFromJson(Map<String, dynamic> json) =>
    _IntegrityEvent(
      id: json['id'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      type: json['type'] as String,
      detail: json['detail'] as String? ?? '',
    );

Map<String, dynamic> _$IntegrityEventToJson(_IntegrityEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp,
      'type': instance.type,
      'detail': instance.detail,
    };

_TradingAccount _$TradingAccountFromJson(Map<String, dynamic> json) =>
    _TradingAccount(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: (json['balance'] as num?)?.toDouble() ?? 25000.0,
      startDate: json['startDate'] as String? ?? '2026-04-20',
      priorPnl: (json['priorPnl'] as num?)?.toDouble() ?? 0.0,
      allTrades:
          (json['allTrades'] as List<dynamic>?)
              ?.map((e) => Trade.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lock: json['lock'] as bool? ?? false,
      lockUntil: (json['lockUntil'] as num?)?.toInt(),
      propFirmRules: json['propFirmRules'] == null
          ? const PropFirmRules()
          : PropFirmRules.fromJson(
              json['propFirmRules'] as Map<String, dynamic>,
            ),
      weeklyRiskBudget: json['weeklyRiskBudget'] == null
          ? const WeeklyRiskBudget()
          : WeeklyRiskBudget.fromJson(
              json['weeklyRiskBudget'] as Map<String, dynamic>,
            ),
      dailyTradeCap: (json['dailyTradeCap'] as num?)?.toInt() ?? 2,
    );

Map<String, dynamic> _$TradingAccountToJson(_TradingAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'balance': instance.balance,
      'startDate': instance.startDate,
      'priorPnl': instance.priorPnl,
      'allTrades': instance.allTrades.map((e) => e.toJson()).toList(),
      'lock': instance.lock,
      'lockUntil': instance.lockUntil,
      'propFirmRules': instance.propFirmRules.toJson(),
      'weeklyRiskBudget': instance.weeklyRiskBudget.toJson(),
      'dailyTradeCap': instance.dailyTradeCap,
    };

_NotificationPrefs _$NotificationPrefsFromJson(Map<String, dynamic> json) =>
    _NotificationPrefs(
      master: json['master'] as bool? ?? true,
      drawdown: json['drawdown'] as bool? ?? true,
      riskBudget: json['riskBudget'] as bool? ?? true,
      lock: json['lock'] as bool? ?? true,
      streak: json['streak'] as bool? ?? true,
      dailyCap: json['dailyCap'] as bool? ?? true,
      newsImminent: json['newsImminent'] as bool? ?? true,
      moodReminder: json['moodReminder'] as bool? ?? true,
      backupReminder: json['backupReminder'] as bool? ?? true,
    );

Map<String, dynamic> _$NotificationPrefsToJson(_NotificationPrefs instance) =>
    <String, dynamic>{
      'master': instance.master,
      'drawdown': instance.drawdown,
      'riskBudget': instance.riskBudget,
      'lock': instance.lock,
      'streak': instance.streak,
      'dailyCap': instance.dailyCap,
      'newsImminent': instance.newsImminent,
      'moodReminder': instance.moodReminder,
      'backupReminder': instance.backupReminder,
    };

_AppState _$AppStateFromJson(Map<String, dynamic> json) => _AppState(
  schemaVersion:
      (json['schemaVersion'] as num?)?.toInt() ?? kCurrentSchemaVersion,
  balance: (json['balance'] as num?)?.toDouble() ?? 25000.0,
  startDate: json['startDate'] as String? ?? '2026-04-20',
  priorPnl: (json['priorPnl'] as num?)?.toDouble() ?? 0.0,
  checks:
      (json['checks'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const {},
  gateProofs:
      (json['gateProofs'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  allTrades:
      (json['allTrades'] as List<dynamic>?)
          ?.map((e) => Trade.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  lock: json['lock'] as bool? ?? false,
  lockUntil: (json['lockUntil'] as num?)?.toInt(),
  preloaded: json['preloaded'] as bool? ?? false,
  integrityLog:
      (json['integrityLog'] as List<dynamic>?)
          ?.map((e) => IntegrityEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  lastResetAt: (json['lastResetAt'] as num?)?.toInt(),
  dailyMoods:
      (json['dailyMoods'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, DailyMood.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  weeklyDigests:
      (json['weeklyDigests'] as List<dynamic>?)
          ?.map((e) => WeeklyDigest.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  propFirmRules: json['propFirmRules'] == null
      ? const PropFirmRules()
      : PropFirmRules.fromJson(json['propFirmRules'] as Map<String, dynamic>),
  weeklyRiskBudget: json['weeklyRiskBudget'] == null
      ? const WeeklyRiskBudget()
      : WeeklyRiskBudget.fromJson(
          json['weeklyRiskBudget'] as Map<String, dynamic>,
        ),
  blockTradesAroundNews: json['blockTradesAroundNews'] as bool? ?? false,
  localOnlyAiMode: json['localOnlyAiMode'] as bool? ?? false,
  dailyTradeCap: (json['dailyTradeCap'] as num?)?.toInt() ?? 2,
  accounts:
      (json['accounts'] as List<dynamic>?)
          ?.map((e) => TradingAccount.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  activeAccountId: json['activeAccountId'] as String?,
  notificationPrefs: json['notificationPrefs'] == null
      ? const NotificationPrefs()
      : NotificationPrefs.fromJson(
          json['notificationPrefs'] as Map<String, dynamic>,
        ),
  riskCapUsd: (json['riskCapUsd'] as num?)?.toDouble() ?? 125.0,
  wizardDraft: json['wizardDraft'] == null
      ? null
      : WizardDraft.fromJson(json['wizardDraft'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AppStateToJson(_AppState instance) => <String, dynamic>{
  'schemaVersion': instance.schemaVersion,
  'balance': instance.balance,
  'startDate': instance.startDate,
  'priorPnl': instance.priorPnl,
  'checks': instance.checks,
  'gateProofs': instance.gateProofs,
  'allTrades': instance.allTrades.map((e) => e.toJson()).toList(),
  'lock': instance.lock,
  'lockUntil': instance.lockUntil,
  'preloaded': instance.preloaded,
  'integrityLog': instance.integrityLog.map((e) => e.toJson()).toList(),
  'lastResetAt': instance.lastResetAt,
  'dailyMoods': instance.dailyMoods.map((k, e) => MapEntry(k, e.toJson())),
  'weeklyDigests': instance.weeklyDigests.map((e) => e.toJson()).toList(),
  'propFirmRules': instance.propFirmRules.toJson(),
  'weeklyRiskBudget': instance.weeklyRiskBudget.toJson(),
  'blockTradesAroundNews': instance.blockTradesAroundNews,
  'localOnlyAiMode': instance.localOnlyAiMode,
  'dailyTradeCap': instance.dailyTradeCap,
  'accounts': instance.accounts.map((e) => e.toJson()).toList(),
  'activeAccountId': instance.activeAccountId,
  'notificationPrefs': instance.notificationPrefs.toJson(),
  'riskCapUsd': instance.riskCapUsd,
  'wizardDraft': instance.wizardDraft?.toJson(),
};
