import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase/auth_service.dart';
import 'auth_screen.dart';
import 'onboarding_screen.dart';
import 'trading_screen.dart';

/// Root router: decides whether to show Auth, Onboarding, or the main app
/// based on Supabase session and profile.onboarding_completed.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final StreamSubscription<AuthState> _authSub;
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _onboardingDone = false;

  @override
  void initState() {
    super.initState();
    _authSub = AuthService.instance.authStateChanges.listen(_onAuthChange);
    _checkInitialState();
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  Future<void> _checkInitialState() async {
    final session = AuthService.instance.session;
    if (session != null) {
      _isAuthenticated = true;
      await _checkOnboarding();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _onAuthChange(AuthState state) async {
    final event = state.event;
    if (event == AuthChangeEvent.signedIn) {
      _isAuthenticated = true;
      await _checkOnboarding();
      if (mounted) setState(() {});
    } else if (event == AuthChangeEvent.signedOut) {
      _isAuthenticated = false;
      _onboardingDone = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _checkOnboarding() async {
    try {
      final profile = await AuthService.instance.getProfile();
      _onboardingDone = profile?['onboarding_completed'] == true;
    } catch (_) {
      // Table may not exist yet (migrations not applied) — treat as not onboarded
      _onboardingDone = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isAuthenticated) {
      return const AuthScreen();
    }

    if (!_onboardingDone) {
      return OnboardingScreen(
        onComplete: () => setState(() => _onboardingDone = true),
      );
    }

    return const TradingScreen();
  }
}
