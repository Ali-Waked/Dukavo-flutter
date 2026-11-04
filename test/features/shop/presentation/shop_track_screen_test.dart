import 'package:dukavo_mobile/app/localization/app_localizations.dart';
import 'package:dukavo_mobile/app/theme/app_theme.dart';
import 'package:dukavo_mobile/features/shop/application/shop_providers.dart';
import 'package:dukavo_mobile/features/shop/presentation/shop_track_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/test_app.dart';

void main() {
  setUpAll(preloadLocalizations);

  testWidgets('requires a tracking token before searching', (tester) async {
    await pumpTestApp(
      tester,
      const Scaffold(
        body: ShopTrackScreen(shop: ShopRef('acme', 'main')),
      ),
    );

    await tester.tap(find.text('Find order'));
    await tester.pumpAndSettle();

    expect(find.text('This field is required.'), findsOneWidget);
  });

  testWidgets('accepts a pasted tracking link and opens the order',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: ShopTrackScreen(shop: ShopRef('acme', 'main')),
          ),
        ),
        GoRoute(
          path: '/shop/:tenant/:store/order/:token',
          builder: (context, state) => Scaffold(
            body: Text('order ${state.pathParameters['token']}'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField),
      'https://dukavo.com/shop/acme/main/order/abc123?source=email',
    );
    await tester.tap(find.text('Find order'));
    await tester.pumpAndSettle();

    expect(find.text('order abc123'), findsOneWidget);
  });
}
