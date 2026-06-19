import 'package:flutter/material.dart';
import 'package:pixela_buttons/l10n/app_localizations.dart';

import '../../core/models/reminder.dart';
import '../../core/notifications/reminder_notification_service.dart';
import '../../core/storage/reminder_storage.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  static const _maximumReminderCount = 5;

  List<Reminder> _reminders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final reminders = await ReminderStorage.load();
    if (mounted) {
      setState(() {
        _reminders = reminders;
        _loading = false;
      });
    }
  }

  Future<void> _addReminder() async {
    final l10n = AppLocalizations.of(context)!;
    if (_reminders.length >= _maximumReminderCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.reminderLimitReached(_maximumReminderCount)),
        ),
      );
      return;
    }

    final time = await _show24HourTimePicker(
      const TimeOfDay(hour: 20, minute: 0),
    );
    if (time == null || !mounted) return;

    if (_containsTime(time)) {
      _showDuplicateMessage();
      return;
    }

    final permissionGranted = await ReminderNotificationService.instance
        .requestPermission();
    final reminder = Reminder(
      id: ReminderStorage.nextId(_reminders),
      hour: time.hour,
      minute: time.minute,
    );
    await _save([..._reminders, reminder]);

    if (!permissionGranted && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.reminderPermissionDenied)));
    }
  }

  Future<void> _editReminder(Reminder reminder) async {
    final time = await _show24HourTimePicker(
      TimeOfDay(hour: reminder.hour, minute: reminder.minute),
    );
    if (time == null || !mounted) return;
    if (_containsTime(time, exceptId: reminder.id)) {
      _showDuplicateMessage();
      return;
    }

    await _save(
      _reminders
          .map(
            (item) => item.id == reminder.id
                ? item.copyWith(hour: time.hour, minute: time.minute)
                : item,
          )
          .toList(),
    );
  }

  Future<void> _toggleReminder(Reminder reminder, bool enabled) async {
    if (enabled) {
      final granted = await ReminderNotificationService.instance
          .requestPermission();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.reminderPermissionDenied,
            ),
          ),
        );
      }
    }
    await _save(
      _reminders
          .map(
            (item) =>
                item.id == reminder.id ? item.copyWith(enabled: enabled) : item,
          )
          .toList(),
    );
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    await _save(_reminders.where((item) => item.id != reminder.id).toList());
  }

  Future<void> _save(List<Reminder> reminders) async {
    reminders.sort((a, b) {
      final hour = a.hour.compareTo(b.hour);
      return hour != 0 ? hour : a.minute.compareTo(b.minute);
    });
    await ReminderStorage.save(reminders);
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    await ReminderNotificationService.instance.reschedule(
      reminders,
      title: l10n.reminderNotificationTitle,
      body: l10n.reminderNotificationBody,
    );
    if (mounted) setState(() => _reminders = reminders);
  }

  bool _containsTime(TimeOfDay time, {int? exceptId}) => _reminders.any(
    (reminder) =>
        reminder.id != exceptId &&
        reminder.hour == time.hour &&
        reminder.minute == time.minute,
  );

  void _showDuplicateMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.reminderDuplicateTime),
      ),
    );
  }

  Future<TimeOfDay?> _show24HourTimePicker(TimeOfDay initialTime) =>
      showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
      );

  String _formatTime(Reminder reminder) =>
      '${reminder.hour.toString().padLeft(2, '0')}:'
      '${reminder.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.screenReminders)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _reminders.length < _maximumReminderCount
            ? _addReminder
            : null,
        icon: const Icon(Icons.add),
        label: Text(l10n.buttonAddReminder),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.emptyRemindersMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 96),
              itemCount: _reminders.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text(
                    _formatTime(reminder),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  onTap: () => _editReminder(reminder),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: reminder.enabled,
                        onChanged: (enabled) =>
                            _toggleReminder(reminder, enabled),
                      ),
                      IconButton(
                        tooltip: l10n.buttonDelete,
                        onPressed: () => _deleteReminder(reminder),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
