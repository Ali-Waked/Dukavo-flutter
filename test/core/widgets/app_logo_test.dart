import 'package:dukavo_mobile/app/localization/app_localizations.dart';
import 'package:dukavo_mobile/app/theme/app_theme.dart';
import 'package:dukavo_mobile/core/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppLocalizations.preload();
  });

  Future<void> pumpLogo(
    WidgetTester tester, {
    required Locale locale,
    required ThemeData theme,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(
          body: Center(child: AppLogo(showWordmark: true)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String assetName(WidgetTester tester) {
    final image = tester.widget<Image>(find.byType(Image));
    return (image.image as AssetImage).assetName;
  }

  testWidgets('uses the English artwork for English in both themes',
      (tester) async {
    await pumpLogo(
      tester,
      locale: const Locale('en'),
      theme: AppTheme.light,
    );
    expect(assetName(tester), 'assets/images/logo-full-en-light.png');

    await pumpLogo(
      tester,
      locale: const Locale('en'),
      theme: AppTheme.dark,
    );
    expect(assetName(tester), 'assets/images/logo-full-en-dark.png');
  });

  testWidgets('uses the Arabic artwork for Arabic in both themes',
      (tester) async {
    await pumpLogo(
      tester,
      locale: const Locale('ar'),
      theme: AppTheme.light,
    );
    expect(assetName(tester), 'assets/images/logo-full-ar-light.png');

    await pumpLogo(
      tester,
      locale: const Locale('ar'),
      theme: AppTheme.dark,
    );
    expect(assetName(tester), 'assets/images/logo-full-ar-dark.png');
  });
}
