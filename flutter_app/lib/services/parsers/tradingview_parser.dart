import 'dart:io';

/// TradingView strategy report CSV parser.
///
/// TradingView exports have columns:
/// Trade #, Type, Signal, Date/Time, Price, Contracts, Profit, Cumulative Profit, Run-up, Drawdown
class TradingViewParser {
  TradingViewParser._();

  static bool looksLikeTradingView(String csv) {
    final lower = csv.toLowerCase();
    return lower.contains('trade #') &&
        (lower.contains('cumulative profit') || lower.contains('run-up'));
  }

  static List<Map<String, dynamic>> parseString(String csv, {String? symbol}) {
    final lines = csv.split(RegExp(r'\r?\n'));
    if (lines.length < 2) return [];

    int headerIdx = -1;
    for (int i = 0; i < lines.length && i < 10; i++) {
      if (lines[i].toLowerCase().contains('trade #')) {
        headerIdx = i;
        break;
      }
    }
    if (headerIdx < 0) return [];

    final headers = _splitLine(
      lines[headerIdx],
    ).map((h) => h.trim().toLowerCase()).toList();

    final tradeIdx = _findCol(headers, ['trade #', 'trade', '#']);
    final typeIdx = _findCol(headers, ['type', 'side']);
    final signalIdx = headers.indexOf('signal');
    final dateIdx = _findCol(headers, ['date/time', 'datetime', 'date']);
    final priceIdx = headers.indexOf('price');
    final contractsIdx = _findCol(headers, [
      'contracts',
      'qty',
      'quantity',
      'lots',
    ]);
    final profitIdx = _findCol(headers, ['profit', 'p&l', 'pnl']);

    // TradingView pairs entries and exits in consecutive rows
    final rawRows = <List<String>>[];
    for (int i = headerIdx + 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final cols = _splitLine(line);
      if (cols.length < 4) continue;
      rawRows.add(cols);
    }

    // Match Entry → Exit pairs
    final trades = <Map<String, dynamic>>[];
    for (int i = 0; i < rawRows.length - 1; i += 2) {
      final entry = rawRows[i];
      final exit = rawRows[i + 1];

      final signal = _safeCol(entry, signalIdx).toLowerCase();
      final exitSignal = _safeCol(exit, signalIdx).toLowerCase();

      // Determine direction
      String direction;
      if (signal.contains('long') || signal.contains('buy')) {
        direction = 'buy';
      } else if (signal.contains('short') || signal.contains('sell')) {
        direction = 'sell';
      } else {
        direction = 'buy';
      }

      final entryDateStr = _safeCol(entry, dateIdx);
      final exitDateStr = _safeCol(exit, dateIdx);
      final entryDt = _parseTvDate(entryDateStr);
      final exitDt = _parseTvDate(exitDateStr);

      final tradeNum = _safeCol(entry, tradeIdx);
      final lots = _toDouble(_safeCol(entry, contractsIdx));
      final profit = _toDouble(_safeCol(exit, profitIdx));

      trades.add({
        'ticket_id': 'tv_$tradeNum',
        'instrument_id': symbol?.toUpperCase() ?? 'UNKNOWN',
        'direction': direction,
        'lots': lots > 0 ? lots : 1.0,
        'open_price': _toDoubleOrNull(_safeCol(entry, priceIdx)),
        'close_price': _toDoubleOrNull(_safeCol(exit, priceIdx)),
        'pnl': profit,
        'open_date': entryDt != null ? _fmtDate(entryDt) : null,
        'open_time': entryDt != null ? _fmtTime(entryDt) : null,
        'close_date': exitDt != null
            ? _fmtDate(exitDt)
            : _fmtDate(DateTime.now()),
        'close_time': exitDt != null ? _fmtTime(exitDt) : null,
      });
    }
    return trades;
  }

  static Future<List<Map<String, dynamic>>> parseCsv(
    File file, {
    String? symbol,
  }) async {
    return parseString(await file.readAsString(), symbol: symbol);
  }

  static DateTime? _parseTvDate(String s) {
    if (s.isEmpty) return null;
    // TV format: 2024-01-15 09:30 or MM/DD/YYYY HH:mm
    var clean = s.replaceAll('/', '-');
    if (clean.contains(' ')) {
      clean = clean.replaceFirst(' ', 'T');
    }
    return DateTime.tryParse(clean);
  }

  static int _findCol(List<String> h, List<String> c) {
    for (final x in c) {
      final i = h.indexOf(x);
      if (i >= 0) return i;
    }
    return -1;
  }

  static String _safeCol(List<String> c, int i) =>
      (i < 0 || i >= c.length) ? '' : c[i].trim();

  static List<String> _splitLine(String line) {
    final result = <String>[];
    bool inQ = false;
    final buf = StringBuffer();
    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQ = !inQ;
      } else if ((ch == ',' || ch == '\t') && !inQ) {
        result.add(buf.toString());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    result.add(buf.toString());
    return result;
  }

  static double _toDouble(String s) =>
      double.tryParse(s.replaceAll(RegExp(r'[^0-9.\-]'), '')) ?? 0;
  static double? _toDoubleOrNull(String s) {
    final v = double.tryParse(s.replaceAll(RegExp(r'[^0-9.\-]'), ''));
    return (v == null || v == 0) ? null : v;
  }

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
