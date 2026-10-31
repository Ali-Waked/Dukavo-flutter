import 'package:dukavo_mobile/app/localization/app_localizations.dart';
import 'package:dukavo_mobile/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled ARB files into the localisation cache.
///
/// Widget tests never run `bootstrap()`, so this is the one piece of start-up
/// work they must repeat. It is deliberately cheap: two small JSON assets.
Future<void> preloadLocalizations() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await AppLocalizations.preload();
}

/// Wraps [child] in the same theme, locale and localisation delegates the app
/// uses, without booting the router or any platform plugin.
Future<void> pumpTestApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const <Override>[],
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.light,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
