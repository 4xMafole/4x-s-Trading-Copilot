import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trading_copilot_flutter/main.dart';
import 'package:trading_copilot_flutter/logic/trading_controller.dart';

void main() {
  testWidgets('renders trading copilot shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = TradingController();
    await controller.init();

    await tester.pumpWidget(CopilotApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('4x Trading Copilot'), findsOneWidget);
    expect(find.text('Readiness Score'), findsOneWidget);

    controller.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
