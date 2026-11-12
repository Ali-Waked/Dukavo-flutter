import 'package:dukavo_mobile/app/localization/app_localizations.dart';
import 'package:dukavo_mobile/app/router/app_router.dart';
import 'package:dukavo_mobile/app/router/route_paths.dart';
import 'package:dukavo_mobile/app/theme/app_theme.dart';
import 'package:dukavo_mobile/core/api/api_client.dart';
import 'package:dukavo_mobile/core/auth/permissions.dart';
import 'package:dukavo_mobile/core/offline/cache_manager.dart';
import 'package:dukavo_mobile/core/providers.dart';
import 'package:dukavo_mobile/core/storage/app_preferences.dart';
import 'package:dukavo_mobile/features/auth/application/auth_controller.dart';
import 'package:dukavo_mobile/features/auth/domain/auth_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/offline/support.dart';
import '../../helpers/test_app.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Session?> restoreSession() async => null;

  @override
  Future<LoginOutcome> login(
      {required String email, required String password}) {
    throw UnimplementedError();
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
  Future<Session> enterPlatformMode() => throw UnimplementedError();

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
  _TestAuthController(Session? session, AuthStatus status)
      : super(_FakeAuthRepository(), autoBootstrap: false) {
    state = AuthState(status: status, session: session);
  }
}

Session _session({
  bool operator = false,
  bool withTenant = true,
}) {
  const tenant = ActiveTenant(
    id: 1,
    name: 'Dukavo Retail',
    slug: 'dukavo-retail',
    status: 'active',
    currency: 'USD',
    timezone: 'UTC',
  );
  return Session(
    user: AuthUser(
      id: 1,
      name: 'Sara Hassan',
      email: 'sara@dukavo.com',
      status: 'active',
      isPlatformUser: operator,
      isPlatformOperator: operator,
    ),
    activeTenant: withTenant ? tenant : null,
    tenants: const <TenantMembership>[
      TenantMembership(
        id: 1,
        name: 'Dukavo Retail',
        slug: 'dukavo-retail',
        status: 'active',
        currency: 'USD',
        timezone: 'UTC',
      ),
    ],
    roles: const <TenantRoles>[],
    permissions: const <String>[PermissionSlugs.dashboardView],
    permissionCatalogue: const <String, List<String>>{},
  );
}

Future<GoRouter> _pumpApp(
  WidgetTester tester,
  _TestAuthController controller,
  AppPreferences preferences,
  ApiClient api,
) async {
  final container = ProviderContainer(
    overrides: <Override>[
      appPreferencesProvider.overrideWithValue(preferences),
      apiClientProvider.overrideWithValue(api),
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
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
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
  await tester.pump();
  return container.read(appRouterProvider);
}

String _currentPath(GoRouter router) =>
    router.routeInformationProvider.value.uri.path;

void main() {
  late AppPreferences preferences;
  late ApiClient api;

  setUpAll(preloadLocalizations);

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = AppPreferences(await SharedPreferences.getInstance());
    api = await buildTestApi(
      adapter: FakeHttpAdapter(
        (options) async =>
            jsonBody(<String, dynamic>{'data': <String, dynamic>{}}),
      ),
      cache: CacheManager(memoryStore()),
      preferences: preferences,
    );
  });

  testWidgets('a merchant cannot open a platform route', (tester) async {
    final router = await _pumpApp(
      tester,
      _TestAuthController(
        _session(),
        AuthStatus.authenticated,
      ),
      preferences,
      api,
    );

    router.go(RoutePaths.platformDashboard);
    await tester.pump(const Duration(milliseconds: 200));

    expect(_currentPath(router), RoutePaths.noAccess);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('a platform route in merchant context returns to merchant home',
      (tester) async {
    final router = await _pumpApp(
      tester,
      _TestAuthController(
        _session(operator: true),
        AuthStatus.authenticated,
      ),
      preferences,
      api,
    );

    router.go(RoutePaths.platformDashboard);
    await tester.pump(const Duration(milliseconds: 200));

    expect(_currentPath(router), RoutePaths.dashboard);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('platform context leaves a merchant destination for the console',
      (tester) async {
    final router = await _pumpApp(
      tester,
      _TestAuthController(
        _session(operator: true, withTenant: false),
        AuthStatus.platform,
      ),
      preferences,
      api,
    );

    router.go(RoutePaths.dashboard);
    await tester.pump(const Duration(milliseconds: 200));

    expect(_currentPath(router), RoutePaths.platformDashboard);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('a merchant deep link into platform data is refused',
      (tester) async {
    final router = await _pumpApp(
      tester,
      _TestAuthController(
        _session(),
        AuthStatus.authenticated,
      ),
      preferences,
      api,
    );

    router.go(RoutePaths.platformTenants);
    await tester.pump(const Duration(milliseconds: 200));

    expect(_currentPath(router), RoutePaths.noAccess);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('payment history requires the payments grant', (tester) async {
    final router = await _pumpApp(
      tester,
      _TestAuthController(
        _session(),
        AuthStatus.authenticated,
      ),
      preferences,
      api,
    );

    router.go(RoutePaths.paymentConnections);
    await tester.pump(const Duration(milliseconds: 200));

    expect(_currentPath(router), RoutePaths.noAccess);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('the AI copilot requires the ai.use grant', (tester) async {
    final router = await _pumpApp(
      tester,
      _TestAuthController(
        _session(),
        AuthStatus.authenticated,
      ),
      preferences,
      api,
    );

    router.go(RoutePaths.aiCopilot);
    await tester.pump(const Duration(milliseconds: 200));

    expect(_currentPath(router), RoutePaths.noAccess);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('automation templates require the automation grant',
      (tester) async {
    final router = await _pumpApp(
      tester,
      _TestAuthController(
        _session(),
        AuthStatus.authenticated,
      ),
      preferences,
      api,
    );

    router.go(RoutePaths.automationTemplates);
    await tester.pump(const Duration(milliseconds: 200));

    expect(_currentPath(router), RoutePaths.noAccess);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets(
      'a platform operator in merchant context cannot open the AI console',
      (tester) async {
    final router = await _pumpApp(
      tester,
      _TestAuthController(
        _session(operator: true),
        AuthStatus.authenticated,
      ),
      preferences,
      api,
    );

    router.go(RoutePaths.platformAiAdmin);
    await tester.pump(const Duration(milliseconds: 200));

    expect(_currentPath(router), RoutePaths.dashboard);
    await tester.pump(const Duration(milliseconds: 200));
  });
}
