import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class SessionAlertSchedule {
  const SessionAlertSchedule({
    required this.eventKey,
    required this.hour,
    required this.minute,
    required this.title,
    required this.body,
  });

  final String eventKey;
  final int hour;
  final int minute;
  final String title;
  final String body;
}

class SessionAlertService {
  SessionAlertService({FlutterLocalNotificationsPlugin? notifications})
      : _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  static const String _channelId = 'session_alerts_v1';
  static const String _channelName = 'Session Alerts';
  static const String _channelDescription =
      'Daily trading session timing reminders';

  final FlutterLocalNotificationsPlugin _notifications;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    final eatLocation = _eatLocation();
    tz.setLocalLocation(eatLocation);

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(settings);
    _initialized = true;
  }

  Future<bool> enableSessionAlerts(List<SessionAlertSchedule> schedules) async {
    await initialize();

    final granted = await _requestPermissions();
    if (!granted) return false;

    for (final key in _knownEventKeys) {
      await _notifications.cancel(_notificationIdFor(key));
    }

    for (final schedule in schedules) {
      await _scheduleDaily(
        id: _notificationIdFor(schedule.eventKey),
        hour: schedule.hour,
        minute: schedule.minute,
        title: schedule.title,
        body: schedule.body,
      );
    }

    return true;
  }

  Future<void> disableSessionAlerts() async {
    await initialize();
    for (final key in _knownEventKeys) {
      await _notifications.cancel(_notificationIdFor(key));
    }
  }

  Future<bool> _requestPermissions() async {
    var granted = true;

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.requestNotificationsPermission();
    if (androidGranted != null) {
      granted = granted && androidGranted;
    }

    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted =
        await ios?.requestPermissions(alert: true, badge: true, sound: true);
    if (iosGranted != null) {
      granted = granted && iosGranted;
    }

    return granted;
  }

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final location = _eatLocation();
    final scheduled = _nextOccurrence(location, hour, minute);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.Location _eatLocation() {
    try {
      return tz.getLocation('Africa/Nairobi');
    } catch (_) {
      return tz.local;
    }
  }

  tz.TZDateTime _nextOccurrence(tz.Location location, int hour, int minute) {
    final now = tz.TZDateTime.now(location);
    var next =
        tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);

    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }

    return next;
  }

  int _notificationIdFor(String eventKey) {
    switch (eventKey) {
      case 'mid_london':
        return 4100;
      case 'late_london':
        return 4101;
      case 'blackout':
        return 4102;
      case 'ny_open':
        return 4103;
      default:
        return 4199;
    }
  }

  List<String> get _knownEventKeys => const [
        'mid_london',
        'late_london',
        'blackout',
        'ny_open',
      ];
}
