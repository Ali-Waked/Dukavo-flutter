import 'package:dukavo_mobile/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// End-to-end smoke tests that run on a device or emulator.
///
/// Run with:
///
///   flutter test integration_test/app_boot_test.dart \
///     --dart-define=DUKAVO_API_BASE_URL=http://10.0.2.2:8000/api/v1
///
/// The login test only runs when credentials are supplied:
///
///   --dart-define=DUKAVO_TEST_EMAIL=owner@example.com \
///   --dart-define=DUKAVO_TEST_PASSWORD=password
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const email = String.fromEnvironment('DUKAVO_TEST_EMAIL');
  const password = String.fromEnvironment('DUKAVO_TEST_PASSWORD');

  testWidgets('boots to the login screen when no session is stored',
      (tester) async {
    await app.main();

    // The splash screen animates a progress indicator, so pump in steps until
    // the router has decided where to go rather than using pumpAndSettle.
    for (var attempt = 0; attempt < 40; attempt++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.text('Welcome back').evaluate().isNotEmpty) break;
    }

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets(
    'signs in with real credentials and reaches the workspace',
    (tester) async {
      await app.main();

      for (var attempt = 0; attempt < 40; attempt++) {
        await tester.pump(const Duration(milliseconds: 250));
        if (find.text('Welcome back').evaluate().isNotEmpty) break;
      }

      await tester.enterText(find.byType(TextFormField).at(0), email);
      await tester.enterText(find.byType(TextFormField).at(1), password);
      await tester.tap(find.text('Sign in'));

      // The dashboard loads several aggregates, so allow a generous window.
      for (var attempt = 0; attempt < 120; attempt++) {
        await tester.pump(const Duration(milliseconds: 250));
        if (find.text('Dashboard').evaluate().isNotEmpty) break;
      }

      expect(find.text('Dashboard'), findsWidgets);
    },
    skip: email.isEmpty || password.isEmpty,
  );
}
