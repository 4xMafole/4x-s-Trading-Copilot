import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trading_copilot_flutter/data/models.dart';
import 'package:trading_copilot_flutter/main.dart';
import 'package:trading_copilot_flutter/logic/trading_controller.dart';

void main() {
  testWidgets('renders trading copilot shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'walkthrough_v2': true});
    final controller = TradingController();
    await controller.init();

    await tester.pumpWidget(CopilotApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('4x Trades'), findsOneWidget);
    expect(find.text('Readiness Score'), findsOneWidget);

    controller.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('settings import uses preview before import',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'walkthrough_v2': true});
    final controller = TradingController();
    await controller.init();

    await tester.pumpWidget(CopilotApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune_outlined));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Import JSON/CSV'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Import JSON/CSV'));
    await tester.pumpAndSettle();

    const payload =
        '{"allTrades":[{"id":"w1","date":"2026-04-28","time":"12:00 EAT","sym":"XAUUSD","dir":"buy","lots":0.1,"pnl":12,"note":"widget","violations":[]}]}';

    final importField = find.byWidgetPredicate(
      (w) => w is TextField && w.maxLines == 12,
    );
    expect(importField, findsOneWidget);
    await tester.enterText(importField, payload);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    expect(find.text('Preview ready'), findsOneWidget);
    expect(find.textContaining('JSON preview ready'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Import'));
    await tester.pumpAndSettle();

    expect(find.text('Import Report'), findsOneWidget);
    expect(controller.state.allTrades.length, 1);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    controller.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('journal delete supports undo', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'walkthrough_v2': true});
    final controller = TradingController();
    await controller.init();

    await controller.restoreTrade(
      Trade(
        id: 'undo-widget-1',
        date: '2026-04-28',
        time: '12:00 EAT',
        sym: 'XAUUSD',
        dir: 'buy',
        lots: 0.2,
        pnl: 15,
        note: 'undo',
        violations: const <String>[],
      ),
    );

    await tester.pumpWidget(CopilotApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_note_outlined));
    await tester.pumpAndSettle();

    expect(find.text('XAUUSD BUY'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();
    expect(find.text('Delete trade?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Undo'), findsOneWidget);
    expect(controller.state.allTrades, isEmpty);

    await tester.ensureVisible(find.widgetWithText(TextButton, 'Undo'));
    await tester.tap(find.widgetWithText(TextButton, 'Undo'));
    await tester.pumpAndSettle();

    expect(find.text('XAUUSD BUY'), findsOneWidget);
    expect(controller.state.allTrades.length, 1);

    controller.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
