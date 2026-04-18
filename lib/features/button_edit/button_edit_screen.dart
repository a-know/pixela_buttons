import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/button_config.dart';
import '../../core/models/card_config.dart';
import '../../core/storage/card_storage.dart';
import 'graph_select_screen.dart';

class ButtonEditScreen extends StatefulWidget {
  final CardConfig? existing;

  const ButtonEditScreen({super.key, this.existing});

  @override
  State<ButtonEditScreen> createState() => _ButtonEditScreenState();
}

class _ButtonEditScreenState extends State<ButtonEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emojiController = TextEditingController();

  GraphInfo? _selectedGraph;
  Color _selectedColor = const Color(0xFF1D9E75);
  List<ButtonConfig> _buttons = [];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final c = widget.existing!;
      _displayNameController.text = c.displayName;
      _emojiController.text = c.emoji;
      try {
        _selectedColor =
            Color(int.parse(c.color.replaceFirst('#', 'FF'), radix: 16));
      } catch (_) {}
      _buttons = List.from(c.buttons);
      _selectedGraph =
          GraphInfo(id: c.graphId, name: c.displayName, unit: c.unit);
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  Future<void> _pickGraph() async {
    final graph = await Navigator.of(context).push<GraphInfo>(
      MaterialPageRoute(builder: (_) => const GraphSelectScreen()),
    );
    if (graph != null) {
      setState(() {
        _selectedGraph = graph;
        if (_displayNameController.text.isEmpty) {
          _displayNameController.text = graph.name;
        }
      });
    }
  }

  Future<void> _pickColor() async {
    Color color = _selectedColor;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ボタンの色'),
        content: ColorPicker(
          color: color,
          onColorChanged: (c) => color = c,
          pickersEnabled: const {ColorPickerType.both: true},
          enableShadesSelection: false,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('決定'),
          ),
        ],
      ),
    );
    setState(() => _selectedColor = color);
  }

  void _addButton() async {
    final controller = TextEditingController();
    final value = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('固定値ボタンを追加'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: true),
          decoration: const InputDecoration(
            labelText: '値（正: 加算 / 負: 減算）',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(double.tryParse(controller.text)),
            child: const Text('追加'),
          ),
        ],
      ),
    );
    if (value != null) {
      setState(() => _buttons.add(ButtonConfig(value: value)));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGraph == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('グラフを選択してください')),
      );
      return;
    }

    final colorHex =
        '#${_selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

    final card = CardConfig(
      id: widget.existing?.id,
      graphId: _selectedGraph!.id,
      displayName: _displayNameController.text.trim(),
      emoji: _emojiController.text.trim(),
      color: colorHex,
      unit: _selectedGraph!.unit,
      buttons: _buttons,
    );

    final cards = await CardStorage.loadCards();
    if (_isEdit) {
      final idx = cards.indexWhere((c) => c.id == card.id);
      if (idx >= 0) cards[idx] = card;
    } else {
      cards.add(card);
    }
    await CardStorage.saveCards(cards);

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'ボタンを編集' : 'ボタンを追加'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Graph selection
            ListTile(
              title: const Text('グラフ'),
              subtitle: _selectedGraph == null
                  ? const Text('タップして選択', style: TextStyle(color: Colors.grey))
                  : Text(
                      '${_selectedGraph!.name}\n${_selectedGraph!.id}  ·  単位: ${_selectedGraph!.unit}'),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300)),
              onTap: _pickGraph,
            ),
            const SizedBox(height: 16),

            // Display name
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: '表示名',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '入力してください' : null,
            ),
            const SizedBox(height: 16),

            // Emoji
            TextFormField(
              controller: _emojiController,
              decoration: const InputDecoration(
                labelText: 'emoji（任意）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Color picker
            ListTile(
              title: const Text('ボタン色（加算）'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300)),
              onTap: _pickColor,
            ),
            const SizedBox(height: 24),

            // Buttons list
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('固定値ボタン',
                    style: Theme.of(context).textTheme.titleSmall),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addButton,
                  tooltip: 'ボタンを追加',
                ),
              ],
            ),
            if (_buttons.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('ボタンがありません',
                    style: TextStyle(color: Colors.grey)),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _buttons.length,
                onReorder: (oldIdx, newIdx) {
                  if (newIdx > oldIdx) newIdx--;
                  setState(() {
                    final item = _buttons.removeAt(oldIdx);
                    _buttons.insert(newIdx, item);
                  });
                },
                itemBuilder: (ctx, i) {
                  final btn = _buttons[i];
                  final label = btn.value >= 0
                      ? '+${btn.value == btn.value.truncateToDouble() ? btn.value.toInt() : btn.value}'
                      : '${btn.value == btn.value.truncateToDouble() ? btn.value.toInt() : btn.value}';
                  return ListTile(
                    key: ValueKey(btn.id),
                    leading: const Icon(Icons.drag_handle),
                    title: Text(label),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          setState(() => _buttons.removeAt(i)),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
