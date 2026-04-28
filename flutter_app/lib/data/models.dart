import 'dart:convert';

class Trade {
  Trade({
    required this.id,
    required this.date,
    required this.time,
    required this.sym,
    required this.dir,
    required this.lots,
    required this.pnl,
    required this.note,
    required this.violations,
    this.htfImage,
    this.ltfImage,
  });

  final String id;
  final String date;
  final String time;
  final String sym;
  final String dir;
  final double lots;
  final double pnl;
  final String note;
  final List<String> violations;
  final String? htfImage; // Higher timeframe chart image path
  final String? ltfImage; // Lower timeframe chart image path

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      sym: json['sym'] as String? ?? 'XAUUSD',
      dir: json['dir'] as String? ?? 'buy',
      lots: (json['lots'] as num?)?.toDouble() ?? 0,
      pnl: (json['pnl'] as num?)?.toDouble() ?? 0,
      note: json['note'] as String? ?? '',
      violations: (json['violations'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      htfImage: json['htfImage'] as String?,
      ltfImage: json['ltfImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'sym': sym,
      'dir': dir,
      'lots': lots,
      'pnl': pnl,
      'note': note,
      'violations': violations,
      'htfImage': htfImage,
      'ltfImage': ltfImage,
    };
  }
}

class AppState {
  AppState({
    required this.balance,
    required this.startDate,
    required this.priorPnl,
    required this.checks,
    required this.allTrades,
    required this.lock,
    required this.lockUntil,
    required this.preloaded,
  });

  final double balance;
  final String startDate;
  final double priorPnl;
  final Map<String, bool> checks;
  final List<Trade> allTrades;
  final bool lock;
  final int? lockUntil;
  final bool preloaded;

  factory AppState.defaults() {
    return AppState(
      balance: 25000,
      startDate: '2026-04-20',
      priorPnl: 0,
      checks: <String, bool>{},
      allTrades: <Trade>[],
      lock: false,
      lockUntil: null,
      preloaded: false,
    );
  }

  AppState copyWith({
    double? balance,
    String? startDate,
    double? priorPnl,
    Map<String, bool>? checks,
    List<Trade>? allTrades,
    bool? lock,
    int? lockUntil,
    bool clearLockUntil = false,
    bool? preloaded,
  }) {
    return AppState(
      balance: balance ?? this.balance,
      startDate: startDate ?? this.startDate,
      priorPnl: priorPnl ?? this.priorPnl,
      checks: checks ?? this.checks,
      allTrades: allTrades ?? this.allTrades,
      lock: lock ?? this.lock,
      lockUntil: clearLockUntil ? null : (lockUntil ?? this.lockUntil),
      preloaded: preloaded ?? this.preloaded,
    );
  }

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      balance: (json['balance'] as num?)?.toDouble() ?? 25000,
      startDate: json['startDate'] as String? ?? '2026-04-20',
      priorPnl: (json['priorPnl'] as num?)?.toDouble() ?? 0,
      checks: (json['checks'] as Map<String, dynamic>? ?? const {}).map(
        (k, v) => MapEntry(k, v == true),
      ),
      allTrades: (json['allTrades'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(Trade.fromJson)
          .toList(),
      lock: json['lock'] == true,
      lockUntil: json['lockUntil'] as int?,
      preloaded: json['preloaded'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'startDate': startDate,
      'priorPnl': priorPnl,
      'checks': checks,
      'allTrades': allTrades.map((e) => e.toJson()).toList(),
      'lock': lock,
      'lockUntil': lockUntil,
      'preloaded': preloaded,
    };
  }

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
