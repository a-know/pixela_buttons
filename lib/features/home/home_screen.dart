import 'package:flutter/material.dart';
import 'package:pixela_buttons/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.buttonDelete),
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.screenHome),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.tooltipAddButton,
            onPressed: () => context.push('/button-edit'),
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
                    l10n.emptyHomeMessage,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.emptyHomeSubMessage,
                      style: const TextStyle(color: Colors.grey)),
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
                    onEdit: () => context.push('/button-edit', extra: card),
                    onDelete: () => _deleteCard(card.id),
                  ),
                );
              },
            ),
    );
  }
}
