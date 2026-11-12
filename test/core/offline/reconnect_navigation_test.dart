import 'package:dukavo_mobile/app/localization/app_localizations.dart';
import 'package:dukavo_mobile/app/router/app_router.dart';
import 'package:dukavo_mobile/app/theme/app_theme.dart';
import 'package:dukavo_mobile/core/offline/cache_manager.dart';
import 'package:dukavo_mobile/core/offline/connectivity.dart';
import 'package:dukavo_mobile/core/offline/offline_banner.dart';
import 'package:dukavo_mobile/core/providers.dart';
import 'package:dukavo_mobile/features/auth/application/auth_controller.dart';
import 'package:dukavo_mobile/features/auth/domain/auth_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/test_app.dart';
import 'support.dart';

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
    permissions: <String>['dashboard.view', 'products.view'],
    permissionCatalogue: <String, List<String>>{},
  );
}

void main() {
  setUpAll(preloadLocalizations);

  testWidgets('reconnecting never moves the merchant off their screen',
      (tester) async {
    final controller = _TestAuthController()
      ..emit(
        AuthState(status: AuthStatus.authenticated, session: _session()),
      );
    final connectivity = ConnectivityController();
    addTearDown(connectivity.dispose);
    final adapter = FakeHttpAdapter((options) async {
      return jsonBody(<String, dynamic>{
        'data': <dynamic>[],
        'meta': <String, dynamic>{
          'current_page': 1,
          'last_page': 1,
          'total': 0,
          'per_page': 20,
        },
      });
    });
    final api = await buildTestApi(
      adapter: adapter,
      cache: CacheManager(memoryStore()),
      connectivity: connectivity,
    );

    final container = ProviderContainer(
      overrides: <Override>[
        authControllerProvider.overrideWith((ref) => controller),
        connectivityProvider.overrideWithValue(connectivity),
        apiClientProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);

    late GoRouter router;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, child) {
            router = ref.watch(appRouterProvider);
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
              builder: (context, child) => OfflineBannerHost(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );

    router.go('/products');
    await tester.pumpAndSettle();
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/products',
    );

    connectivity.reportNetworkFailure();
    await tester.pump();
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/products',
    );

    connectivity.reportSuccess();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/products',
    );
  });
}
