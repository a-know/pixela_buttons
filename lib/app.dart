import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:pixela_buttons/l10n/app_localizations.dart';
import 'core/api/pixela_client.dart';
import 'core/models/card_config.dart';
import 'features/button_edit/graph_select_screen.dart';
import 'core/storage/card_storage.dart';
import 'core/storage/secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/button_edit/button_edit_screen.dart';
import 'features/main_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/register/register_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// null = システム設定に従う
final localeNotifier = ValueNotifier<Locale?>(null);

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/loading',
  routes: [
    GoRoute(
      path: '/loading',
      builder: (context, _) => const _LoadingScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, state) => OnboardingScreen(
        errorMessage: state.extra as String?,
      ),
    ),
    GoRoute(
      path: '/register',
      builder: (context, _) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, _) => const MainShell(),
    ),
    GoRoute(
      path: '/button-edit',
      builder: (_, state) {
        final extra = state.extra;
        if (extra is CardConfig) return ButtonEditScreen(existing: extra);
        if (extra is GraphInfo) return ButtonEditScreen(preSelectedGraph: extra);
        return const ButtonEditScreen();
      },
    ),
  ],
);

class PixelaButtonsApp extends StatefulWidget {
  const PixelaButtonsApp({super.key});

  @override
  State<PixelaButtonsApp> createState() => _PixelaButtonsAppState();
}

class _PixelaButtonsAppState extends State<PixelaButtonsApp> {
  @override
  void initState() {
    super.initState();
    pixelaClient.onUnauthorized = _onUnauthorized;
    localeNotifier.addListener(_onLocaleChanged);
    _loadSavedLocale();
  }

  @override
  void dispose() {
    localeNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  Future<void> _loadSavedLocale() async {
    final code = await CardStorage.getLocale();
    if (code != null) localeNotifier.value = Locale(code);
  }

  void _onLocaleChanged() => setState(() {});

  void _onUnauthorized() {
    final ctx = _rootNavigatorKey.currentContext;
    if (ctx == null) return;
    final msg = AppLocalizations.of(ctx)?.tokenInvalidBanner ?? '';
    ctx.go('/onboarding', extra: msg);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pixela Buttons',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: localeNotifier.value,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ja'),
      ],
      routerConfig: _router,
    );
  }
}

class _LoadingScreen extends StatefulWidget {
  const _LoadingScreen();

  @override
  State<_LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<_LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await SecureStorage.getToken();
    final username = await CardStorage.getUsername();
    if (mounted) {
      if (token != null && username != null) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
