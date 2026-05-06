import '../data/models.dart';

/// Holds a single trade candidate parsed from OCR text. Lossy by nature —
/// users review and confirm before these become real trades in Hive.
class TradeCandidate {
  TradeCandidate({
    required this.sym,
    required this.dir,
    required this.lots,
    required this.pnl,
    required this.rawSource,
    this.date,
    this.time,
  });

  String sym;
  String dir; // 'buy' | 'sell'
  double lots;
  double pnl;
  String? date; // yyyy-MM-dd
  String? time; // HH:mm
  final String rawSource;

  /// True when we have at least the bare minimum to call this a trade:
  /// a recognised symbol, a direction, and a non-zero P/L.
  bool get isValid =>
      sym.isNotEmpty && (dir == 'buy' || dir == 'sell') && pnl != 0.0;
}

/// Universal trade parser. Takes OCR-extracted text lines from a broker
/// screenshot (MT5, MT4, cTrader, TradeLocker, etc.) and reconstructs a list
/// of [TradeCandidate]s using line-by-line heuristics.
///
/// The strategy is intentionally simple and broker-agnostic:
///   1. Walk the lines top-to-bottom.
///   2. For each line containing both a symbol and a direction keyword,
///      open a new candidate and harvest lots / P/L from the same line and
///      the next 1–2 lines (most platforms wrap a trade across rows).
///   3. Skip headers, totals, and rows that look like deposits/withdrawals.
class TradeExtractor {
  /// Common forex / metal / index / crypto tickers seen in retail screenshots.
  /// Anything else is still detected by the generic 5–7 char A-Z pattern.
  static const List<String> _knownSymbols = [
    'XAUUSD',
    'XAGUSD',
    'XBRUSD',
    'XTIUSD',
    'EURUSD',
    'GBPUSD',
    'USDJPY',
    'USDCHF',
    'USDCAD',
    'AUDUSD',
    'NZDUSD',
    'EURGBP',
    'EURJPY',
    'GBPJPY',
    'AUDJPY',
    'EURAUD',
    'EURCAD',
    'GBPAUD',
    'NQ100',
    'US100',
    'US30',
    'SPX500',
    'NAS100',
    'DJ30',
    'GER40',
    'UK100',
    'BTCUSD',
    'ETHUSD',
    'XRPUSD',
    'SOLUSD',
  ];

  /// Match a 5–7 char ticker (letters and optional digits) — picks up almost
  /// every modern broker symbol naming pattern.
  static final RegExp _symRegex = RegExp(r'\b[A-Z]{3}[A-Z0-9]{2,4}\b');

  /// Match a money value like  -$120.50  +$45  120.5  -120,50
  static final RegExp _moneyRegex = RegExp(
    r'([+\-−–]?)\s*\$?\s*(\d{1,3}(?:[,\.\s]\d{3})*(?:[\.,]\d{1,2})?)',
  );

  /// Match a typical lot size (0.01 – 99.99). Restrict to two decimals so we
  /// don't accidentally pick up prices like "1.08423".
  static final RegExp _lotsRegex = RegExp(r'\b(\d{1,3}\.\d{2})\b');

  /// Match a yyyy.MM.dd / yyyy-MM-dd / dd.MM.yyyy date.
  static final RegExp _dateRegex = RegExp(
    r'(\d{4})[.\-/](\d{2})[.\-/](\d{2})|(\d{2})[.\-/](\d{2})[.\-/](\d{4})',
  );

  /// Match HH:mm[:ss] times.
  static final RegExp _timeRegex = RegExp(r'\b(\d{2}):(\d{2})(?::\d{2})?\b');

  /// Words that mean "skip this row" — totals, headers, ledger entries.
  static const List<String> _skipKeywords = [
    'balance',
    'deposit',
    'withdrawal',
    'credit',
    'commission only',
    'total',
    'profit:',
    'subtotal',
    'summary',
    'symbol',
    'ticket',
  ];

  /// Run the full parse. Returns a list of validated [TradeCandidate]s.
  static List<TradeCandidate> parseLines(List<String> lines) {
    final results = <TradeCandidate>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();

      if (_skipKeywords.any(lower.contains)) continue;

      final dir = _detectDirection(lower);
      if (dir == null) continue;

      final sym = _detectSymbol(line);
      if (sym == null) continue;

      // Combine the current line with the next two as a search window —
      // many platforms split open / close rows across consecutive lines.
      final window = [
        line,
        if (i + 1 < lines.length) lines[i + 1],
        if (i + 2 < lines.length) lines[i + 2],
      ].join(' ');

      final lots = _detectLots(window);
      final pnl = _detectPnl(window);
      final dateTime = _detectDateTime(window);

      final candidate = TradeCandidate(
        sym: sym,
        dir: dir,
        lots: lots,
        pnl: pnl,
        date: dateTime?.$1,
        time: dateTime?.$2,
        rawSource: line,
      );

      if (candidate.isValid) results.add(candidate);
    }

