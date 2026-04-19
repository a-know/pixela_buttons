import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pixela_buttons/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/pixela_client.dart';
import '../../core/storage/card_storage.dart';
import '../../core/storage/secure_storage.dart';

class OnboardingScreen extends StatefulWidget {
  final String? errorMessage;

  const OnboardingScreen({super.key, this.errorMessage});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _obscureToken = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _errorMessage = widget.errorMessage;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final l10n = AppLocalizations.of(context)!;
    try {
      final username = _usernameController.text.trim();
      final token = _tokenController.text.trim();

      await SecureStorage.saveToken(token);
      try {
        await pixelaClient.getGraphs(username);
      } catch (e) {
        await SecureStorage.deleteToken();
        rethrow;
      }

      await CardStorage.saveUsername(username);
      if (mounted) context.go('/home');
    } on DioException catch (e) {
      setState(() {
        if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
          _errorMessage = l10n.errorInvalidCredentials;
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          _errorMessage = l10n.errorTimeout;
        } else if (e.type == DioExceptionType.connectionError) {
          _errorMessage = l10n.errorNoNetwork;
        } else {
          _errorMessage = l10n.errorGeneric(e.response?.statusCode?.toString() ?? '?');
        }
      });
    } on Exception catch (e) {
      setState(() => _errorMessage = l10n.errorUnknown(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Image.asset(
                MediaQuery.platformBrightnessOf(context) == Brightness.dark
                    ? 'assets/images/pixela_icon_monochrome.png'
                    : 'assets/images/pixela_icon_color.png',
                height: 64,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.appTitle,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.appTagline,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
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
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? l10n.fieldRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tokenController,
                      obscureText: _obscureToken,
                      decoration: InputDecoration(
                        labelText: l10n.fieldToken,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureToken
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscureToken = !_obscureToken),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? l10n.fieldRequired : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _save,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.buttonStart),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.push('/register'),
                child: Text(l10n.linkCreateAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
