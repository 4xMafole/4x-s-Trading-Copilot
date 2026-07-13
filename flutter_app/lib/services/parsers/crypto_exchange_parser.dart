import 'dart:io';

/// Binance / Bybit trade history CSV parser.
///
/// Binance export columns vary but typically:
/// Date(UTC), Pair, Side, Price, Executed, Amount, Fee
///
/// Bybit export:
/// Symbol, Side, Qty, Price, Fee, PNL, Create Time, Close Time
class CryptoExchangeParser {
  CryptoExchangeParser._();

  static bool looksLikeBinance(String csv) {
    final lower = csv.toLowerCase();
    return (lower.contains('date(utc)') || lower.contains('date (utc)')) &&
        (lower.contains('pair') || lower.contains('symbol')) &&
        lower.contains('side');
  }

  static bool looksLikeBybit(String csv) {
    final lower = csv.toLowerCase();
    return lower.contains('symbol') &&
        lower.contains('side') &&
        lower.contains('pnl') &&
        (lower.contains('create time') || lower.contains('entry time'));
  }

  /// Detect and parse any supported crypto exchange format.
  static List<Map<String, dynamic>> parseString(String csv) {
    if (looksLikeBybit(csv)) return _parseBybit(csv);
    if (looksLikeBinance(csv)) return _parseBinance(csv);
    return [];
  }

  static Future<List<Map<String, dynamic>>> parseCsv(File file) async {
    return parseString(await file.readAsString());
  }

  // ── Binance ──
  static List<Map<String, dynamic>> _parseBinance(String csv) {
    final lines = csv.split(RegExp(r'\r?\n'));
    if (lines.length < 2) return [];

    int headerIdx = -1;
    for (int i = 0; i < lines.length && i < 10; i++) {
      if (lines[i].toLowerCase().contains('date') &&
          lines[i].toLowerCase().contains('side')) {
        headerIdx = i;
        break;
      }
    }
    if (headerIdx < 0) return [];

    final headers = _splitLine(
      lines[headerIdx],
    ).map((h) => h.trim().toLowerCase()).toList();

    final dateIdx = _findCol(headers, [
      'date(utc)',
      'date (utc)',
      'time',
      'date',
    ]);
    final pairIdx = _findCol(headers, ['pair', 'symbol', 'market']);
    final sideIdx = headers.indexOf('side');
    final priceIdx = headers.indexOf('price');
    final qtyIdx = _findCol(headers, ['executed', 'qty', 'quantity', 'amount']);
    final feeIdx = headers.indexOf('fee');
    final pnlIdx = _findCol(headers, ['realized profit', 'pnl', 'profit']);

    final trades = <Map<String, dynamic>>[];
    int counter = 0;

    for (int i = headerIdx + 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final cols = _splitLine(line);
      if (cols.length < 4) continue;

      final side = _safeCol(cols, sideIdx).toLowerCase();
      if (side != 'buy' && side != 'sell') continue;

      final dateStr = _safeCol(cols, dateIdx);
      final dt = DateTime.tryParse(dateStr.replaceFirst(' ', 'T'));
      counter++;

      trades.add({
        'ticket_id': 'binance_$counter',
        'instrument_id': _safeCol(
          cols,
          pairIdx,
        ).toUpperCase().replaceAll(' ', ''),
        'direction': side,
        'lots': _toDouble(_safeCol(cols, qtyIdx)),
        'open_price': _toDoubleOrNull(_safeCol(cols, priceIdx)),
        'close_price': _toDoubleOrNull(_safeCol(cols, priceIdx)),
        'commission': _toDoubleOrNull(_safeCol(cols, feeIdx)),
        'pnl': _toDouble(_safeCol(cols, pnlIdx)),
        'close_date': dt != null ? _fmtDate(dt) : _fmtDate(DateTime.now()),
        'close_time': dt != null ? _fmtTime(dt) : null,
      });
    }
    return trades;
  }

  // ── Bybit ──
  static List<Map<String, dynamic>> _parseBybit(String csv) {
    final lines = csv.split(RegExp(r'\r?\n'));
    if (lines.length < 2) return [];

    int headerIdx = -1;
    for (int i = 0; i < lines.length && i < 10; i++) {
      if (lines[i].toLowerCase().contains('symbol') &&
          lines[i].toLowerCase().contains('pnl')) {
        headerIdx = i;
        break;
      }
    }
    if (headerIdx < 0) return [];

    final headers = _splitLine(
      lines[headerIdx],
    ).map((h) => h.trim().toLowerCase()).toList();

    final symIdx = headers.indexOf('symbol');
    final sideIdx = headers.indexOf('side');
    final qtyIdx = _findCol(headers, ['qty', 'quantity', 'size']);
    final priceIdx = _findCol(headers, ['entry price', 'price', 'avg price']);
    final closePriceIdx = _findCol(headers, ['exit price', 'close price']);
    final pnlIdx = headers.indexOf('pnl');
    final feeIdx = headers.indexOf('fee');
    final openTimeIdx = _findCol(headers, [
      'create time',
      'entry time',
      'open time',
    ]);
    final closeTimeIdx = _findCol(headers, ['close time', 'exit time']);

    final trades = <Map<String, dynamic>>[];
    int counter = 0;

    for (int i = headerIdx + 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final cols = _splitLine(line);
      if (cols.length < 4) continue;

      final side = _safeCol(cols, sideIdx).toLowerCase();
      if (side != 'buy' && side != 'sell') continue;
      counter++;

      final openStr = _safeCol(cols, openTimeIdx);
      final closeStr = _safeCol(cols, closeTimeIdx);
      final openDt = DateTime.tryParse(openStr.replaceFirst(' ', 'T'));
      final closeDt = DateTime.tryParse(closeStr.replaceFirst(' ', 'T'));

      trades.add({
        'ticket_id': 'bybit_$counter',
        'instrument_id': _safeCol(cols, symIdx).toUpperCase(),
        'direction': side,
        'lots': _toDouble(_safeCol(cols, qtyIdx)),
        'open_price': _toDoubleOrNull(_safeCol(cols, priceIdx)),
        'close_price': _toDoubleOrNull(_safeCol(cols, closePriceIdx)),
        'commission': _toDoubleOrNull(_safeCol(cols, feeIdx)),
        'pnl': _toDouble(_safeCol(cols, pnlIdx)),
        'open_date': openDt != null ? _fmtDate(openDt) : null,
        'open_time': openDt != null ? _fmtTime(openDt) : null,
        'close_date': closeDt != null
            ? _fmtDate(closeDt)
            : _fmtDate(DateTime.now()),
        'close_time': closeDt != null ? _fmtTime(closeDt) : null,
      });
    }
    return trades;
  }

  // ── Shared Helpers ──
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
