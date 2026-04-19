import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../../core/api/pixela_client.dart';
import '../../core/storage/card_storage.dart';
import '../../widgets/timezone_picker_screen.dart';

const _colorOptions = [
  ('shibafu', 'shibafu', Color(0xFF7BC67A)),
  ('momiji',  'momiji',  Color(0xFFE05B4B)),
  ('sora',    'sora',    Color(0xFF54A0FF)),
  ('ichou',   'ichou',   Color(0xFFF9CA24)),
  ('ajisai',  'ajisai',  Color(0xFF786FA6)),
  ('kuro',    'kuro',    Color(0xFF353B48)),
];

class GraphCreateScreen extends StatefulWidget {
  const GraphCreateScreen({super.key});

  @override
  State<GraphCreateScreen> createState() => _GraphCreateScreenState();
}

class _GraphCreateScreenState extends State<GraphCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  String _timezone = '';

  String _type = 'int';
  String _color = 'shibafu';
  bool _isLoading = false;
  String? _errorMessage;

  static final _idRegex = RegExp(r'^[a-z][a-z0-9\-]{1,16}$');

  @override
  void initState() {
    super.initState();
    _loadDeviceTimezone();
  }

  Future<void> _loadDeviceTimezone() async {
    try {
      final tz = await FlutterTimezone.getLocalTimezone();
      if (mounted) setState(() => _timezone = tz.identifier);
    } catch (_) {
      if (mounted) setState(() => _timezone = 'UTC');
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final username = await CardStorage.getUsername() ?? '';
      await pixelaClient.createGraph(
        username: username,
        id: _idController.text.trim(),
        name: _nameController.text.trim(),
        unit: _unitController.text.trim(),
        type: _type,
        color: _color,
        timezone: _timezone.isEmpty ? null : _timezone,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on DioException catch (e) {
      setState(() {
        final msg = e.response?.data?['message'] as String?;
        _errorMessage = msg ?? 'エラーが発生しました（${e.response?.statusCode}）';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('グラフを作成'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _create,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('作成'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer),
                ),
              ),

            // ID
            TextFormField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'グラフID *',
                border: OutlineInputBorder(),
                helperText: '小文字英字で始まる2〜17文字（英数字・ハイフン）',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '入力してください';
                if (!_idRegex.hasMatch(v.trim())) return '小文字英字で始まる2〜17文字（英数字・ハイフンのみ）';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 名前
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'グラフ名 *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '入力してください' : null,
            ),
            const SizedBox(height: 16),

            // 単位
            TextFormField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: '単位 *',
                border: OutlineInputBorder(),
                helperText: '例: km、commit、kg',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '入力してください' : null,
            ),
            const SizedBox(height: 16),

            // タイプ
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'タイプ *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'int', child: Text('int（整数）')),
                DropdownMenuItem(value: 'float', child: Text('float（小数）')),
              ],
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),

            // カラー
            DropdownButtonFormField<String>(
              initialValue: _color,
              decoration: const InputDecoration(
                labelText: 'カラー *',
                border: OutlineInputBorder(),
              ),
              items: _colorOptions
                  .map((c) => DropdownMenuItem(
                        value: c.$1,
                        child: Row(
                          children: [
                            CircleAvatar(
                                backgroundColor: c.$3, radius: 10),
                            const SizedBox(width: 8),
                            Text(c.$2),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _color = v!),
            ),
            const SizedBox(height: 16),

            // タイムゾーン
            ListTile(
              title: const Text('タイムゾーン'),
              subtitle: Text(_timezone.isEmpty ? '未設定' : _timezone),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: () async {
                final selected = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => const TimezonePickerScreen(),
                  ),
                );
                if (selected != null) setState(() => _timezone = selected);
              },
            ),
          ],
        ),
      ),
    );
  }
}
