import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'data/trading_repository.dart';
import 'logic/cubits/settings_cubit.dart';
import 'logic/cubits/settings_state.dart';
import 'logic/cubits/trading_core_cubit.dart';
import 'logic/cubits/ai_coach_cubit.dart';
import 'ui/app_theme.dart';
import 'ui/trading_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

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
      child: const CopilotApp(),
    ),
  );
}

class CopilotApp extends StatelessWidget {
  const CopilotApp({super.key});

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
          title: '4x Trades',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          themeAnimationDuration: Duration.zero,
          home: const _AppLockGate(),
        );
      },
    );
  }
}

class _AppLockGate extends StatefulWidget {
  const _AppLockGate();

  @override
  State<_AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<_AppLockGate>
    with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _isAuthenticating = false;
  bool _lastBiometricEnabled = false;
  bool _lockOnNextResume = false;
  String? _authMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final settings = context.read<SettingsCubit>();
    _lastBiometricEnabled = settings.state.biometricLockEnabled;
    _isLocked = _lastBiometricEnabled;
    if (_lastBiometricEnabled) {
      unawaited(_authenticate());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_lastBiometricEnabled) return;

    if (state == AppLifecycleState.paused && !_isAuthenticating) {
      _lockOnNextResume = true;
      return;
    }

    if (state == AppLifecycleState.resumed && _lockOnNextResume) {
      _lockOnNextResume = false;
      setState(() => _isLocked = true);
      unawaited(_authenticate());
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating || !_lastBiometricEnabled || !mounted) return;
    setState(() {
      _isAuthenticating = true;
      _authMessage = null;
    });

    final ok = await context.read<SettingsCubit>().authenticateBiometric();
    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
      _isLocked = !ok;
      if (!ok) _authMessage = 'Authentication required to continue.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (prev, current) =>
          prev.biometricLockEnabled != current.biometricLockEnabled,
      listener: (context, state) {
        final enabled = state.biometricLockEnabled;
        _lastBiometricEnabled = enabled;
        if (!enabled) {
          _lockOnNextResume = false;
          setState(() {
            _isLocked = false;
            _authMessage = null;
          });
        } else {
          setState(() {
            _isLocked = true;
            _authMessage = null;
          });
          _lockOnNextResume = false;
          unawaited(_authenticate());
        }
      },
      child: _isLocked ? _buildLockScreen() : const TradingScreen(),
    );
  }

  Widget _buildLockScreen() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 44,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 14),
                Text(
                  '4x Trades Locked',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _authMessage ?? 'Use Face ID or fingerprint to unlock.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _isAuthenticating
                      ? null
                      : () => unawaited(_authenticate()),
                  icon: _isAuthenticating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.fingerprint),
                  label: Text(
                    _isAuthenticating
                        ? 'Authenticating...'
                        : 'Unlock with biometrics',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