    return _dedupe(results);
  }

  /// Convert candidates into real [Trade] objects ready for the cubit.
  static List<Trade> toTrades(
    List<TradeCandidate> candidates, {
    required String fallbackDate,
    required String fallbackTime,
    String? noteOverride,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return [
      for (var i = 0; i < candidates.length; i++)
        Trade(
          id: 'ocr_${now}_$i',
          date: candidates[i].date ?? fallbackDate,
          time: candidates[i].time ?? fallbackTime,
          sym: candidates[i].sym,
          dir: candidates[i].dir,
          lots: candidates[i].lots,
          pnl: candidates[i].pnl,
          note: noteOverride ?? 'Imported from screenshot',
          tags: const ['imported'],
        ),
    ];
  }

  // ── Internal heuristics ────────────────────────────────────────────────

  static String? _detectDirection(String lowerLine) {
    if (lowerLine.contains('buy')) return 'buy';
    if (lowerLine.contains('sell')) return 'sell';
    if (lowerLine.contains('long')) return 'buy';
    if (lowerLine.contains('short')) return 'sell';
    return null;
  }

  static String? _detectSymbol(String line) {
    // First try known symbols (case-insensitive).
    final upper = line.toUpperCase();
    for (final s in _knownSymbols) {
      if (upper.contains(s)) return s;
    }
    // Fall back to the generic ticker pattern.
    final match = _symRegex.firstMatch(upper);
    return match?.group(0);
  }

  static double _detectLots(String window) {
    final matches = _lotsRegex.allMatches(window).toList();
    for (final m in matches) {
      final v = double.tryParse(m.group(1) ?? '');
      // Lots are almost always between 0.01 and 50 in retail.
      if (v != null && v >= 0.01 && v <= 50) return v;
    }
    return 0.0;
  }

  static double _detectPnl(String window) {
    // Prefer the LAST money value on the row — most platforms put profit
    // at the far right of the row.
    final matches = _moneyRegex.allMatches(window).toList();
    if (matches.isEmpty) return 0.0;

    for (final m in matches.reversed) {
      final signRaw = (m.group(1) ?? '')
          .replaceAll('−', '-')
          .replaceAll('–', '-');
      final numRaw = (m.group(2) ?? '')
          .replaceAll(',', '.')
          .replaceAll(' ', '');

      // Drop trailing-decimal commas like 120,50 → 120.50, but if there are
      // multiple dots after our normalize, take the last 2 as decimals.
      final cleaned = _normalizeNumber(numRaw);
      final v = double.tryParse(cleaned);
      if (v == null) continue;

      // Skip values that look like a price (3+ digits before decimal AND not
      // signed). 1.08432 isn't a P/L; -45.32 obviously is.
      if (signRaw.isEmpty && v > 5000) continue;

      final signed = signRaw == '-' ? -v : v;
      // Demand non-zero — a line of zeros is almost always a header.
      if (signed != 0) return signed;
    }
    return 0.0;
  }

  static String _normalizeNumber(String raw) {
    // Strip thousands separators if both . and , present.
    if (raw.contains('.') && raw.contains(',')) {
      // Whichever appears last is the decimal separator.
      if (raw.lastIndexOf('.') > raw.lastIndexOf(',')) {
        return raw.replaceAll(',', '');
      } else {
        return raw.replaceAll('.', '').replaceFirst(',', '.');
      }
    }
    return raw;
  }

  static (String, String)? _detectDateTime(String window) {
    final dMatch = _dateRegex.firstMatch(window);
    final tMatch = _timeRegex.firstMatch(window);
    if (dMatch == null && tMatch == null) return null;

    String? date;
    if (dMatch != null) {
      // yyyy-mm-dd OR dd-mm-yyyy
      if (dMatch.group(1) != null) {
        date = '${dMatch.group(1)}-${dMatch.group(2)}-${dMatch.group(3)}';
      } else {
        date = '${dMatch.group(6)}-${dMatch.group(5)}-${dMatch.group(4)}';
      }
    }

    final time = tMatch != null
        ? '${tMatch.group(1)}:${tMatch.group(2)}'
        : '00:00';

    return (date ?? '', time);
  }

  /// Collapse near-duplicate candidates that come from the same row spanning
  /// multiple OCR lines.
  static List<TradeCandidate> _dedupe(List<TradeCandidate> items) {
    final seen = <String>{};
    final out = <TradeCandidate>[];
    for (final c in items) {
      final key = '${c.sym}|${c.dir}|${c.pnl.toStringAsFixed(2)}|${c.lots}';
      if (seen.add(key)) out.add(c);
    }
    return out;
  }
}
