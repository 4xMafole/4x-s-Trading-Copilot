import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/models.dart';

/// Sprint 3.2 — Weekly AI Digest service.
///
/// Computes deterministic weekly stats from local trade data, then asks
/// Gemini's free tier to phrase them as a 3-bullet digest. If the network
/// or API is unavailable, falls back to a hardcoded but still useful
/// English summary so the user always gets a digest.
class WeeklyDigestService {
  WeeklyDigestService({FlutterLocalNotificationsPlugin? notifications})
    : _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  static const int _digestNotificationId = 4200;
  static const String _channelId = 'weekly_digest_v1';
  static const String _channelName = 'Weekly digest';
  static const String _channelDescription =
      'Sunday 6 PM (EAT) summary of your trading week';

  final FlutterLocalNotificationsPlugin _notifications;

  /// Schedules a recurring Sunday 18:00 (Africa/Nairobi) reminder.
  /// Notification text is generic — the rich digest opens inside the app.
  Future<bool> scheduleSundayReminder() async {
    final granted = await _requestPermissions();
    if (!granted) return false;

    final location = _eatLocation();
    final now = tz.TZDateTime.now(location);
    var next = tz.TZDateTime(location, now.year, now.month, now.day, 18);
    // Find next Sunday at 18:00 EAT.
    while (next.weekday != DateTime.sunday || !next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.zonedSchedule(
      _digestNotificationId,
      'Your week in trades is ready',
      'Tap to see your win, worst habit, and one fix for next week.',
      next,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
    return true;
  }

  Future<void> cancelReminder() => _notifications.cancel(_digestNotificationId);

  Future<bool> _requestPermissions() async {
    var granted = true;
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidGranted = await android?.requestNotificationsPermission();
    if (androidGranted != null) granted = granted && androidGranted;

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (iosGranted != null) granted = granted && iosGranted;
    return granted;
  }

  tz.Location _eatLocation() {
    try {
      return tz.getLocation('Africa/Nairobi');
    } catch (_) {
      return tz.local;
    }
  }

  /// Builds the digest for the most recently completed week (Mon..Sun) in EAT.
  /// Tries Gemini first; falls back to deterministic phrasing on any error.
  /// When [localOnly] is true (Sprint 5.3), Gemini is skipped entirely.
  Future<WeeklyDigest> buildDigestForLastWeek(
    List<Trade> allTrades, {
    bool localOnly = false,
  }) async {
    final stats = _WeeklyStats.compute(allTrades);

    String win = stats.deterministicWin();
    String worstHabit = stats.deterministicWorstHabit();
    String oneFix = stats.deterministicOneFix();

    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (!localOnly && apiKey.isNotEmpty && stats.tradesThisWeek > 0) {
      try {
        final phrased = await _phraseWithGemini(stats);
        if (phrased != null) {
          win = phrased.win;
          worstHabit = phrased.worstHabit;
          oneFix = phrased.oneFix;
        }
      } catch (e) {
        debugPrint('Weekly digest: Gemini call failed, using fallback: $e');
      }
    }

    return WeeklyDigest(
      weekId: stats.weekId,
      generatedAt: DateTime.now().millisecondsSinceEpoch,
      win: win,
      worstHabit: worstHabit,
      oneFix: oneFix,
    );
  }

  Future<_PhrasedDigest?> _phraseWithGemini(_WeeklyStats stats) async {
    final model = GenerativeModel(
      model: 'gemini-3.1-flash-lite-preview',
      apiKey: dotenv.env['GEMINI_API_KEY']!,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.4,
      ),
    );

    final prompt =
        '''
You are a ruthless prop-trading coach writing a Sunday-evening digest.
Write exactly three short, punchy lines using only the data below. No fluff.

Data:
${stats.toPromptJson()}

Return STRICT JSON:
{
  "win": "string — one concrete WIN from the week",
  "worst_habit": "string — one concrete WORST habit / leak",
  "one_fix": "string — one specific actionable fix for next week"
}
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final raw = (response.text ?? '').trim();
    if (raw.isEmpty) return null;
    final cleaned = raw.replaceAll('```json', '').replaceAll('```', '').trim();
    final map = jsonDecode(cleaned) as Map<String, dynamic>;
    return _PhrasedDigest(
      win: (map['win'] ?? '').toString(),
      worstHabit: (map['worst_habit'] ?? '').toString(),
      oneFix: (map['one_fix'] ?? '').toString(),
    );
  }
}

class _PhrasedDigest {
  _PhrasedDigest({
    required this.win,
    required this.worstHabit,
    required this.oneFix,
  });
  final String win;
  final String worstHabit;
  final String oneFix;
}

/// Pure deterministic stats. No I/O, no API. Used both as the prompt
/// payload for Gemini and as the offline fallback.
class _WeeklyStats {
  _WeeklyStats({
    required this.weekId,
    required this.weekStart,
    required this.weekEnd,
    required this.tradesThisWeek,
    required this.totalPnl,
    required this.aPlusPnl,
    required this.bcPnl,
    required this.fomoCount,
    required this.fomoPnl,
    required this.totalCount,
    required this.worstDayLabel,
    required this.worstDayPnl,
    required this.consecutiveLossMaxDrawdown,
  });

  final String weekId;
  final String weekStart;
  final String weekEnd;
  final int tradesThisWeek;
  final double totalPnl;
  final double aPlusPnl;
  final double bcPnl;
  final int fomoCount;
  final double fomoPnl;
  final int totalCount;
  final String worstDayLabel;
  final double worstDayPnl;
  final double consecutiveLossMaxDrawdown;

  static _WeeklyStats compute(List<Trade> all) {
    // Use Africa/Nairobi local time anchor — fall back to system local.
    tz.Location loc;
    try {
      loc = tz.getLocation('Africa/Nairobi');
    } catch (_) {
      loc = tz.local;
    }
    final now = tz.TZDateTime.now(loc);
    // End of last week = the most recent past Sunday 23:59. Start = Mon 00:00.
    final daysSinceMon = (now.weekday - DateTime.monday) % 7;
    final thisMon = tz.TZDateTime(
      loc,
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: daysSinceMon));
    final lastMon = thisMon.subtract(const Duration(days: 7));
    final lastSun = thisMon.subtract(const Duration(days: 1));

    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final startStr = fmt(lastMon);
    final endStr = fmt(lastSun);

    final trades = all
        .where(
          (t) =>
              !t.isHypothetical &&
              t.date.compareTo(startStr) >= 0 &&
              t.date.compareTo(endStr) <= 0,
        )
        .toList();

    double total = 0;
    double aPlus = 0;
    double bc = 0;
    int fomo = 0;
    double fomoPnl = 0;
    final byDay = <String, double>{};
    for (final t in trades) {
      total += t.pnl;
      if (t.setupQuality == 'A+') aPlus += t.pnl;
      if (t.setupQuality == 'B' || t.setupQuality == 'C') bc += t.pnl;
      if (t.trigger != null && t.trigger != 'Plan') {
        fomo++;
        fomoPnl += t.pnl;
      }
      byDay[t.date] = (byDay[t.date] ?? 0) + t.pnl;
    }

    String worstDay = '';
    double worstDayPnl = 0;
    byDay.forEach((day, pnl) {
      if (pnl < worstDayPnl) {
        worstDay = day;
        worstDayPnl = pnl;
      }
    });

    // Largest 2-loss-in-a-row drawdown (rolling pair sum of losses).
    double maxPair = 0;
    final losses = trades.where((t) => t.pnl < 0).toList();
    for (var i = 0; i + 1 < losses.length; i++) {
      final pair = losses[i].pnl + losses[i + 1].pnl;
      if (pair < maxPair) maxPair = pair;
    }

    // ISO-ish week id: YYYY-Www
    final isoWeek = _isoWeekNumber(lastMon);
    final weekId = '${lastMon.year}-W${isoWeek.toString().padLeft(2, '0')}';

    return _WeeklyStats(
      weekId: weekId,
      weekStart: startStr,
      weekEnd: endStr,
      tradesThisWeek: trades.length,
      totalPnl: total,
      aPlusPnl: aPlus,
      bcPnl: bc,
      fomoCount: fomo,
      fomoPnl: fomoPnl,
      totalCount: trades.length,
      worstDayLabel: worstDay,
      worstDayPnl: worstDayPnl,
      consecutiveLossMaxDrawdown: maxPair,
    );
  }

  static int _isoWeekNumber(DateTime d) {
    final thursday = d.add(Duration(days: 3 - ((d.weekday + 6) % 7)));
    final firstThu = DateTime(thursday.year, 1, 4);
    final week = ((thursday.difference(firstThu).inDays) / 7).floor() + 1;
    return week;
  }

  String toPromptJson() => jsonEncode({
    'weekStart': weekStart,
    'weekEnd': weekEnd,
    'totalTrades': totalCount,
    'totalPnl': totalPnl.toStringAsFixed(2),
    'aPlusPnl': aPlusPnl.toStringAsFixed(2),
    'bcPnl': bcPnl.toStringAsFixed(2),
    'impulseTriggerCount': fomoCount,
    'impulseTriggerPnl': fomoPnl.toStringAsFixed(2),
    'worstDay': worstDayLabel,
    'worstDayPnl': worstDayPnl.toStringAsFixed(2),
    'consecutiveLossMaxDrawdown': consecutiveLossMaxDrawdown.toStringAsFixed(2),
  });

  String deterministicWin() {
    if (tradesThisWeek == 0) return 'No trades logged this week — clean slate.';
    if (aPlusPnl > 0) {
      return 'A+ setups produced +${aPlusPnl.toStringAsFixed(0)} USD.';
    }
    if (totalPnl > 0) {
      return 'Net positive week: +${totalPnl.toStringAsFixed(0)} USD over $tradesThisWeek trades.';
    }
    return 'You showed up. ${tradesThisWeek} trades logged with full structure.';
  }

  String deterministicWorstHabit() {
    if (tradesThisWeek == 0) return '—';
    if (fomoCount > 0 && fomoCount * 2 >= totalCount) {
      final pct = (fomoCount * 100 / totalCount).round();
      return '$pct% of trades were impulse-triggered (non-Plan).${worstDayLabel.isNotEmpty ? " Worst day: $worstDayLabel." : ""}';
    }
    if (bcPnl < 0) {
      return 'B/C-grade setups bled ${bcPnl.toStringAsFixed(0)} USD.';
    }
    if (worstDayLabel.isNotEmpty && worstDayPnl < 0) {
      return 'Worst day $worstDayLabel: ${worstDayPnl.toStringAsFixed(0)} USD.';
    }
    return 'No clear leak this week — keep tagging trades.';
  }

  String deterministicOneFix() {
    if (tradesThisWeek == 0) {
      return 'Pre-mark levels for next week before London open.';
    }
    if (consecutiveLossMaxDrawdown < -50) {
      return 'Skip the next trade after 2 consecutive losses. Would have saved ${consecutiveLossMaxDrawdown.abs().toStringAsFixed(0)} USD this week.';
    }
    if (fomoCount > 0) {
      return 'Reject any setup not pre-tagged "Plan" before entry.';
    }
    if (bcPnl < 0) return 'Take A+ setups only next week.';
    return 'Stay structured — keep logging Setup Quality + Trigger every trade.';
  }
}
