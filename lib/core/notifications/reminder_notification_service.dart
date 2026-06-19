import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder.dart';

class ReminderNotificationService {
  ReminderNotificationService._();

  static final instance = ReminderNotificationService._();

  static const _channelId = 'record_reminders';
  static const _notificationIdOffset = 1000;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize() async {
    if (_initialized || !_isSupported) return;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings: settings);
    await _setLocalTimezone();
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (!_isSupported) return false;
    await initialize();

    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          true;
    }

    return await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true) ??
        false;
  }

  Future<void> reschedule(
    List<Reminder> reminders, {
    required String title,
    required String body,
  }) async {
    if (!_isSupported) return;
    await initialize();

    final pending = await _plugin.pendingNotificationRequests();
    for (final notification in pending) {
      if (notification.id >= _notificationIdOffset) {
        await _plugin.cancel(id: notification.id);
      }
    }

    for (final reminder in reminders) {
      if (!reminder.enabled) continue;

      await _plugin.zonedSchedule(
        id: _notificationId(reminder.id),
        title: title,
        body: body,
        scheduledDate: _nextOccurrence(reminder.hour, reminder.minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Record reminders',
            channelDescription:
                'Daily reminders to record your Pixela activity',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'record-reminder',
      );
    }
  }

  int _notificationId(int reminderId) => _notificationIdOffset + reminderId;

  tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> _setLocalTimezone() async {
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }
}
