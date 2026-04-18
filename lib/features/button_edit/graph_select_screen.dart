import 'package:flutter/material.dart';
import '../../core/api/pixela_client.dart';
import '../../core/storage/card_storage.dart';

class GraphInfo {
  final String id;
  final String name;
  final String unit;

  const GraphInfo({required this.id, required this.name, required this.unit});
}

class GraphSelectScreen extends StatefulWidget {
  const GraphSelectScreen({super.key});

  @override
  State<GraphSelectScreen> createState() => _GraphSelectScreenState();
}

class _GraphSelectScreenState extends State<GraphSelectScreen> {
  List<GraphInfo>? _graphs;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchGraphs();
  }

  Future<void> _fetchGraphs() async {
    try {
      final username = await CardStorage.getUsername() ?? '';
      final data = await pixelaClient.getGraphs(username);
      setState(() {
        _graphs = data
            .map((g) => GraphInfo(
                  id: g['id'] as String,
                  name: g['name'] as String,
                  unit: g['unit'] as String,
                ))
            .toList();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('グラフを選択')),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('エラー: $_error'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _graphs = null;
                      });
                      _fetchGraphs();
                    },
                    child: const Text('再試行'),
                  ),
                ],
              ),
            )
          : _graphs == null
              ? const Center(child: CircularProgressIndicator())
              : _graphs!.isEmpty
                  ? const Center(child: Text('グラフがありません'))
                  : ListView.builder(
                      itemCount: _graphs!.length,
                      itemBuilder: (ctx, i) {
                        final g = _graphs![i];
                        return ListTile(
                          title: Text(g.name),
                          subtitle: Text('${g.id}  ·  単位: ${g.unit}'),
                          onTap: () => Navigator.of(ctx).pop(g),
                        );
                      },
                    ),
    );
  }
}
