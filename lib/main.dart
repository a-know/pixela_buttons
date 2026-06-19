import 'dart:async';

import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app.dart';
import 'core/notifications/reminder_notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(const PixelaButtonsApp());
  unawaited(_initializeNotifications());
}

Future<void> _initializeNotifications() async {
  try {
    await ReminderNotificationService.instance.initialize();
  } catch (error, stackTrace) {
    debugPrint('Failed to initialize notifications: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
