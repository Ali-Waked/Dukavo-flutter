import 'package:dukavo_mobile/app/localization/app_localizations.dart';
import 'package:dukavo_mobile/app/router/app_router.dart';
import 'package:dukavo_mobile/app/theme/app_theme.dart';
import 'package:dukavo_mobile/core/providers.dart';
import 'package:dukavo_mobile/core/storage/app_preferences.dart';
import 'package:dukavo_mobile/core/widgets/app_widgets.dart';
import 'package:dukavo_mobile/features/auth/application/auth_controller.dart';
import 'package:dukavo_mobile/features/auth/domain/auth_domain.dart';
import 'package:dukavo_mobile/features/auth/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/test_app.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Session?> restoreSession() async => null;

  @override
  Future<LoginOutcome> login(
      {required String email, required String password}) {
    throw UnimplementedError('The splash never signs a user in.');
  }

  @override
  Future<Session> completeTwoFactor({
    required String challengeToken,
    String? code,
    String? recoveryCode,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<void> clearLocalSession() async {}

  @override
  Future<void> resendVerificationEmail() async {}

  @override
  Future<Session> switchTenant(String slug) {
    throw UnimplementedError();
  }

  @override
  Future<Session> enterPlatformMode() {
    throw UnimplementedError();
  }

  @override
  Future<Session> provisionTenant({
    required String name,
    String? storeName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {}
}

class _TestAuthController extends AuthController {
  _TestAuthController() : super(_FakeAuthRepository(), autoBootstrap: false);

  void emit(AuthState next) => state = next;
}

const _destinations = <String, String>{
  '/home': 'destination-home',
  '/setup': 'destination-setup',
  '/dashboard': 'destination-dashboard',
  '/orders': 'destination-orders',
  '/products': 'destination-products',
  '/conversations': 'destination-conversations',
  '/more': 'destination-more',
  '/platform/dashboard': 'destination-platform',
};

Session _session(
    {List<String> permissions = const <String>['dashboard.view']}) {
  return Session(
    user: const AuthUser(
      id: 1,
      name: 'Owner',
      email: 'owner@dukavo.com',
      status: 'active',
    ),
    activeTenant: const ActiveTenant(
      id: 1,
      name: 'Dukavo',
      slug: 'dukavo',
      status: 'active',
      currency: 'USD',
      timezone: 'UTC',
    ),
    tenants: const <TenantMembership>[],
    roles: const <TenantRoles>[],
    permissions: permissions,
    permissionCatalogue: const <String, List<String>>{},
  );
}

GoRouter _buildRouter({required bool reduceMotion}) {
  return GoRouter(
    initialLocation: '/splash',
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        builder: (context, state) =>
            DukavoSplashScreen(reduceMotion: reduceMotion),
      ),
      for (final entry in _destinations.entries)
        GoRoute(
          path: entry.key,
          builder: (context, state) => Scaffold(
            body: Center(child: Text(entry.value)),
          ),
        ),
    ],
  );
}

/// Advances the test clock in realistic frame-sized steps.
///
/// `AnimationController` starts a new phase on the tick *after* the previous
/// one completes, so a single huge `pump` would make the test measure the
/// pumping strategy instead of the storyboard.
Future<void> _advance(WidgetTester tester, Duration duration) async {
  const frame = Duration(milliseconds: 50);
  var remaining = duration;
  while (remaining > Duration.zero) {
    final step = remaining < frame ? remaining : frame;
    await tester.pump(step);
    remaining -= step;
  }
}

Future<void> _pumpSplash(
  WidgetTester tester, {
  required _TestAuthController controller,
  AuthState state = const AuthState(status: AuthStatus.unauthenticated),
  Locale locale = const Locale('en'),
  Brightness brightness = Brightness.light,
  bool reduceMotion = false,
}) async {
  controller.emit(state);
  final router = _buildRouter(reduceMotion: reduceMotion);
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        authControllerProvider.overrideWith((ref) => controller),
      ],
      child: MaterialApp.router(
        theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();
}

void main() {
  late _TestAuthController controller;

  setUpAll(preloadLocalizations);

  setUp(() {
    controller = _TestAuthController();
  });

  testWidgets('keeps the full storyboard before opening the public home',
      (tester) async {
    await _pumpSplash(tester, controller: controller);

    await _advance(tester, const Duration(milliseconds: 2400));
    expect(find.byType(DukavoSplashScreen), findsOneWidget);
    expect(find.text('destination-home'), findsNothing);
    expect(find.text('Your Business. Connected.'), findsOneWidget);

    // Just before the 3-second mark the exit is still running.
    await _advance(tester, const Duration(milliseconds: 500));
    expect(find.text('destination-home'), findsNothing);

    await _advance(tester, const Duration(milliseconds: 300));
    // Let the default route transition finish so the splash is truly replaced.
    await tester.pumpAndSettle();
    expect(find.text('destination-home'), findsOneWidget);
    expect(find.byType(DukavoSplashScreen), findsNothing);
  });

  testWidgets('opens a permitted dashboard for an authenticated merchant',
      (tester) async {
    await _pumpSplash(
      tester,
      controller: controller,
      state: AuthState(
        status: AuthStatus.authenticated,
        session: _session(),
      ),
    );

    await _advance(tester, const Duration(milliseconds: 3200));
    await tester.pump();

    expect(find.text('destination-dashboard'), findsOneWidget);
  });

  testWidgets('lands on the first permitted section for a restricted role',
      (tester) async {
    await _pumpSplash(
      tester,
      controller: controller,
      state: AuthState(
        status: AuthStatus.authenticated,
        session: _session(permissions: const <String>['orders.view']),
      ),
    );

    await _advance(tester, const Duration(milliseconds: 3200));
    await tester.pump();

    expect(find.text('destination-orders'), findsOneWidget);
  });

  testWidgets('sends an account without a workspace to onboarding',
      (tester) async {
    await _pumpSplash(
      tester,
      controller: controller,
      state: const AuthState(status: AuthStatus.needsTenant),
    );

    await _advance(tester, const Duration(milliseconds: 3200));
    await tester.pump();

    expect(find.text('destination-setup'), findsOneWidget);
  });

  testWidgets('sends a platform operator to the platform console',
      (tester) async {
    await _pumpSplash(
      tester,
      controller: controller,
      state: const AuthState(status: AuthStatus.platform),
    );

    await _advance(tester, const Duration(milliseconds: 3200));
    await tester.pump();

    expect(find.text('destination-platform'), findsOneWidget);
  });

  testWidgets('shows the Arabic tagline in RTL', (tester) async {
    await _pumpSplash(
      tester,
      controller: controller,
      locale: const Locale('ar'),
      state: AuthState(
        status: AuthStatus.authenticated,
        session: _session(),
      ),
    );

    await _advance(tester, const Duration(milliseconds: 2600));

    final tagline = find.byKey(const ValueKey('splash-tagline'));
    expect(tagline, findsOneWidget);
    expect(
      tester.widget<Text>(tagline).data,
      'كل تجارتك في مكان واحد',
    );
    expect(Directionality.of(tester.element(tagline)), TextDirection.rtl);
  });

  testWidgets('renders in the light theme', (tester) async {
    await _pumpSplash(tester, controller: controller);

    await _advance(tester, const Duration(milliseconds: 900));

    final context = tester.element(find.byType(DukavoSplashScreen));
    expect(Theme.of(context).brightness, Brightness.light);
    expect(find.byType(AppLogo), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in the dark theme', (tester) async {
    await _pumpSplash(
      tester,
      controller: controller,
      brightness: Brightness.dark,
      state: AuthState(
        status: AuthStatus.authenticated,
        session: _session(),
      ),
    );

    await _advance(tester, const Duration(milliseconds: 900));

    final context = tester.element(find.byType(DukavoSplashScreen));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.byType(AppLogo), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('honours the reduced-motion preference', (tester) async {
    await _pumpSplash(tester, controller: controller, reduceMotion: true);

    await tester.pumpAndSettle();

    expect(find.text('destination-home'), findsOneWidget);
  });

  testWidgets('holds the finished frame while auth is still resolving',
      (tester) async {
    await _pumpSplash(
      tester,
      controller: controller,
      state: const AuthState(status: AuthStatus.unknown),
    );

    await _advance(tester, const Duration(milliseconds: 3100));

    expect(find.byType(DukavoSplashScreen), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Preparing your workspace…'), findsOneWidget);
    // The finished brand moment is kept; the animation does not restart.
    expect(find.byKey(const ValueKey('splash-tagline')), findsOneWidget);
    expect(find.text('destination-home'), findsNothing);

    controller.emit(
      AuthState(
        status: AuthStatus.authenticated,
        session: _session(),
      ),
    );
    await tester.pump();
    await _advance(tester, const Duration(milliseconds: 600));
    await tester.pump();

    expect(find.text('destination-dashboard'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('completes cleanly on repeated launches', (tester) async {
    await _pumpSplash(tester, controller: controller);
    await _advance(tester, const Duration(milliseconds: 3200));
    await tester.pump();
    expect(find.text('destination-home'), findsOneWidget);

    // Unmount the whole app, then boot a fresh introduction.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    controller = _TestAuthController();
    await _pumpSplash(tester, controller: controller);
    await _advance(tester, const Duration(milliseconds: 3200));
    await tester.pump();

    expect(find.text('destination-home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disposes its controllers when removed mid-animation',
      (tester) async {
    await _pumpSplash(tester, controller: controller);
    await _advance(tester, const Duration(milliseconds: 600));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('the real app router does not redirect away from the splash',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = AppPreferences(await SharedPreferences.getInstance());
    final container = ProviderContainer(
      overrides: <Override>[
        appPreferencesProvider.overrideWithValue(preferences),
        authControllerProvider.overrideWith((ref) => controller),
      ],
    );
    addTearDown(container.dispose);

    controller.emit(const AuthState(status: AuthStatus.unauthenticated));
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();

    await _advance(tester, const Duration(milliseconds: 1200));

    // A signed-out session must not bounce the brand animation to login.
    expect(find.byType(DukavoSplashScreen), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
  });
}
