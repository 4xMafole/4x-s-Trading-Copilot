import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trading_copilot_flutter/data/models.dart';
import 'package:trading_copilot_flutter/data/schema_migration.dart';
import 'package:trading_copilot_flutter/logic/trading_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults use current schema version', () {
    final controller = TradingController();
    expect(controller.state.schemaVersion, kCurrentSchemaVersion);
  });

  test('legacy JSON preview does not mutate state and import migrates payload',
      () async {
    final controller = TradingController();
    final payload = {
      'balance': 25500,
      'startDate': '2026-04-20',
      'priorPnl': 50,
      'trades': [
        {
          'id': '',
          'date': '2026-04-25',
          'time': '10:15',
          'sym': 'XAUUSD',
          'dir': 'BUY',
          'lots': 0.2,
          'pnl': 44,
          'note': 'legacy',
          'violations': 'risk|session',
        }
      ],
    };

    final beforeCount = controller.state.allTrades.length;
    final preview = await controller.importJsonData(
      jsonEncode(payload),
      merge: false,
      dryRun: true,
    );

    expect(preview.ok, isTrue);
    expect(preview.dryRun, isTrue);
    expect(preview.importedCount, 1);
    expect(preview.preview, isNotNull);
    expect(controller.state.allTrades.length, beforeCount);

    final applied = await controller.importJsonData(jsonEncode(payload));
    expect(applied.ok, isTrue);
    expect(controller.state.schemaVersion, kCurrentSchemaVersion);
    expect(controller.state.allTrades.length, 1);
    expect(controller.state.allTrades.first.id, isNotEmpty);
    expect(controller.state.allTrades.first.time, '10:15 EAT');
    expect(controller.state.allTrades.first.dir, anyOf('buy', 'BUY'));
  });

  test('CSV dry-run reports duplicates and skipped rows', () async {
    final controller = TradingController();

    await controller.importJsonData(
      jsonEncode({
        'allTrades': [
          {
            'id': 'existing-1',
            'date': '2026-04-25',
            'time': '09:00 EAT',
            'sym': 'XAUUSD',
            'dir': 'buy',
            'lots': 0.1,
            'pnl': 10,
            'note': '',
            'violations': <String>[],
          }
        ]
      }),
      merge: false,
    );

    const csv = '''Date,Time,Instrument,Direction,Lots,P&L,Notes,Violations,id
2026-04-25,10:15 EAT,XAUUSD,buy,0.5,120,ok,stacking,existing-1
2026-04-25,12:00,EURUSD,sell,0.1,-20,note,,new-1
2026-04-25,13:00,EURUSD,sell,abc,40,note,,bad-lots
2026-04-26,14:00,NQ,buy,1,50,note,,new-1
''';

    final preview = await controller.importCsvData(
      csv,
      merge: true,
      dryRun: true,
    );

    expect(preview.ok, isTrue);
    expect(preview.dryRun, isTrue);
    expect(preview.importedCount, 2);
    expect(preview.skippedCount, 2);
    expect(preview.preview, isNotNull);
    expect(preview.preview!.duplicateCount, 1);
    expect(preview.preview!.resultingCount, 2);
    expect(controller.state.allTrades.length, 1);

    final applied = await controller.importCsvData(csv, merge: true);
    expect(applied.ok, isTrue);
    expect(controller.state.allTrades.length, 2);
  });

  test('CSV import rejects invalid date rows', () async {
    final controller = TradingController();
    const csv = '''Date,Time,Instrument,Direction,Lots,P&L
not-a-date,10:00,XAUUSD,buy,0.2,12
''';

    final result = await controller.importCsvData(csv);
    expect(result.ok, isFalse);
    expect(result.skippedCount, 1);
  });

  test('restoreTrade re-inserts deleted trade with original id', () async {
    final controller = TradingController();

    final original = Trade(
      id: 'undo-1',
      date: '2026-04-28',
      time: '12:00 EAT',
      sym: 'XAUUSD',
      dir: 'buy',
      lots: 0.2,
      pnl: 15,
      note: 'undo test',
      violations: const <String>[],
    );

    await controller.restoreTrade(original);
    expect(controller.state.allTrades.length, 1);

    await controller.deleteTrade(original.id);
    expect(controller.state.allTrades, isEmpty);

    await controller.restoreTrade(original);
    expect(controller.state.allTrades.length, 1);
    expect(controller.state.allTrades.first.id, original.id);
    expect(controller.state.allTrades.first.note, original.note);
  });

  test('export includes schemaVersion field', () async {
    final controller = TradingController();
    final exported = controller.exportAsJson();
    final decoded = jsonDecode(exported) as Map<String, dynamic>;

    expect(decoded['schemaVersion'], kCurrentSchemaVersion);
  });
}
