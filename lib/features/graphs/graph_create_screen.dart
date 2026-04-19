import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pixela_buttons/l10n/app_localizations.dart';
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
        _errorMessage = msg ?? AppLocalizations.of(context)!.errorGeneric(e.response?.statusCode?.toString() ?? '?');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.screenCreateGraph),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _create,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(AppLocalizations.of(context)!.buttonCreate),
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

            TextFormField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: l10n.fieldGraphId,
                border: const OutlineInputBorder(),
                helperText: l10n.fieldGraphIdHelper,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                if (!_idRegex.hasMatch(v.trim())) return l10n.fieldGraphIdError;
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.fieldGraphName,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: l10n.fieldUnit,
                border: const OutlineInputBorder(),
                helperText: l10n.fieldUnitHelper,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: l10n.fieldType,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'int', child: Text(l10n.typeInt)),
                DropdownMenuItem(value: 'float', child: Text(l10n.typeFloat)),
              ],
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _color,
              decoration: InputDecoration(
                labelText: l10n.fieldColor,
                border: const OutlineInputBorder(),
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

            ListTile(
              title: Text(l10n.fieldTimezone),
              subtitle: Text(_timezone.isEmpty ? l10n.timezoneNotSet : _timezone),
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
      );
      }),
    );
  }
}
