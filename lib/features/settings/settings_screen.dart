import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/pixela_client.dart';
import '../../core/storage/card_storage.dart';
import '../../core/storage/secure_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final username = await CardStorage.getUsername();
    setState(() => _username = username);
  }

  Future<void> _showChangeTokenDialog() async {
    final controller = TextEditingController();
    bool obscure = true;
    String? errorText;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('保存済みトークンを変更'),
          content: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: '新しいトークン',
              border: const OutlineInputBorder(),
              errorText: errorText,
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setDialogState(() => obscure = !obscure),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () async {
                final token = controller.text.trim();
                if (token.isEmpty) {
                  setDialogState(() => errorText = '入力してください');
                  return;
                }
                // Verify new token
                await SecureStorage.saveToken(token);
                try {
                  await pixelaClient.getGraphs(_username ?? '');
                  if (ctx.mounted) Navigator.of(ctx).pop();
                } on DioException catch (e) {
                  await SecureStorage.deleteToken();
                  setDialogState(() => errorText =
                      e.response?.statusCode == 400 || e.response?.statusCode == 401
                          ? 'トークンが正しくありません'
                          : 'エラーが発生しました');
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('ログアウトします。カード設定は保持され、再ログイン時に復元されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SecureStorage.deleteToken();
      await CardStorage.clearUsername();
      if (mounted) context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('ユーザー名'),
            subtitle: Text(_username ?? ''),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.key_outlined),
            title: const Text('アプリに保存済みのトークンを変更'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showChangeTokenDialog,
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout,
                color: Theme.of(context).colorScheme.error),
            title: Text(
              'ログアウト',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
