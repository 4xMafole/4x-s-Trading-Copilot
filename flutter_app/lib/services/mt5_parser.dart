import 'dart:io';
import 'package:csv/csv.dart';
import '../data/models.dart';

/// Parser for MT5 / cTrader / generic broker CSV history exports.
///
/// Supports the canonical MT5 ReportHistory.csv layout:
///
///   Time,Position,Symbol,Type,Volume,Price,S / L,T / P,Time,Price,Commission,Swap,Profit
///    0     1       2     3     4      5     6     7    8     9      10        11    12
///
/// Where columns 0/5 are the OPEN time/price and columns 8/9 are the CLOSE
/// time/price. The trade's `date`/`time` are stored as the CLOSE timestamp
/// (used for daily grouping) and the open timestamp is preserved on
/// `openDate`/`openTime`/`openPrice`.
class MT5Parser {
  /// Returns true when [headerRow] looks like an MT5 history export.
  static bool isMT5Header(List<dynamic> headerRow) {
    final lower = headerRow
        .map((c) => c.toString().toLowerCase().trim())
        .toList();
    final joined = lower.join(',');
    return joined.contains('position') &&
        joined.contains('symbol') &&
        joined.contains('volume') &&
        (joined.contains('s / l') ||
            joined.contains('s/l') ||
            joined.contains('sl')) &&
        joined.contains('profit');
  }

  /// Detect MT5 format directly from a CSV string (header line).
  static bool looksLikeMT5(String csvString) {
    final firstLine = csvString
        .split(RegExp(r'\r?\n'))
        .firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
    final cells = firstLine.split(RegExp(r'[,\t]'));
    return isMT5Header(cells);
  }

  /// Reads an MT5 CSV file and returns a list of [Trade] objects.
  static Future<List<Trade>> parseCsv(File file) async {
    final csvString = await file.readAsString();
    return parseString(csvString);
  }

  /// Parses an MT5 CSV string and returns a list of [Trade] objects.
  static List<Trade> parseString(String csvString) {
    // Try comma first; fall back to tab if it produced too few columns.
    List<List<dynamic>> rows = const CsvToListConverter(
      fieldDelimiter: ',',
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(csvString);

    if (rows.length <= 1 || rows[0].length < 8) {
      rows = const CsvToListConverter(
        fieldDelimiter: '\t',
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(csvString);
    }

    if (rows.isEmpty) return const [];

    final out = <Trade>[];
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      try {
        if (row.length < 11) continue;

        final symbol = row[2].toString().trim();
        if (symbol.isEmpty) continue;

        final typeStr = row[3].toString().trim().toLowerCase();
        if (!typeStr.contains('buy') && !typeStr.contains('sell')) continue;

        final positionId = row[1].toString().trim();
        final lots = _toDouble(row[4]);
        final openPrice = _toDouble(row[5]);
        final stopLoss = _toDoubleOrNull(row[6]);
        final takeProfit = _toDoubleOrNull(row[7]);

        // Open time = column 0, close time = column 8 when present.
        final openTs = _parseMt5DateTime(row[0]);
        final closeTs = row.length > 8
            ? _parseMt5DateTime(row[8]) ?? openTs
            : openTs;

        // Standard 13-col layout: close price=9, commission=10, swap=11, profit=12.
        // Older 12-col layout (no commission): close price=9, swap=10, profit=11.
        double? closePrice;
        double commission = 0.0;
        double swap = 0.0;
        double profit = 0.0;

        if (row.length >= 13) {
          closePrice = _toDoubleOrNull(row[9]);
          commission = _toDouble(row[10]);
          swap = _toDouble(row[11]);
          profit = _toDouble(row[12]);
        } else if (row.length == 12) {
          closePrice = _toDoubleOrNull(row[9]);
          swap = _toDouble(row[10]);
          profit = _toDouble(row[11]);
        } else {
          profit = _toDouble(row.last);
          if (row.length > 9) closePrice = _toDoubleOrNull(row[9]);
        }

        final closeDt = closeTs ?? DateTime.now();
        final openDt = openTs ?? closeDt;

        out.add(
          Trade(
            id: 'mt5_${positionId}_${nowMs}_$i',
            ticketId: positionId.isEmpty ? null : positionId,
            sym: symbol.toUpperCase(),
            dir: typeStr.contains('buy') ? 'buy' : 'sell',
            lots: lots,
            pnl: profit,
            date: _fmtDate(closeDt),
            time: _fmtTime(closeDt),
            openDate: _fmtDate(openDt),
            openTime: _fmtTime(openDt),
            openPrice: openPrice == 0 ? null : openPrice,
            closePrice: closePrice,
            stopLoss: stopLoss,
            takeProfit: takeProfit,
            commission: commission == 0 ? null : commission,
            swap: swap == 0 ? null : swap,
            isHypothetical: false,
            note: 'Imported from MT5',
            tags: const ['imported', 'mt5'],
          ),
        );
      } catch (_) {
        continue;
      }
    }

    return out;
  }

  // ── helpers ───────────────────────────────────────────────────────────

  static DateTime? _parseMt5DateTime(dynamic raw) {
    final s = raw?.toString().trim() ?? '';
    if (s.isEmpty) return null;
    // MT5 uses 'yyyy.MM.dd HH:mm:ss'. Replace dots with dashes for ISO.
    final iso = s.replaceAll('.', '-');
    return DateTime.tryParse(iso);
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    final s = v.toString().replaceAll(RegExp(r'[^0-9.\-]'), '').trim();
    if (s.isEmpty || s == '-' || s == '.') return 0.0;
    return double.tryParse(s) ?? 0.0;
  }

  static double? _toDoubleOrNull(dynamic v) {
    if (v == null) return null;
    final raw = v.toString().trim();
    if (raw.isEmpty) return null;
    final s = raw.replaceAll(RegExp(r'[^0-9.\-]'), '').trim();
    if (s.isEmpty || s == '-' || s == '.') return null;
    return double.tryParse(s);
  }

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
}
