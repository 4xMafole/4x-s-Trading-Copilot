import 'dart:io';
import 'package:csv/csv.dart';
import '../data/models.dart';

class MT5Parser {
  /// Reads an MT5 CSV file and returns a list of Trade objects.
  static Future<List<Trade>> parseCsv(File file) async {
    final csvString = await file.readAsString();

    // MT5 CSVs usually use tabs or commas depending on the locale and export format
    // MT5 "Report -> Open in Excel" creates an HTML or a pseudo-CSV/TSV.
    List<List<dynamic>> rows = const CsvToListConverter(
      fieldDelimiter: ',', // Try comma first
      eol: '\n',
    ).convert(csvString);

    if (rows.length <= 1 || rows[0].length < 5) {
      // Fallback to Tab separation if comma parsing failed
      rows = const CsvToListConverter(
        fieldDelimiter: '\t',
        eol: '\n',
      ).convert(csvString);
    }

    if (rows.isEmpty) return [];

    List<Trade> importedTrades = [];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      // A standard MT5 CSV export generally looks like:
      // Time, Position, Symbol, Type, Volume, Price, S/L, T/P, Time, Price, Swap, Profit
      // This parsing assumes that structure, adjust indexes if needed based on the exact CSV format.

      try {
        if (row.length < 11) continue;

        final symbol = row[2].toString().trim();
        final typeStr = row[3].toString().trim().toLowerCase();

        // Skip things that are not buy/sell trades (like deposit/withdrawal if they leak into history)
        if (!typeStr.contains('buy') && !typeStr.contains('sell')) continue;

        final profitStr = row.last.toString().replaceAll(
          RegExp(r'[^0-9\.\-]'),
          '',
        ); // Profit is often the last column
        final profit = double.tryParse(profitStr) ?? 0.0;

        final openTimeStr = row[0].toString().trim(); // 'yyyy.MM.dd HH:mm:ss'

        DateTime openTime;
        try {
          openTime = DateTime.parse(openTimeStr.replaceAll('.', '-'));
        } catch (_) {
          openTime = DateTime.now(); // Fallback if time parsing fails
        }

        final date =
            "\${openTime.year.toString().padLeft(4, '0')}-\${openTime.month.toString().padLeft(2, '0')}-\${openTime.day.toString().padLeft(2, '0')}";
        final time =
            "\${openTime.hour.toString().padLeft(2, '0')}:\${openTime.minute.toString().padLeft(2, '0')}";

        final volumeStr = row[4].toString().trim();
        final lots = double.tryParse(volumeStr) ?? 0.0;

        final positionId = row[1].toString().trim();

        // Create the Trade object matching our models.dart
        final trade = Trade(
          id: 'mt5_\$positionId\_\${DateTime.now().millisecondsSinceEpoch}',
          sym: symbol.toUpperCase(),
          dir: typeStr.contains('buy') ? 'buy' : 'sell',
          lots: lots,
          pnl: profit,
          date: date,
          time: time,
          isHypothetical: false,
          note: 'Imported from MT5',
        );

        importedTrades.add(trade);
      } catch (e) {
        continue;
      }
    }

    return importedTrades;
  }
}
