import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pixela_buttons/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    bool obscure = true;
    String? errorText;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.dialogChangeTokenTitle),
          content: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: l10n.fieldNewToken,
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
              child: Text(l10n.buttonCancel),
            ),
            FilledButton(
              onPressed: () async {
                final token = controller.text.trim();
                if (token.isEmpty) {
                  setDialogState(() => errorText = l10n.fieldRequired);
                  return;
                }
                await SecureStorage.saveToken(token);
                try {
                  await pixelaClient.getGraphs(_username ?? '');
                  if (ctx.mounted) Navigator.of(ctx).pop();
                } on DioException catch (e) {
                  await SecureStorage.deleteToken();
                  setDialogState(() => errorText =
                      e.response?.statusCode == 400 || e.response?.statusCode == 401
                          ? l10n.errorTokenIncorrect
                          : l10n.errorTokenGeneric);
                }
              },
              child: Text(l10n.buttonSave),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialogLogoutTitle),
        content: Text(l10n.dialogLogoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.buttonLogout),
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.screenSettings)),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.labelUsernameItem),
            subtitle: Text(_username ?? ''),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.key_outlined),
            title: Text(l10n.labelChangeToken),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showChangeTokenDialog,
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout,
                color: Theme.of(context).colorScheme.error),
            title: Text(
              l10n.labelLogout,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
