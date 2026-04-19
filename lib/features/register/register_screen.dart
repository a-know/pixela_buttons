import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pixela_buttons/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api/pixela_client.dart';
import '../../core/storage/card_storage.dart';
import '../../core/storage/secure_storage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _obscureToken = true;
  bool _agreeTerms = false;
  bool _notMinor = false;
  bool _isLoading = false;
  String? _errorMessage;

  static final _usernameRegex = RegExp(r'^[a-z][a-z0-9\-]{1,32}$');
  static final _tokenRegex = RegExp(r'^[ -~]{8,128}$');

  @override
  void dispose() {
    _usernameController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms || !_notMinor) {
      setState(() => _errorMessage = l10n.errorAgreeAll);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final username = _usernameController.text.trim();
      final token = _tokenController.text.trim();

      await pixelaClient.createUser(
        username: username,
        token: token,
        agreeTermsOfService: true,
        notMinor: true,
      );

      await SecureStorage.saveToken(token);
      await CardStorage.saveUsername(username);

      if (mounted) context.go('/home');
    } on DioException catch (e) {
      setState(() {
        final msg = e.response?.data?['message'] as String?;
        if (msg != null) {
          _errorMessage = msg;
        } else if (e.type == DioExceptionType.connectionError) {
          _errorMessage = l10n.errorNoNetwork;
        } else {
          _errorMessage = l10n.errorRegisterFailed(e.response?.statusCode?.toString() ?? '?');
        }
      });
    } on Exception catch (e) {
      setState(() => _errorMessage = l10n.errorRegisterUnknown(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.screenRegister)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: l10n.fieldUsername,
                        border: const OutlineInputBorder(),
                        helperText: l10n.fieldUsernameHelper,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                        if (!_usernameRegex.hasMatch(v.trim())) return l10n.fieldUsernameError;
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _tokenController,
                      obscureText: _obscureToken,
                      decoration: InputDecoration(
                        labelText: l10n.fieldToken,
                        border: const OutlineInputBorder(),
                        helperText: l10n.fieldTokenHelper,
                        suffixIcon: IconButton(
                          icon: Icon(_obscureToken
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscureToken = !_obscureToken),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                        if (!_tokenRegex.hasMatch(v.trim())) return l10n.fieldTokenError;
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _agreeTerms,
                onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                title: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(text: l10n.labelAgreeTerms),
                      TextSpan(
                        text: l10n.linkTermsOfService,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrl(
                                Uri.parse('https://pixe.la/terms'),
                                mode: LaunchMode.externalApplication,
                              ),
                      ),
                    ],
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: _notMinor,
                onChanged: (v) => setState(() => _notMinor = v ?? false),
                title: Text(l10n.labelNotMinor),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.buttonRegister),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
