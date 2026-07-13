import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages subscription state and paywall enforcement.
///
/// Uses RevenueCat (purchases_flutter) for cross-platform IAP and
/// Supabase profiles.tier for server-side enforcement.
class SubscriptionService {
  SubscriptionService._();
  static final instance = SubscriptionService._();

  SupabaseClient get _client => Supabase.instance.client;

  // ── Tier query ───────────────────────────────────────────────────────

  /// Returns current user's subscription tier from Supabase.
  Future<String> getCurrentTier() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return 'free';
    final row = await _client
        .from('profiles')
        .select('tier, subscription_expires_at')
        .eq('id', uid)
        .maybeSingle();
    if (row == null) return 'free';

    final tier = row['tier'] as String? ?? 'free';
    final expiresAt = row['subscription_expires_at'] as String?;

    // If expired, downgrade
    if (tier == 'pro' && expiresAt != null) {
      final expiry = DateTime.tryParse(expiresAt);
      if (expiry != null && expiry.isBefore(DateTime.now().toUtc())) {
        await _client.from('profiles').update({'tier': 'free'}).eq('id', uid);
        return 'free';
      }
    }
    return tier;
  }

  /// Whether the current user has Pro access.
  Future<bool> isPro() async {
    return (await getCurrentTier()) == 'pro';
  }

  // ── Feature gates ────────────────────────────────────────────────────

  /// Returns true if the user can import CSV (Pro only).
  Future<bool> canImportCsv() => isPro();

  /// Returns true if the user can access Edge Map analytics (Pro only).
  Future<bool> canAccessEdgeMap() => isPro();

  /// Returns true if the user can export PDF tear sheets (Pro only).
  Future<bool> canExportPdf() => isPro();

  /// Returns true if the user can use cloud sync (Pro only).
  Future<bool> canCloudSync() => isPro();

  /// Returns the trade limit for the current tier.
  Future<int> tradeLimit() async {
    final tier = await getCurrentTier();
    return tier == 'pro' ? -1 : 30; // -1 = unlimited
  }

  // ── Subscription management ──────────────────────────────────────────

  /// Upgrade user to Pro. Called after successful Stripe/IAP payment.
  /// In production, this should be done server-side via webhook.
  Future<void> upgradeToPro({required DateTime expiresAt}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    await _client
        .from('profiles')
        .update({
          'tier': 'pro',
          'subscription_expires_at': expiresAt.toUtc().toIso8601String(),
        })
        .eq('id', uid);
  }

  /// Downgrade to free. Called on subscription cancellation.
  Future<void> downgradeToFree() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    await _client
        .from('profiles')
        .update({'tier': 'free', 'subscription_expires_at': null})
        .eq('id', uid);
  }

  // ── Trade count check ────────────────────────────────────────────────

  /// Returns how many trades the user has stored.
  Future<int> getTradeCount() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return 0;
    final result = await _client.from('trades').select('id').eq('user_id', uid);
    return (result as List).length;
  }

  /// Whether the user has hit their trade limit.
  Future<bool> hasHitTradeLimit() async {
    final limit = await tradeLimit();
    if (limit < 0) return false; // unlimited
    final count = await getTradeCount();
    return count >= limit;
  }
}
