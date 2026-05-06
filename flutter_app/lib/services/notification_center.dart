import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Unified local-notification center. Owns all channels, permission
/// handling, and the singleton plugin instance. Every notification the
/// app fires goes through this class so we have one place to audit
/// scope, frequency, and category prefs.
///
/// $0/month — pure on-device notifications via `flutter_local_notifications`.
/// No FCM, no server.
class NotificationCenter {
  NotificationCenter._();
  static final NotificationCenter instance = NotificationCenter._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ── Channel & ID registry ────────────────────────────────────────────
  // IDs are stable so re-firing replaces the previous notification.
  static const int idDrawdown = 5100;
  static const int idRiskBudget = 5200;
  static const int idLock = 5300;
  static const int idStreak = 5400;
  static const int idDailyCap = 5500;
  static const int idNewsImminent = 5600;
  static const int idMoodReminder = 5700;
  static const int idBackupReminder = 5800;

  static const _drawdownChannel = AndroidNotificationChannel(
    'drawdown_v1',
    'Drawdown alerts',
    description: 'Warns when prop-firm daily/total drawdown is at risk.',
    importance: Importance.max,
  );
  static const _riskBudgetChannel = AndroidNotificationChannel(
    'risk_budget_v1',
    'Weekly risk budget',
    description: 'Warns when your weekly R-unit budget is mostly consumed.',
    importance: Importance.high,
  );
  static const _lockChannel = AndroidNotificationChannel(
    'lock_v1',
    'Account lock',
    description: 'Confirms when the app auto-locks after consecutive losses.',
    importance: Importance.max,
  );
  static const _streakChannel = AndroidNotificationChannel(
    'streak_v1',
    'Loss streaks',
    description: 'Pre-trade warning when 3+ recent trades were losers.',
    importance: Importance.high,
  );
  static const _dailyCapChannel = AndroidNotificationChannel(
    'daily_cap_v1',
    'Daily trade cap',
    description: 'Tells you when you have hit your max trades for today.',
    importance: Importance.defaultImportance,
  );
  static const _newsChannel = AndroidNotificationChannel(
    'news_imminent_v1',
    'High-impact news',
    description: 'Heads-up before NFP / CPI / FOMC prints.',
    importance: Importance.max,
  );
  static const _moodChannel = AndroidNotificationChannel(
    'mood_v1',
    'Daily mood check-in',
    description: 'Morning ping to log your pre-trading state.',
    importance: Importance.defaultImportance,
  );
  static const _backupChannel = AndroidNotificationChannel(
    'backup_v1',
    'Backup reminder',
    description: 'Weekly nudge to export an encrypted backup.',
    importance: Importance.low,
  );

  // ── Init / permissions ───────────────────────────────────────────────
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(_eatLocation());
    } catch (_) {
      /* timezone may already be initialised */
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      for (final ch in const [
        _drawdownChannel,
        _riskBudgetChannel,
        _lockChannel,
        _streakChannel,
        _dailyCapChannel,
        _newsChannel,
        _moodChannel,
        _backupChannel,
      ]) {
        await android.createNotificationChannel(ch);
      }
    }
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    await initialize();
    var ok = true;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final aOk = await android?.requestNotificationsPermission();
    if (aOk != null) ok = ok && aOk;

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iOk = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (iOk != null) ok = ok && iOk;
    return ok;
  }

  // ── Show-now helpers (reactive triggers) ─────────────────────────────
  Future<void> _showNow({
    required int id,
    required AndroidNotificationChannel channel,
    required String title,
    required String body,
  }) async {
    try {
      await initialize();
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );
      await _plugin.show(id, title, body, details);
    } catch (e) {
      debugPrint('NotificationCenter.show failed: $e');
    }
  }

  Future<void> showDrawdownAlert(String title, String body) => _showNow(
    id: idDrawdown,
    channel: _drawdownChannel,
    title: title,
    body: body,
  );

  Future<void> showRiskBudgetAlert(String title, String body) => _showNow(
    id: idRiskBudget,
    channel: _riskBudgetChannel,
    title: title,
    body: body,
  );

  Future<void> showLockAlert(String title, String body) =>
      _showNow(id: idLock, channel: _lockChannel, title: title, body: body);

  Future<void> showStreakAlert(String title, String body) =>
      _showNow(id: idStreak, channel: _streakChannel, title: title, body: body);

  Future<void> showDailyCapAlert(String title, String body) => _showNow(
    id: idDailyCap,
    channel: _dailyCapChannel,
    title: title,
    body: body,
  );

  Future<void> showNewsAlert(String title, String body) => _showNow(
    id: idNewsImminent,
    channel: _newsChannel,
    title: title,
    body: body,
  );

  // ── Recurring schedules ──────────────────────────────────────────────
  Future<void> scheduleDailyMoodReminder({
    int hour = 8,
    int minute = 30,
  }) async {
    await initialize();
    final loc = _eatLocation();
    final now = tz.TZDateTime.now(loc);
    var next = tz.TZDateTime(loc, now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _moodChannel.id,
        _moodChannel.name,
        channelDescription: _moodChannel.description,
        importance: _moodChannel.importance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    try {
      await _plugin.zonedSchedule(
        idMoodReminder,
        'Morning check-in',
        'How are you feeling? Log your mood before the session.',
        next,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Mood reminder schedule failed: $e');
    }
  }

  Future<void> cancelMoodReminder() async {
    await initialize();
    await _plugin.cancel(idMoodReminder);
  }

  Future<void> scheduleSundayBackupReminder({
    int hour = 19,
    int minute = 0,
  }) async {
    await initialize();
    final loc = _eatLocation();
    final now = tz.TZDateTime.now(loc);
    var next = tz.TZDateTime(loc, now.year, now.month, now.day, hour, minute);
    while (next.weekday != DateTime.sunday || !next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _backupChannel.id,
        _backupChannel.name,
        channelDescription: _backupChannel.description,
        importance: _backupChannel.importance,
        priority: Priority.low,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    try {
      await _plugin.zonedSchedule(
        idBackupReminder,
        'Backup time',
        'Tap to export an encrypted backup to Drive/iCloud.',
        next,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      debugPrint('Backup reminder schedule failed: $e');
    }
  }

  Future<void> cancelBackupReminder() async {
    await initialize();
    await _plugin.cancel(idBackupReminder);
  }

  Future<void> cancelAllReactive() async {
    await initialize();
    for (final id in const [
      idDrawdown,
      idRiskBudget,
      idLock,
      idStreak,
      idDailyCap,
      idNewsImminent,
    ]) {
      await _plugin.cancel(id);
    }
  }

  tz.Location _eatLocation() {
    try {
      return tz.getLocation('Africa/Nairobi');
    } catch (_) {
      return tz.local;
    }
  }
}
