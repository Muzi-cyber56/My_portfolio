import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osint_platform/config/app_config.dart';
import 'package:osint_platform/screens/login_screen.dart';

void main() {
  testWidgets('Login validates empty credentials without a request', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppConfig.theme,
        home: LoginScreen(onSignedIn: () {}),
      ),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();
    expect(find.text('Use at least 3 characters.'), findsOneWidget);
    expect(find.text('Use at least 12 characters.'), findsOneWidget);
  });
  testWidgets('Registration toggle exposes create account flow', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppConfig.theme,
        home: LoginScreen(onSignedIn: () {}),
      ),
    );
    await tester.tap(find.text('New analyst? Create an account'));
    await tester.pump();
    expect(find.text('Create your workspace'), findsOneWidget);
  });
}
