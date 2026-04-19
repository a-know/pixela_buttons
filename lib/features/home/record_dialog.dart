import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pixela_buttons/l10n/app_localizations.dart';
import '../../core/api/pixela_client.dart';
import '../../core/models/card_config.dart';
import '../../core/storage/card_storage.dart';

class RecordDialog extends StatefulWidget {
  final CardConfig card;
  final double value;

  const RecordDialog({super.key, required this.card, required this.value});

  static Future<void> show(
      BuildContext context, CardConfig card, double value) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RecordDialog(card: card, value: value),
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
      final value =
          await pixelaClient.getTodayValue(username, widget.card.graphId);
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
                const SizedBox(height: 8),
                if (_todayFailed)
                  Text(l10n.dialogTodayFailed)
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
