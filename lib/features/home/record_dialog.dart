import 'dart:async';
import 'package:flutter/material.dart';
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

  String get _recordLabel {
    final sign = widget.value >= 0 ? '+' : '';
    return '$sign${_formatValue(widget.value)}${widget.card.unit}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('記録しました'),
      content: _loading
          ? const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$_recordLabel を記録しました',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (_todayFailed)
                  const Text('累計値の取得に失敗しました')
                else
                  Text('今日の合計: $_todayValue${widget.card.unit}'),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () {
            _autoCloseTimer?.cancel();
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
