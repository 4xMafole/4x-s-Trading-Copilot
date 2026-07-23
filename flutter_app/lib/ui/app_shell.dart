import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase/auth_service.dart';
import 'auth_screen.dart';
import 'onboarding_screen.dart';
import 'trading_screen.dart';

/// Root router: decides whether to show Auth, Onboarding, or the main app.
///
/// Onboarding state uses a two-layer check:
///  1. Local SharedPreferences flag (fast, works offline) — primary source
///  2. Supabase profile.onboarding_completed — synced on first load
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _onboardingKey = 'locotrader_onboarding_done_v1';

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
      // Clear local flag so the next user goes through onboarding
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingKey);
      if (mounted) setState(() {});
    }
  }

  Future<void> _checkOnboarding() async {
    // 1. Check local flag first (fast, offline-safe)
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_onboardingKey) == true) {
      _onboardingDone = true;
      return;
    }

    // 2. Try to verify against Supabase (may fail if offline/JWT expired)
    try {
      await AuthService.instance.refreshSession();
      final profile = await AuthService.instance.getProfile();
      final cloudDone = profile?['onboarding_completed'] == true;
      if (cloudDone) {
        _onboardingDone = true;
        // Cache locally so we don't need to hit Supabase next time
        await prefs.setBool(_onboardingKey, true);
      }
    } catch (_) {
      // Network/auth error — do NOT reset to false if already done locally.
      // _onboardingDone remains false only if local flag was also false (new user).
    }
  }

  /// Called by OnboardingScreen when the user completes setup.
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    if (mounted) setState(() => _onboardingDone = true);
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
      return OnboardingScreen(onComplete: _completeOnboarding);
    }

    return const TradingScreen();
  }
}
