import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pixela_buttons/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/pixela_client.dart';
import '../../core/storage/card_storage.dart';
import '../button_edit/graph_select_screen.dart';
import 'graph_create_screen.dart';

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({super.key});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  List<Map<String, dynamic>>? _graphs;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchGraphs();
  }

  Future<void> _deleteGraph(Map<String, dynamic> g) async {
    final l10n = AppLocalizations.of(context)!;
    final name = g['name'] as String? ?? '';
    final graphId = g['id'] as String;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDeleteGraphTitle),
        content: Text(l10n.confirmDeleteGraphMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.buttonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final username = await CardStorage.getUsername() ?? '';
      await pixelaClient.deleteGraph(username, graphId);

      final cards = await CardStorage.loadCards();
      final filtered = cards.where((c) => c.graphId != graphId).toList();
      if (filtered.length < cards.length) {
        await CardStorage.saveCards(filtered);
      }

      if (mounted) _fetchGraphs();
    } catch (e) {
      if (!mounted) return;
      final msg = e is DioException
          ? l10n.errorGeneric(e.response?.statusCode?.toString() ?? '?')
          : l10n.errorUnknown(e.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _fetchGraphs() async {
    setState(() {
      _graphs = null;
      _error = null;
    });
    try {
      final username = await CardStorage.getUsername() ?? '';
      final graphs = await pixelaClient.getGraphs(username);
      setState(() => _graphs = graphs);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.screenGraphs),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart),
            tooltip: AppLocalizations.of(context)!.tooltipCreateGraph,
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                    builder: (_) => const GraphCreateScreen()),
              );
              if (created == true) _fetchGraphs();
            },
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.errorGeneric(_error ?? '')),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _fetchGraphs,
                    child: Text(AppLocalizations.of(context)!.errorRetry),
                  ),
                ],
              ),
            )
          : _graphs == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchGraphs,
                  child: _graphs!.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 200,
                        child: Center(child: Text(AppLocalizations.of(context)!.noGraphs)),
                      ),
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _graphs!.length,
                      separatorBuilder: (context, _) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final g = _graphs![i];
                        final l10n = AppLocalizations.of(context)!;
                        return Slidable(
                          key: ValueKey(g['id']),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                onPressed: (_) => _deleteGraph(g),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete_outline,
                                label: l10n.buttonDelete,
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _parseColor(g['color'] as String?),
                              child: Text(
                                (g['name'] as String? ?? '?')[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(g['name'] as String? ?? ''),
                            subtitle: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              children: [
                                _typeBadge(context, g['type'] as String? ?? ''),
                                Text(
                                  '${g['id']}  ·  ${l10n.labelUnit(g['unit'] as String? ?? '')}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.add_circle_outline),
                            onTap: () {
                              final graph = GraphInfo(
                                id: g['id'] as String,
                                name: g['name'] as String,
                                unit: g['unit'] as String,
                              );
                              context.push('/button-edit', extra: graph);
                            },
                          ),
                        );
                      },
                    ),
                ),
    );
  }

  Widget _typeBadge(BuildContext context, String type) {
    final (bg, fg) = switch (type) {
      'int'   => (Colors.blue.withAlpha(40), Colors.blue),
      'float' => (Colors.orange.withAlpha(40), Colors.orange.shade800),
      _       => (Colors.grey.withAlpha(40), Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
      ),
    );
  }

  Color _parseColor(String? colorName) {
    const colors = {
      'shibafu': Color(0xFF7BC67A),
      'momiji': Color(0xFFE05B4B),
      'sora': Color(0xFF54A0FF),
      'ichou': Color(0xFFF9CA24),
      'ajisai': Color(0xFF786FA6),
      'kuro': Color(0xFF353B48),
    };
    return colors[colorName] ?? Colors.teal;
  }
}
