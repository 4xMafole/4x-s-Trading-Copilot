import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Sprint 4.4 — Economic calendar service.
///
/// Pulls the free Forex Factory "this week" JSON feed (hosted by
/// FairEconomy / NFS) and exposes high-impact events for the dashboard
/// banner and the trade-block guard.
///
/// Cost: $0. No API key required. The endpoint is the same one Forex
/// Factory's own widgets use and is permissive for personal use.
class EconomicCalendarService {
  EconomicCalendarService({http.Client? client})
    : _client = client ?? http.Client();

  static const String _url =
      'https://nfs.faireconomy.media/ff_calendar_thisweek.json';

  static const Duration _cacheTtl = Duration(hours: 6);

  final http.Client _client;

  List<EconomicEvent> _cache = const <EconomicEvent>[];
  DateTime? _fetchedAt;
  Future<List<EconomicEvent>>? _inFlight;

  /// Returns this week's high-impact events. Cached for 6 hours.
  Future<List<EconomicEvent>> getHighImpactEvents({bool force = false}) async {
    final now = DateTime.now();
    if (!force &&
        _fetchedAt != null &&
        now.difference(_fetchedAt!) < _cacheTtl &&
        _cache.isNotEmpty) {
      return _cache;
    }
    final inFlight = _inFlight;
    if (inFlight != null) return inFlight;

    final future = _fetch();
    _inFlight = future;
    try {
      final result = await future;
      _cache = result;
      _fetchedAt = DateTime.now();
      return result;
    } finally {
      _inFlight = null;
    }
  }

  Future<List<EconomicEvent>> _fetch() async {
    try {
      final res = await _client
          .get(Uri.parse(_url))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) {
        debugPrint('EconomicCalendar: HTTP ${res.statusCode}');
        return _cache;
      }
      final raw = jsonDecode(res.body);
      if (raw is! List) return _cache;
      final out = <EconomicEvent>[];
      for (final item in raw) {
        if (item is! Map) continue;
        final impact = (item['impact'] ?? '').toString();
        if (impact.toLowerCase() != 'high') continue;
        final dateStr = (item['date'] ?? '').toString();
        final dt = DateTime.tryParse(dateStr);
        if (dt == null) continue;
        out.add(
          EconomicEvent(
            title: (item['title'] ?? '').toString(),
            country: (item['country'] ?? '').toString(),
            impact: impact,
            timeUtc: dt.toUtc(),
          ),
        );
      }
      out.sort((a, b) => a.timeUtc.compareTo(b.timeUtc));
      return out;
    } catch (e) {
      debugPrint('EconomicCalendar fetch failed: $e');
      return _cache;
    }
  }

  /// Returns the next high-impact event whose UTC time is within
  /// [windowMinutes] minutes of [now]. Returns null if none.
  static EconomicEvent? imminentEvent(
    List<EconomicEvent> events,
    DateTime now, {
    int windowMinutes = 60,
  }) {
    final nowUtc = now.toUtc();
    for (final e in events) {
      final diff = e.timeUtc.difference(nowUtc).inMinutes;
      if (diff >= -windowMinutes && diff <= windowMinutes) return e;
    }
    return null;
  }

  /// True when [now] is within ±[blockMinutes] of any high-impact event.
  /// Used to gate the log-trade button when the user opts in.
  static bool isInBlackout(
    List<EconomicEvent> events,
    DateTime now, {
    int blockMinutes = 15,
  }) {
    return imminentEvent(events, now, windowMinutes: blockMinutes) != null;
  }
}

class EconomicEvent {
  const EconomicEvent({
    required this.title,
    required this.country,
    required this.impact,
    required this.timeUtc,
  });

  final String title;
  final String country;
  final String impact; // High | Medium | Low
  final DateTime timeUtc;

  /// Minutes until the event from `now`. Negative if already happened.
  int minutesFrom(DateTime now) => timeUtc.difference(now.toUtc()).inMinutes;
}
