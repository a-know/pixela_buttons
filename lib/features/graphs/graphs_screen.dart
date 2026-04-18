import 'package:flutter/material.dart';
import '../../core/api/pixela_client.dart';
import '../../core/storage/card_storage.dart';

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
        title: const Text('グラフ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchGraphs,
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('エラー: $_error'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _fetchGraphs,
                    child: const Text('再試行'),
                  ),
                ],
              ),
            )
          : _graphs == null
              ? const Center(child: CircularProgressIndicator())
              : _graphs!.isEmpty
                  ? const Center(child: Text('グラフがありません'))
                  : ListView.separated(
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
                            '${g['id']}  ·  単位: ${g['unit']}  ·  ${g['type']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
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
