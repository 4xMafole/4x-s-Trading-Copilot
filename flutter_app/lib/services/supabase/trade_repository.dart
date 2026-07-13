import 'package:supabase_flutter/supabase_flutter.dart';

/// CRUD operations for trades against Supabase Postgres.
/// Replaces the Hive-based local persistence for cloud-first architecture.
class TradeRepository {
  TradeRepository._();
  static final instance = TradeRepository._();

  SupabaseClient get _client => Supabase.instance.client;
  String? get _uid => _client.auth.currentUser?.id;

  // ── Read ─────────────────────────────────────────────────────────────

  /// Fetch all trades for the current user, ordered by close_date desc.
  Future<List<Map<String, dynamic>>> getAllTrades() async {
    if (_uid == null) return [];
    final res = await _client
        .from('trades')
        .select()
        .eq('user_id', _uid!)
        .order('close_date', ascending: false)
        .order('close_time', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Fetch trades for a specific date.
  Future<List<Map<String, dynamic>>> getTradesByDate(String date) async {
    if (_uid == null) return [];
    final res = await _client
        .from('trades')
        .select()
        .eq('user_id', _uid!)
        .eq('close_date', date)
        .order('close_time', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Fetch trades for a specific instrument.
  Future<List<Map<String, dynamic>>> getTradesByInstrument(
    String instrumentId,
  ) async {
    if (_uid == null) return [];
    final res = await _client
        .from('trades')
        .select()
        .eq('user_id', _uid!)
        .eq('instrument_id', instrumentId)
        .order('close_date', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Get trade count.
  Future<int> getTradeCount() async {
    if (_uid == null) return 0;
    final res = await _client.from('trades').select('id').eq('user_id', _uid!);
    return (res as List).length;
  }

  // ── Write ────────────────────────────────────────────────────────────

  /// Insert a new trade.
  Future<Map<String, dynamic>> insertTrade(Map<String, dynamic> trade) async {
    trade['user_id'] = _uid;
    final res = await _client.from('trades').insert(trade).select().single();
    return res;
  }

  /// Insert a batch of trades (e.g. from CSV import).
  Future<List<Map<String, dynamic>>> insertTrades(
    List<Map<String, dynamic>> trades,
  ) async {
    for (final t in trades) {
      t['user_id'] = _uid;
    }
    final res = await _client
        .from('trades')
        .upsert(trades, onConflict: 'user_id,ticket_id', ignoreDuplicates: true)
        .select();
    return List<Map<String, dynamic>>.from(res);
  }

  /// Update an existing trade.
  Future<void> updateTrade(String tradeId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toUtc().toIso8601String();
    await _client.from('trades').update(updates).eq('id', tradeId);
  }

  /// Delete a trade.
  Future<void> deleteTrade(String tradeId) async {
    await _client.from('trades').delete().eq('id', tradeId);
  }

  // ── Gate checks ──────────────────────────────────────────────────────

  /// Get today's gate checks.
  Future<List<Map<String, dynamic>>> getTodayGateChecks() async {
    if (_uid == null) return [];
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final res = await _client
        .from('gate_checks')
        .select()
        .eq('user_id', _uid!)
        .eq('checked_date', today);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Upsert a gate check (toggle pass/fail with proof).
  Future<void> upsertGateCheck({
    required String gateId,
    required bool isPassed,
    String? proof,
  }) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _client.from('gate_checks').upsert({
      'user_id': _uid,
      'gate_id': gateId,
      'checked_date': today,
      'is_passed': isPassed,
      'proof': proof,
    });
  }

  // ── Daily mood ───────────────────────────────────────────────────────

  /// Get today's mood.
  Future<Map<String, dynamic>?> getTodayMood() async {
    if (_uid == null) return null;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return await _client
        .from('daily_moods')
        .select()
        .eq('user_id', _uid!)
        .eq('mood_date', today)
        .maybeSingle();
  }

  /// Set today's mood.
  Future<void> setTodayMood(String mood, {String note = ''}) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _client.from('daily_moods').upsert({
      'user_id': _uid,
      'mood': mood,
      'note': note,
      'mood_date': today,
    });
  }

  // ── Strategy & gates ─────────────────────────────────────────────────

  /// Get user's strategy profiles.
  Future<List<Map<String, dynamic>>> getStrategies() async {
    if (_uid == null) return [];
    final res = await _client
        .from('strategy_profiles')
        .select('*, gates(*)')
        .eq('user_id', _uid!)
        .order('created_at');
    return List<Map<String, dynamic>>.from(res);
  }

  /// Create a strategy profile (optionally from a template).
  Future<Map<String, dynamic>> createStrategy({
    required String name,
    String? templateSource,
  }) async {
    final strategy = await _client
        .from('strategy_profiles')
        .insert({
          'user_id': _uid,
          'name': name,
          'template_source': templateSource,
        })
        .select()
        .single();

    // Clone template gates if specified
    if (templateSource != null) {
      await _client.rpc(
        'clone_gate_template',
        params: {
          'p_user_id': _uid,
          'p_strategy_id': strategy['id'],
          'p_template_name': templateSource,
        },
      );
    }
    return strategy;
  }

  /// Add a custom gate to a strategy.
  Future<void> addGate({
    required String strategyId,
    required String label,
    String? description,
    String gateType = 'manual',
    List<String>? appliesToInstruments,
    int sortOrder = 99,
  }) async {
    await _client.from('gates').insert({
      'strategy_id': strategyId,
      'label': label,
      'description': description,
      'gate_type': gateType,
      'applies_to_instruments': appliesToInstruments,
      'sort_order': sortOrder,
    });
  }

  /// Delete a gate.
  Future<void> deleteGate(String gateId) async {
    await _client.from('gates').delete().eq('id', gateId);
  }

  /// Reorder gates within a strategy.
  Future<void> reorderGates(List<String> gateIds) async {
    for (int i = 0; i < gateIds.length; i++) {
      await _client
          .from('gates')
          .update({'sort_order': i})
          .eq('id', gateIds[i]);
    }
  }

  // ── User instruments (watchlist) ─────────────────────────────────────

  /// Get the user's selected instruments.
  Future<List<Map<String, dynamic>>> getUserInstruments() async {
    if (_uid == null) return [];
    final res = await _client
        .from('user_instruments')
        .select('instrument_id, instruments(*)')
        .eq('user_id', _uid!);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Add instrument to watchlist.
  Future<void> addInstrument(String instrumentId) async {
    await _client.from('user_instruments').upsert({
      'user_id': _uid,
      'instrument_id': instrumentId,
    });
  }

  /// Remove instrument from watchlist.
  Future<void> removeInstrument(String instrumentId) async {
    await _client
        .from('user_instruments')
        .delete()
        .eq('user_id', _uid!)
        .eq('instrument_id', instrumentId);
  }

  // ── Trading sessions ─────────────────────────────────────────────────

  /// Get user's configured trading sessions.
  Future<List<Map<String, dynamic>>> getTradingSessions() async {
    if (_uid == null) return [];
    final res = await _client
        .from('trading_sessions')
        .select()
        .eq('user_id', _uid!)
        .order('start_time');
    return List<Map<String, dynamic>>.from(res);
  }

  /// Create or update a trading session.
  Future<void> upsertSession(Map<String, dynamic> session) async {
    session['user_id'] = _uid;
    await _client.from('trading_sessions').upsert(session);
  }

  // ── Prop firm profiles ───────────────────────────────────────────────

  /// Get user's prop firm profiles.
  Future<List<Map<String, dynamic>>> getPropFirmProfiles() async {
    if (_uid == null) return [];
    final res = await _client
        .from('prop_firm_profiles')
        .select()
        .eq('user_id', _uid!);
    return List<Map<String, dynamic>>.from(res);
  }
}
