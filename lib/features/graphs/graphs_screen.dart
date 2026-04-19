import 'package:flutter/material.dart';
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
            icon: const Icon(Icons.add),
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
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _parseColor(g['color'] as String?),
                            child: Text(
                              (g['name'] as String? ?? '?')[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(g['name'] as String? ?? ''),
                          subtitle: Text(
                            '${g['id']}  ·  ${AppLocalizations.of(context)!.labelUnit(g['unit'] as String? ?? '')}  ·  ${g['type']}',
                            style: Theme.of(context).textTheme.bodySmall,
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
                        );
                      },
                    ),
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
