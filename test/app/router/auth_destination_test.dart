import 'package:dukavo_mobile/app/router/auth_destination.dart';
import 'package:dukavo_mobile/app/router/route_paths.dart';
import 'package:dukavo_mobile/core/auth/permissions.dart';
import 'package:dukavo_mobile/features/auth/application/auth_controller.dart';
import 'package:dukavo_mobile/features/auth/domain/auth_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Session _session({List<String> permissions = const <String>[]}) {
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

void main() {
  group('homePathFor', () {
    test('platform mode always opens the platform console', () {
      expect(
        homePathFor(const Permissions.empty(), platformMode: true),
        RoutePaths.platformDashboard,
      );
    });

    test('prefers the dashboard when the role may view it', () {
      expect(
        homePathFor(
          const Permissions(
              {PermissionSlugs.ordersView, PermissionSlugs.dashboardView}),
        ),
        RoutePaths.dashboard,
      );
    });

    test('falls back to the first permitted section', () {
      expect(
        homePathFor(const Permissions({PermissionSlugs.ordersView})),
        RoutePaths.orders,
      );
      expect(
        homePathFor(const Permissions({PermissionSlugs.productsView})),
        RoutePaths.products,
      );
      expect(
        homePathFor(const Permissions({PermissionSlugs.conversationsView})),
        RoutePaths.conversations,
      );
    });

    test('uses the more tab when nothing else is allowed', () {
      expect(homePathFor(const Permissions.empty()), RoutePaths.more);
    });
  });

  group('splashDestination', () {
    test('keeps waiting while the session is unresolved', () {
      expect(
        splashDestination(const AuthState(status: AuthStatus.unknown)),
        isNull,
      );
    });

    test('sends a signed-out visitor to the public home', () {
      expect(
        splashDestination(
          const AuthState(status: AuthStatus.unauthenticated),
        ),
        RoutePaths.home,
      );
    });

    test('sends an account without a workspace to onboarding', () {
      expect(
        splashDestination(const AuthState(status: AuthStatus.needsTenant)),
        RoutePaths.setup,
      );
    });

    test('sends a platform operator to the platform console', () {
      expect(
        splashDestination(const AuthState(status: AuthStatus.platform)),
        RoutePaths.platformDashboard,
      );
    });

    test('sends an authenticated merchant to a permitted screen', () {
      expect(
        splashDestination(
          AuthState(
            status: AuthStatus.authenticated,
            session: _session(
              permissions: const <String>[PermissionSlugs.dashboardView],
            ),
          ),
        ),
        RoutePaths.dashboard,
      );
      expect(
        splashDestination(
          AuthState(
            status: AuthStatus.authenticated,
            session: _session(
              permissions: const <String>[PermissionSlugs.ordersView],
            ),
          ),
        ),
        RoutePaths.orders,
      );
    });

    test('uses the safe fallback when permissions are empty', () {
      expect(
        splashDestination(
          AuthState(
            status: AuthStatus.authenticated,
            session: _session(),
          ),
        ),
        RoutePaths.more,
      );
      expect(
        splashDestination(
          const AuthState(status: AuthStatus.authenticated),
        ),
        RoutePaths.more,
      );
    });
  });

  group('sanitizeRedirect', () {
    test('keeps same-origin absolute paths with their query', () {
      expect(sanitizeRedirect('/orders/1043'), '/orders/1043');
      expect(
        sanitizeRedirect('/orders?status=pending'),
        '/orders?status=pending',
      );
    });

    test('rejects external, protocol-relative and malformed targets', () {
      expect(sanitizeRedirect(null), isNull);
      expect(sanitizeRedirect(''), isNull);
      expect(sanitizeRedirect('https://evil.example'), isNull);
      expect(sanitizeRedirect('//evil.example/path'), isNull);
      expect(sanitizeRedirect(r'\evil'), isNull);
      expect(sanitizeRedirect('orders'), isNull);
      expect(sanitizeRedirect('/orders\nSet-Cookie: x'), isNull);
      expect(sanitizeRedirect('/orders?x=1'), '/orders?x=1');
      expect(sanitizeRedirect('/orders%00'), isNull);
    });

    test('refuses to bounce back into the auth flow', () {
      expect(sanitizeRedirect(RoutePaths.login), isNull);
      expect(sanitizeRedirect('${RoutePaths.login}?redirect=/orders'), isNull);
      expect(sanitizeRedirect(RoutePaths.register), isNull);
      expect(sanitizeRedirect(RoutePaths.forgotPassword), isNull);
      expect(sanitizeRedirect(RoutePaths.resetPassword), isNull);
      expect(sanitizeRedirect(RoutePaths.splash), isNull);
    });
  });
}
