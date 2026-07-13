import 'dart:io';

/// MT4 CSV parser (Statement format).
///
/// MT4 exports have columns:
/// Ticket, Open Time, Type, Size, Item, Price, S/L, T/P, Close Time, Price, Commission, Taxes, Swap, Profit
class MT4Parser {
  MT4Parser._();

  /// Quick heuristic: does this CSV look like an MT4 statement?
  static bool looksLikeMT4(String csv) {
    final lower = csv.toLowerCase();
    return lower.contains('ticket') &&
        lower.contains('open time') &&
        lower.contains('close time') &&
        lower.contains('profit');
  }

  /// Parse an MT4 CSV string into a list of trade maps.
  static List<Map<String, dynamic>> parseString(String csv) {
    final lines = csv.split(RegExp(r'\r?\n'));
    if (lines.length < 2) return [];

    // Find the header row
    int headerIdx = -1;
    for (int i = 0; i < lines.length && i < 10; i++) {
      if (lines[i].toLowerCase().contains('ticket') &&
          lines[i].toLowerCase().contains('profit')) {
        headerIdx = i;
        break;
      }
    }
    if (headerIdx < 0) return [];

    final headers = _splitCsvLine(
      lines[headerIdx],
    ).map((h) => h.trim().toLowerCase()).toList();

    final ticketIdx = headers.indexOf('ticket');
    final openTimeIdx = _findCol(headers, ['open time', 'open date']);
    final typeIdx = _findCol(headers, ['type', 'cmd']);
    final sizeIdx = _findCol(headers, ['size', 'volume', 'lots']);
    final itemIdx = _findCol(headers, ['item', 'symbol']);
    final openPriceIdx = headers.indexOf('price');
    final slIdx = _findCol(headers, ['s / l', 's/l', 'sl']);
    final tpIdx = _findCol(headers, ['t / p', 't/p', 'tp']);
    final closeTimeIdx = _findCol(headers, ['close time', 'close date']);
    final closePriceIdx = openPriceIdx >= 0
        ? headers.indexOf('price', openPriceIdx + 1)
        : -1;
    final commIdx = _findCol(headers, ['commission', 'comm']);
    final swapIdx = headers.indexOf('swap');
    final profitIdx = headers.indexOf('profit');

    final trades = <Map<String, dynamic>>[];

    for (int i = headerIdx + 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final cols = _splitCsvLine(line);
      if (cols.length < 5) continue;

      // Skip balance/deposit/withdrawal rows
      final type = _safeCol(cols, typeIdx).toLowerCase();
      if (type.contains('balance') ||
          type.contains('deposit') ||
          type.contains('withdraw') ||
          type.contains('credit'))
        continue;
      if (type != 'buy' && type != 'sell') continue;

      final ticket = _safeCol(cols, ticketIdx);
      if (ticket.isEmpty) continue;

      final openTimeStr = _safeCol(cols, openTimeIdx);
      final closeTimeStr = _safeCol(cols, closeTimeIdx);
      final openDt = _parseDateTime(openTimeStr);
      final closeDt = _parseDateTime(closeTimeStr);

      trades.add({
        'ticket_id': 'mt4_$ticket',
        'instrument_id': _safeCol(
          cols,
          itemIdx,
        ).toUpperCase().replaceAll(' ', ''),
        'direction': type,
        'lots': _toDouble(_safeCol(cols, sizeIdx)),
        'open_price': _toDouble(_safeCol(cols, openPriceIdx)),
        'close_price': _toDouble(_safeCol(cols, closePriceIdx)),
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
    final content = await file.readAsString();
    return parseString(content);
  }

  // ── Helpers ──

  static int _findCol(List<String> headers, List<String> candidates) {
    for (final c in candidates) {
      final idx = headers.indexOf(c);
      if (idx >= 0) return idx;
    }
    return -1;
  }

  static String _safeCol(List<String> cols, int idx) {
    if (idx < 0 || idx >= cols.length) return '';
    return cols[idx].trim();
  }

  static List<String> _splitCsvLine(String line) {
    // Handle quoted fields
    final result = <String>[];
    bool inQuotes = false;
    final buf = StringBuffer();
    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
      } else if ((ch == ',' || ch == '\t' || ch == ';') && !inQuotes) {
        result.add(buf.toString());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    result.add(buf.toString());
    return result;
  }

  static DateTime? _parseDateTime(String s) {
    if (s.isEmpty) return null;
    // MT4 format: yyyy.MM.dd HH:mm:ss or yyyy.MM.dd HH:mm
    final clean = s.replaceAll('.', '-');
    return DateTime.tryParse(clean.replaceFirst(' ', 'T'));
  }

  static double _toDouble(String s) =>
      double.tryParse(s.replaceAll(' ', '')) ?? 0;
  static double? _toDoubleOrNull(String s) {
    final v = double.tryParse(s.replaceAll(' ', ''));
    return (v == null || v == 0) ? null : v;
  }

  static String _fmtDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  static String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
