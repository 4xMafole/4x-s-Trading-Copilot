import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages authentication state and operations via Supabase Auth.
///
/// Supports email/password, Google, and Apple sign-in.
class AuthService {
  AuthService._();
  static final instance = AuthService._();

  SupabaseClient get _client => Supabase.instance.client;
  GoTrueClient get _auth => _client.auth;

  /// Current session (null if not logged in).
  Session? get session => _auth.currentSession;

  /// Current user (null if not logged in).
  User? get user => _auth.currentUser;

  /// Whether the user is currently authenticated.
  bool get isAuthenticated => session != null;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // ── Email / Password ─────────────────────────────────────────────────

  /// Sign up with email and password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return _auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'full_name': displayName} : null,
    );
  }

  /// Sign in with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithPassword(email: email, password: password);
  }

  /// Send a password-reset email.
  Future<void> resetPassword(String email) async {
    await _auth.resetPasswordForEmail(email);
  }

  // ── OAuth (Google / Apple) ───────────────────────────────────────────

  /// Sign in with Google OAuth.
  Future<bool> signInWithGoogle() async {
    return _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.locotrader.app://auth-callback',
    );
  }

  /// Sign in with Apple.
  Future<bool> signInWithApple() async {
    return _auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'com.locotrader.app://auth-callback',
    );
  }

  // ── Session management ───────────────────────────────────────────────

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Refresh the current session token.
  Future<AuthResponse> refreshSession() async {
    return _auth.refreshSession();
  }

  /// Delete the user's account and all data (GDPR compliance).
  /// Requires a Supabase Edge Function for admin delete.
  Future<void> deleteAccount() async {
    await _client.functions.invoke('delete-user-account');
  }

  // ── Profile helpers ──────────────────────────────────────────────────

  /// Get the current user's profile from the `profiles` table.
  Future<Map<String, dynamic>?> getProfile() async {
    final uid = user?.id;
    if (uid == null) return null;
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();
    return response;
  }

  /// Update profile fields. Creates the profile row if it doesn't exist.
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final uid = user?.id;
    if (uid == null) return;
    // Refresh session if expired before making API calls
    try {
      await _auth.refreshSession();
    } catch (_) {
      // Non-fatal — proceed with existing session
    }
    final data = {
      'id': uid,
      'email': user?.email ?? '',
      ...updates,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    await _client.from('profiles').upsert(data, onConflict: 'id');
  }
}
