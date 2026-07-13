import 'dart:io';

/// cTrader CSV parser (History export format).
///
/// cTrader exports columns:
/// Position ID, Symbol, Direction, Volume, Open Time, Open Price, Close Time,
/// Close Price, Commission, Swap, Net Profit, Pips
class CTraderParser {
  CTraderParser._();

  /// Heuristic detection.
  static bool looksLikeCTrader(String csv) {
    final lower = csv.toLowerCase();
    return lower.contains('position id') &&
        (lower.contains('net profit') || lower.contains('netprofit')) &&
        lower.contains('symbol');
  }

  static List<Map<String, dynamic>> parseString(String csv) {
    final lines = csv.split(RegExp(r'\r?\n'));
    if (lines.length < 2) return [];

    int headerIdx = -1;
    for (int i = 0; i < lines.length && i < 10; i++) {
      if (lines[i].toLowerCase().contains('position id')) {
        headerIdx = i;
        break;
      }
    }
    if (headerIdx < 0) return [];

    final headers = _splitLine(
      lines[headerIdx],
    ).map((h) => h.trim().toLowerCase()).toList();

    final posIdx = _findCol(headers, ['position id', 'positionid', 'deal id']);
    final symIdx = headers.indexOf('symbol');
    final dirIdx = _findCol(headers, ['direction', 'type', 'side']);
    final volIdx = _findCol(headers, ['volume', 'lots', 'quantity']);
    final openTimeIdx = _findCol(headers, [
      'open time',
      'opentime',
      'entry time',
    ]);
    final openPriceIdx = _findCol(headers, [
      'open price',
      'openprice',
      'entry price',
    ]);
    final closeTimeIdx = _findCol(headers, [
      'close time',
      'closetime',
      'exit time',
    ]);
    final closePriceIdx = _findCol(headers, [
      'close price',
      'closeprice',
      'exit price',
    ]);
    final commIdx = _findCol(headers, ['commission', 'comm']);
    final swapIdx = headers.indexOf('swap');
    final profitIdx = _findCol(headers, ['net profit', 'netprofit', 'profit']);
    final slIdx = _findCol(headers, ['stop loss', 'sl']);
    final tpIdx = _findCol(headers, ['take profit', 'tp']);

    final trades = <Map<String, dynamic>>[];

    for (int i = headerIdx + 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final cols = _splitLine(line);
      if (cols.length < 5) continue;

      final posId = _safeCol(cols, posIdx);
      if (posId.isEmpty) continue;

      final dir = _safeCol(cols, dirIdx).toLowerCase();
      if (dir != 'buy' && dir != 'sell') continue;

      final openTimeStr = _safeCol(cols, openTimeIdx);
      final closeTimeStr = _safeCol(cols, closeTimeIdx);
      final openDt = DateTime.tryParse(openTimeStr.replaceFirst(' ', 'T'));
      final closeDt = DateTime.tryParse(closeTimeStr.replaceFirst(' ', 'T'));

      // cTrader volume is in units (100000 = 1 lot); convert
      var volume = _toDouble(_safeCol(cols, volIdx));
      if (volume > 100) volume = volume / 100000;

      trades.add({
        'ticket_id': 'ct_$posId',
        'instrument_id': _safeCol(
          cols,
          symIdx,
        ).toUpperCase().replaceAll(' ', ''),
        'direction': dir,
        'lots': volume,
        'open_price': _toDoubleOrNull(_safeCol(cols, openPriceIdx)),
        'close_price': _toDoubleOrNull(_safeCol(cols, closePriceIdx)),
        'stop_loss': _toDoubleOrNull(_safeCol(cols, slIdx)),
        'take_profit': _toDoubleOrNull(_safeCol(cols, tpIdx)),
        'commission': _toDoubleOrNull(_safeCol(cols, commIdx)),
        'swap': _toDoubleOrNull(_safeCol(cols, swapIdx)),
        'pnl': _toDouble(_safeCol(cols, profitIdx)),
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

  static Future<List<Map<String, dynamic>>> parseCsv(File file) async {
    return parseString(await file.readAsString());
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
      } else if ((ch == ',' || ch == ';' || ch == '\t') && !inQ) {
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
      double.tryParse(s.replaceAll(' ', '')) ?? 0;
  static double? _toDoubleOrNull(String s) {
    final v = double.tryParse(s.replaceAll(' ', ''));
    return (v == null || v == 0) ? null : v;
  }

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
