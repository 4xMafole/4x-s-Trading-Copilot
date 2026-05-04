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
  }) = _Trade;

  factory Trade.fromJson(Map<String, dynamic> json) => _$TradeFromJson(json);
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
    @Default([]) List<Trade> allTrades,
    @Default(false) bool lock,
    int? lockUntil,
    @Default(false) bool preloaded,
  }) = _AppState;

  factory AppState.defaults() => const AppState();

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);

  String toPrettyJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }
}

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
    sub: 'Fewer than 2 trades today - lock not active',
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
