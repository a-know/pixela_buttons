import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/pixela_client.dart';
import '../../core/models/card_config.dart';
import '../../core/storage/card_storage.dart';
import '../../core/theme/app_theme.dart';
import 'record_dialog.dart';

class CardWidget extends StatefulWidget {
  final CardConfig card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CardWidget({
    super.key,
    required this.card,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  CardConfig get card => widget.card;

  String? _todayValue;

  @override
  void initState() {
    super.initState();
    _fetchTodayValue();
  }

  Future<void> _fetchTodayValue() async {
    try {
      final username = await CardStorage.getUsername() ?? '';
      final value = await pixelaClient.getTodayValue(username, card.graphId);
      if (mounted) setState(() => _todayValue = _formatValue(value ?? 0));
    } catch (_) {
      if (mounted) setState(() => _todayValue = '--');
    }
  }

  String _formatValue(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  Color get _addColor {
    try {
      return Color(int.parse(card.color.replaceFirst('#', 'FF'), radix: 16));
    } catch (_) {
      return Colors.teal;
    }
  }

  Future<void> _record(BuildContext context, double value) async {
    final username = await CardStorage.getUsername() ?? '';
    try {
      if (value >= 0) {
        await pixelaClient.addPixel(username, card.graphId, value);
      } else {
        await pixelaClient.subtractPixel(username, card.graphId, value.abs());
      }
      if (context.mounted) await RecordDialog.show(context, card, value);
      _fetchTodayValue();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    }
  }

  Future<void> _showCustomDialog(BuildContext context) async {
    final controller = TextEditingController();
    final value = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('カスタム値を入力'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: true),
          decoration: InputDecoration(
            labelText: '値（${card.unit}）',
            border: const OutlineInputBorder(),
            helperText: '正の数: 加算　負の数: 減算',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(controller.text);
              Navigator.of(ctx).pop(v);
            },
            child: const Text('記録'),
          ),
        ],
      ),
    );
    if (value != null && context.mounted) {
      await _record(context, value);
    }
  }

  void _openGraph(String username) {
    final url = ApiEndpoints.graphHtml(username, card.graphId);
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final addColor = _addColor;
    final subtractColor = AppTheme.darkenColor(addColor);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.drag_handle, color: Colors.grey),
                const SizedBox(width: 8),
                if (card.emoji.isNotEmpty)
                  Text(card.emoji,
                      style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    card.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                FutureBuilder<String?>(
                  future: CardStorage.getUsername(),
                  builder: (ctx, snap) => IconButton(
                    icon: const Icon(Icons.open_in_new, size: 18),
                    onPressed: () => _openGraph(snap.data ?? ''),
                    tooltip: 'グラフを開く',
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onSelected: (v) {
                    if (v == 'edit') widget.onEdit();
                    if (v == 'delete') widget.onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('編集')),
                    PopupMenuItem(value: 'delete', child: Text('削除')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                _todayValue != null
                    ? '単位: ${card.unit}　今日: $_todayValue${card.unit}'
                    : '単位: ${card.unit}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...card.buttons.map((btn) {
                    final isAdd = btn.value >= 0;
                    final color = isAdd ? addColor : subtractColor;
                    final label =
                        '${isAdd ? "+" : ""}${btn.value == btn.value.truncateToDouble() ? btn.value.toInt() : btn.value}';
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: color),
                        onPressed: () => _record(context, btn.value),
                        child: Text(label),
                      ),
                    );
                  }),
                  OutlinedButton(
                    onPressed: () => _showCustomDialog(context),
                    child: const Text('カスタム'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
