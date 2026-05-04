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
  allTrades:
      (json['allTrades'] as List<dynamic>?)
          ?.map((e) => Trade.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  lock: json['lock'] as bool? ?? false,
  lockUntil: (json['lockUntil'] as num?)?.toInt(),
  preloaded: json['preloaded'] as bool? ?? false,
);

Map<String, dynamic> _$AppStateToJson(_AppState instance) => <String, dynamic>{
  'schemaVersion': instance.schemaVersion,
  'balance': instance.balance,
  'startDate': instance.startDate,
  'priorPnl': instance.priorPnl,
  'checks': instance.checks,
  'allTrades': instance.allTrades.map((e) => e.toJson()).toList(),
  'lock': instance.lock,
  'lockUntil': instance.lockUntil,
  'preloaded': instance.preloaded,
};
