import 'package:dukavo_mobile/app/localization/app_localizations.dart';
import 'package:dukavo_mobile/app/router/app_router.dart';
import 'package:dukavo_mobile/app/router/auth_destination.dart';
import 'package:dukavo_mobile/app/router/route_paths.dart';
import 'package:dukavo_mobile/app/theme/app_theme.dart';
import 'package:dukavo_mobile/core/auth/permissions.dart';
import 'package:dukavo_mobile/core/providers.dart';
import 'package:dukavo_mobile/core/storage/app_preferences.dart';
import 'package:dukavo_mobile/features/auth/application/auth_controller.dart';
import 'package:dukavo_mobile/features/auth/domain/auth_domain.dart';
import 'package:dukavo_mobile/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_app.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.session});

  final Session? session;

  @override
  Future<Session?> restoreSession() async => null;

  @override
  Future<LoginOutcome> login(
      {required String email, required String password}) async {
    final result = session;
    if (result == null) throw UnimplementedError('No session configured.');
    return LoginOutcome.session(result);
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
  Future<Session> switchTenant(String slug) => throw UnimplementedError();

  @override
  Future<Session> enterPlatformMode() async {
    final result = session;
    if (result == null) throw UnimplementedError('No session configured.');
    return result;
  }

  @override
  Future<Session> provisionTenant({
    required String name,
    String? storeName,
  }) =>
      throw UnimplementedError();

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
  _TestAuthController(super.repository) : super(autoBootstrap: false) {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

Session _session() {
  return const Session(
    user: AuthUser(
      id: 1,
      name: 'Owner',
      email: 'owner@dukavo.com',
      status: 'active',
    ),
    activeTenant: ActiveTenant(
      id: 1,
      name: 'Dukavo',
      slug: 'dukavo',
      status: 'active',
      currency: 'USD',
      timezone: 'UTC',
    ),
    tenants: <TenantMembership>[],
    roles: <TenantRoles>[],
    permissions: <String>[PermissionSlugs.ordersView],
    permissionCatalogue: <String, List<String>>{},
  );
}

void main() {
  late AppPreferences preferences;

  setUpAll(() async {
    await preloadLocalizations();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = AppPreferences(await SharedPreferences.getInstance());
  });

  testWidgets('a protected path sends a signed-out visitor to login',
      (tester) async {
    final controller = _TestAuthController(_FakeAuthRepository());
    final container = ProviderContainer(
      overrides: [
        appPreferencesProvider.overrideWithValue(preferences),
        authControllerProvider.overrideWith((ref) => controller),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, child) {
            final router = ref.watch(appRouterProvider);
            return MaterialApp.router(
              routerConfig: router,
              theme: AppTheme.light,
              locale: const Locale('en'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            );
          },
        ),
      ),
    );

    final router = container.read(appRouterProvider);
    router.go(RoutePaths.orders);
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.queryParameters['redirect'],
      RoutePaths.orders,
    );
  });

  testWidgets('a signed-in user returns to the intended destination',
      (tester) async {
    final controller = _TestAuthController(
      _FakeAuthRepository(session: _session()),
    );
    final router = GoRouter(
      initialLocation:
          '${RoutePaths.login}?redirect=${Uri.encodeComponent(RoutePaths.orders)}',
      routes: [
        GoRoute(
          path: RoutePaths.login,
          builder: (context, state) => LoginScreen(
            redirect: sanitizeRedirect(state.uri.queryParameters['redirect']),
          ),
        ),
        GoRoute(
          path: RoutePaths.orders,
          builder: (context, state) =>
              const Scaffold(body: Text('Orders destination')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWithValue(preferences),
          authControllerProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light,
          locale: const Locale('en'),
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
      find.byType(TextFormField).first,
      'owner@dukavo.com',
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      'correct-horse-battery',
    );
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Orders destination'), findsOneWidget);
  });

  testWidgets('the login screen can return to the public site', (tester) async {
    final controller = _TestAuthController(_FakeAuthRepository());
    final router = GoRouter(
      initialLocation: RoutePaths.login,
      routes: [
        GoRoute(
          path: RoutePaths.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RoutePaths.home,
          builder: (context, state) =>
              const Scaffold(body: Text('Public home')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWithValue(preferences),
          authControllerProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light,
          locale: const Locale('en'),
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

    await tester.tap(find.text('Back to site'));
    await tester.pumpAndSettle();

    expect(find.text('Public home'), findsOneWidget);
  });
}
