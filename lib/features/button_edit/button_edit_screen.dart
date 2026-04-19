import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:pixela_buttons/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../main_shell.dart';
import '../../core/models/button_config.dart';
import '../../core/models/card_config.dart';
import '../../core/storage/card_storage.dart';
import 'graph_select_screen.dart';

class ButtonEditScreen extends StatefulWidget {
  final CardConfig? existing;
  final GraphInfo? preSelectedGraph;

  const ButtonEditScreen({super.key, this.existing, this.preSelectedGraph});

  @override
  State<ButtonEditScreen> createState() => _ButtonEditScreenState();
}

class _ButtonEditScreenState extends State<ButtonEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();

  GraphInfo? _selectedGraph;
  Color _selectedColor = const Color(0xFF1D9E75);
  String _selectedEmoji = '';
  List<ButtonConfig> _buttons = [];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final c = widget.existing!;
      _displayNameController.text = c.displayName;
      _selectedEmoji = c.emoji;
      try {
        _selectedColor =
            Color(int.parse(c.color.replaceFirst('#', 'FF'), radix: 16));
      } catch (_) {}
      _buttons = List.from(c.buttons);
      _selectedGraph =
          GraphInfo(id: c.graphId, name: c.displayName, unit: c.unit);
    } else if (widget.preSelectedGraph != null) {
      _selectedGraph = widget.preSelectedGraph;
      _displayNameController.text = widget.preSelectedGraph!.name;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickEmoji() async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SizedBox(
        height: 350,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(l10n.emojiPickerTitle),
                ),
                if (_selectedEmoji.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedEmoji = '');
                      Navigator.of(ctx).pop();
                    },
                    child: Text(l10n.emojiPickerClear),
                  ),
              ],
            ),
            Expanded(
              child: EmojiPicker(
                onEmojiSelected: (_, emoji) {
                  setState(() => _selectedEmoji = emoji.emoji);
                  Navigator.of(ctx).pop();
                },
                config: const Config(
                  emojiViewConfig: EmojiViewConfig(columns: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    final l10n = AppLocalizations.of(context)!;
    Color color = _selectedColor;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.labelButtonColor),
        content: ColorPicker(
          color: color,
          onColorChanged: (c) => color = c,
          pickersEnabled: const {ColorPickerType.both: true},
          enableShadesSelection: false,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.buttonOk),
          ),
        ],
      ),
    );
    setState(() => _selectedColor = color);
  }

  void _addButton() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final value = await showDialog<double>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final parsed = double.tryParse(controller.text);
          final hasInput = controller.text.isNotEmpty;
          final isInvalid = hasInput && parsed == null;

          return AlertDialog(
            title: Text(l10n.addFixedButtonTitle),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: true),
              decoration: InputDecoration(
                labelText: l10n.addFixedButtonHelper,
                border: const OutlineInputBorder(),
                errorText: isInvalid ? l10n.addFixedButtonError : null,
              ),
              autofocus: true,
              onChanged: (_) => setDialogState(() {}),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.buttonCancel),
              ),
              FilledButton(
                onPressed: parsed != null
                    ? () => Navigator.of(ctx).pop(parsed)
                    : null,
                child: Text(l10n.buttonAdd),
              ),
            ],
          );
        },
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
        SnackBar(content: Text(AppLocalizations.of(context)!.snackSelectGraph)),
      );
      return;
    }

    final colorHex =
        '#${_selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

    final card = CardConfig(
      id: widget.existing?.id,
      graphId: _selectedGraph!.id,
      displayName: _displayNameController.text.trim(),
      emoji: _selectedEmoji,
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

    if (mounted) {
      homeTabNotifier.value++;
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? AppLocalizations.of(context)!.screenButtonEdit : AppLocalizations.of(context)!.screenButtonAdd),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(AppLocalizations.of(context)!.buttonSave),
          ),
        ],
      ),
      body: Builder(builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Graph selection
            ListTile(
              title: Text(l10n.labelGraph),
              subtitle: _selectedGraph == null
                  ? Text(l10n.labelGraphPlaceholder, style: const TextStyle(color: Colors.grey))
                  : Text(l10n.labelGraphSubtitle(_selectedGraph!.name, _selectedGraph!.id, _selectedGraph!.unit)),
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
              decoration: InputDecoration(
                labelText: l10n.fieldDisplayName,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 16),

            // Emoji
            ListTile(
              title: Text(l10n.fieldEmoji),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedEmoji.isEmpty ? l10n.emojiNotSet : _selectedEmoji,
                    style: TextStyle(
                      fontSize: _selectedEmoji.isEmpty ? 14 : 24,
                      color: _selectedEmoji.isEmpty ? Colors.grey : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: _pickEmoji,
            ),
            const SizedBox(height: 16),

            // Color picker
            ListTile(
              title: Text(l10n.labelButtonColor),
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
                Text(l10n.labelFixedButtons,
                    style: Theme.of(context).textTheme.titleSmall),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addButton,
                  tooltip: l10n.tooltipAddFixedButton,
                ),
              ],
            ),
            if (_buttons.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l10n.noFixedButtons,
                    style: const TextStyle(color: Colors.grey)),
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
      );
      }),
    );
  }
}
