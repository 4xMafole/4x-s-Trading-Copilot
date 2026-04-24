import 'package:flutter/material.dart';

import 'logic/trading_controller.dart';
import 'ui/app_theme.dart';
import 'ui/trading_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = TradingController();
  await controller.init();
  runApp(CopilotApp(controller: controller));
}

class CopilotApp extends StatelessWidget {
  const CopilotApp({super.key, required this.controller});

  final TradingController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '4x Trading Copilot',
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: TradingScreen(controller: controller),
    );
  }
}
