import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/card_config.dart';
import '../../core/storage/card_storage.dart';
import 'card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CardConfig> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await CardStorage.loadCards();
    setState(() => _cards = cards);
  }

  Future<void> _deleteCard(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('削除の確認'),
        content: const Text('このカードを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final updated = _cards.where((c) => c.id != id).toList();
      await CardStorage.saveCards(updated);
      setState(() => _cards = updated);
    }
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final updated = List<CardConfig>.from(_cards);
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    await CardStorage.saveCards(updated);
    setState(() => _cards = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pixela Buttons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'ボタンを追加',
            onPressed: () async {
              await context.push('/button-edit');
              _loadCards();
            },
          ),
        ],
      ),
      body: _cards.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'ボタンがまだありません',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text('右上の ＋ から追加してください',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _cards.length,
              onReorder: _reorder,
              itemBuilder: (ctx, i) {
                final card = _cards[i];
                return KeyedSubtree(
                  key: ValueKey(card.id),
                  child: CardWidget(
                    card: card,
                    onEdit: () async {
                      await context.push('/button-edit', extra: card);
                      _loadCards();
                    },
                    onDelete: () => _deleteCard(card.id),
                  ),
                );
              },
            ),
    );
  }
}
