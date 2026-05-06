import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pixela_buttons/l10n/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../core/api/pixela_client.dart';
import '../../core/models/card_config.dart';
import '../../core/storage/card_storage.dart';

class RecordDialog extends StatefulWidget {
  final CardConfig card;
  final double value;
  final DateTime recordedAt;
  final String? timezone;
  final DateTime? specificDate;

  const RecordDialog({
    super.key,
    required this.card,
    required this.value,
    required this.recordedAt,
    this.timezone,
    this.specificDate,
  });

  static Future<void> show(
      BuildContext context, CardConfig card, double value, DateTime recordedAt, String? timezone,
      {DateTime? specificDate}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RecordDialog(
        card: card,
        value: value,
        recordedAt: recordedAt,
        timezone: timezone,
        specificDate: specificDate,
      ),
    );
  }

  @override
  State<RecordDialog> createState() => _RecordDialogState();
}

class _RecordDialogState extends State<RecordDialog> {
  String? _todayValue;
  bool _todayFailed = false;
  bool _loading = true;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _fetchToday();
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchToday() async {
    try {
      final username = await CardStorage.getUsername() ?? '';
      final double? value;
      if (widget.specificDate != null) {
        final yyyyMMdd = DateFormat('yyyyMMdd').format(widget.specificDate!);
        value = await pixelaClient.getPixelValue(username, widget.card.graphId, yyyyMMdd);
      } else {
        value = await pixelaClient.getTodayValue(username, widget.card.graphId);
      }
      setState(() {
        _todayValue = _formatValue(value ?? 0);
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _todayFailed = true;
        _loading = false;
      });
    }
    _autoCloseTimer = Timer(
      const Duration(seconds: 3),
      () { if (mounted) Navigator.of(context).pop(); },
    );
  }

  String _formatValue(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  String _recordLabel(AppLocalizations l10n) {
    final sign = widget.value >= 0 ? '+' : '';
    return '$sign${_formatValue(widget.value)}${widget.card.unit}';
  }

  DateTime _recordedDate() {
    final tzId = widget.timezone;
    if (tzId != null && tzId.isNotEmpty) {
      try {
        final location = tz.getLocation(tzId);
        return tz.TZDateTime.from(widget.recordedAt, location);
      } catch (_) {}
    }
    return widget.recordedAt;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.dialogRecordedTitle),
      content: _loading
          ? const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.dialogRecordedMessage(_recordLabel(l10n)),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  l10n.dialogRecordedDate(
                    DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
                        .format(_recordedDate()),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                if (_todayFailed)
                  Text(l10n.dialogTodayFailed)
                else if (widget.specificDate != null)
                  Text(l10n.dialogDateTotal(_todayValue!, widget.card.unit))
                else
                  Text(l10n.dialogTodayTotal(_todayValue!, widget.card.unit)),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () {
            _autoCloseTimer?.cancel();
            Navigator.of(context).pop();
          },
          child: Text(l10n.buttonOk),
        ),
      ],
    );
  }
}
