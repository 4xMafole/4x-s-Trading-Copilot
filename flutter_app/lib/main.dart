import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/trading_repository.dart';
import 'logic/cubits/settings_cubit.dart';
import 'logic/cubits/settings_state.dart';
import 'logic/cubits/trading_core_cubit.dart';
import 'logic/cubits/ai_coach_cubit.dart';
import 'ui/app_shell.dart';
import 'ui/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  final repository = TradingRepository();
  await repository.init();

  final tradingCubit = TradingCoreCubit(repository);
  final aiCoachCubit = AiCoachCubit();
  final settingsCubit = SettingsCubit(repository);
  await settingsCubit.init();
  await tradingCubit.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<TradingCoreCubit>.value(value: tradingCubit),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
        BlocProvider<AiCoachCubit>.value(value: aiCoachCubit),
      ],
      child: const LocoTraderApp(),
    ),
  );
}

class LocoTraderApp extends StatelessWidget {
  const LocoTraderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        if (settings.isLoading) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LocoTrader',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          themeAnimationDuration: Duration.zero,
          home: const AppShell(),
        );
      },
    );
  }
}
