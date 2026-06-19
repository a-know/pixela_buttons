import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/reminder.dart';

class ReminderStorage {
  static const _remindersKey = 'reminders';

  static Future<List<Reminder>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_remindersKey);
    if (value == null) return [];

    try {
      final items = jsonDecode(value) as List<dynamic>;
      return items
          .map((item) => Reminder.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort(_compareByTime);
    } on FormatException {
      return [];
    }
  }

  static Future<void> save(List<Reminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _remindersKey,
      jsonEncode(reminders.map((reminder) => reminder.toJson()).toList()),
    );
  }

  static int nextId(List<Reminder> reminders) {
    if (reminders.isEmpty) return 1;
    return reminders
            .map((reminder) => reminder.id)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

  static int _compareByTime(Reminder a, Reminder b) {
    final hourComparison = a.hour.compareTo(b.hour);
    return hourComparison != 0 ? hourComparison : a.minute.compareTo(b.minute);
  }
}
