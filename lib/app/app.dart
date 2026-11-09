import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/notifications/application/push_lifecycle.dart';
import 'localization/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/design_tokens.dart';
import 'theme/theme_controller.dart';

/// The root widget: theme, language and router, all driven by persisted state.
class DukavoApp extends ConsumerWidget {
  const DukavoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Owning the push lifecycle here keeps it alive for the whole app session
    // without making every screen think about Firebase.
    ref.watch(pushLifecycleProvider);

    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      title: 'Dukavo',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      themeAnimationDuration: AppDurations.normal,
      themeAnimationCurve: Curves.easeOutCubic,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Respect the user's font size but stop extreme settings from breaking
        // dense layouts such as the KPI grid and the message composer.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
