import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms || !_notMinor) {
      setState(() => _errorMessage = 'すべての項目に同意してください');
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
          _errorMessage = 'ネットワークに接続できません。';
        } else {
          _errorMessage = '登録に失敗しました（${e.response?.statusCode ?? "不明"}）。';
        }
      });
    } on Exception catch (e) {
      setState(() => _errorMessage = '登録に失敗しました: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新規登録')),
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
                      decoration: const InputDecoration(
                        labelText: 'ユーザー名',
                        border: OutlineInputBorder(),
                        helperText: '小文字英字で始まる2〜33文字（英数字・ハイフン）',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return '入力してください';
                        if (!_usernameRegex.hasMatch(v.trim())) {
                          return '小文字英字で始まる2〜33文字（英数字・ハイフンのみ）';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _tokenController,
                      obscureText: _obscureToken,
                      decoration: InputDecoration(
                        labelText: 'トークン',
                        border: const OutlineInputBorder(),
                        helperText: '8〜128文字（ASCII印字可能文字）',
                        suffixIcon: IconButton(
                          icon: Icon(_obscureToken
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscureToken = !_obscureToken),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return '入力してください';
                        if (!_tokenRegex.hasMatch(v.trim())) {
                          return '8〜128文字のASCII印字可能文字';
                        }
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
                      const TextSpan(text: 'Pixelaの'),
                      TextSpan(
                        text: '利用規約',
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
                      const TextSpan(text: 'に同意する'),
                    ],
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: _notMinor,
                onChanged: (v) => setState(() => _notMinor = v ?? false),
                title: const Text('18歳以上である、または保護者の同意を得ている'),
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
                      : const Text('登録する'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
