import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixela_buttons/features/onboarding/onboarding_screen.dart';
import 'package:pixela_buttons/features/register/register_screen.dart';
import 'package:pixela_buttons/l10n/app_localizations.dart';

const _closedPortraitSize = Size(390, 844);
const _openInnerSize = Size(1000, 720);
const _closedLandscapeSize = Size(844, 390);

Future<void> _pumpScreen(WidgetTester tester, Widget screen, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ja'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ja')],
      home: screen,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _resize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('onboarding adapts across sizes and preserves input', (
    tester,
  ) async {
    await _pumpScreen(tester, const OnboardingScreen(), _closedPortraitSize);

    await tester.enterText(
      find.byKey(const ValueKey('onboarding_username_field')),
      'duo-test',
    );

    await _resize(tester, _openInnerSize);
    expect(
      tester.getSize(find.byKey(const ValueKey('onboarding_content'))).width,
      lessThanOrEqualTo(560),
    );
    expect(find.text('duo-test'), findsOneWidget);

    await _resize(tester, _closedLandscapeSize);
    final startButton = find.byKey(const ValueKey('onboarding_start_button'));
    await tester.ensureVisible(startButton);
    await tester.pumpAndSettle();

    expect(find.text('duo-test'), findsOneWidget);
    expect(startButton, findsOneWidget);
    expect(tester.getRect(startButton).bottom, lessThanOrEqualTo(390));
    expect(tester.takeException(), isNull);
  });

  testWidgets('register form stays constrained and reachable when resized', (
    tester,
  ) async {
    await _pumpScreen(tester, const RegisterScreen(), _closedPortraitSize);

    await tester.enterText(
      find.byKey(const ValueKey('register_username_field')),
      'duo-test',
    );

    await _resize(tester, _openInnerSize);
    expect(
      tester.getSize(find.byKey(const ValueKey('register_content'))).width,
      lessThanOrEqualTo(560),
    );
    expect(find.text('duo-test'), findsOneWidget);

    await _resize(tester, _closedLandscapeSize);
    final registerButton = find.byKey(const ValueKey('register_button'));
    await tester.ensureVisible(registerButton);
    await tester.pumpAndSettle();

    expect(find.text('duo-test'), findsOneWidget);
    expect(registerButton, findsOneWidget);
    expect(tester.getRect(registerButton).bottom, lessThanOrEqualTo(390));
    expect(tester.takeException(), isNull);
  });
}
