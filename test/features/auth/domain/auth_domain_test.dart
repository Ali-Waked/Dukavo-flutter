import 'package:dukavo_mobile/features/auth/domain/auth_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const user = AuthUser(
    id: 1,
    name: 'Sara Hassan',
    email: 'sara@dukavo.com',
    status: 'active',
  );

  const tenant = ActiveTenant(
    id: 7,
    name: 'Dukavo Retail',
    slug: 'dukavo-retail',
    status: 'active',
    currency: 'AED',
    timezone: 'Asia/Dubai',
  );

  const membership = TenantMembership(
    id: 7,
    name: 'Dukavo Retail',
    slug: 'dukavo-retail',
    status: 'active',
    currency: 'AED',
    timezone: 'Asia/Dubai',
  );

  group('AuthUser', () {
    test('uses the first word as the display name', () {
      expect(user.firstName, 'Sara');
    });

    test('handles a single-word name', () {
      const single = AuthUser(
        id: 2,
        name: 'Dukavo',
        email: 'hi@dukavo.com',
        status: 'active',
      );
      expect(single.firstName, 'Dukavo');
    });
  });

  group('Session', () {
    test('exposes its permissions as a set', () {
      const session = Session(
        user: user,
        tenants: [membership],
        roles: [
          TenantRoles(
            tenantId: 7,
            slug: 'dukavo-retail',
            roles: ['Owner'],
            permissions: ['orders.view', 'orders.create'],
          ),
        ],
        permissions: ['orders.view', 'orders.create'],
        permissionCatalogue: {
          'orders': ['orders.view', 'orders.create'],
        },
        activeTenant: tenant,
      );

      expect(session.permissionSet.can('orders.view'), isTrue);
      expect(session.permissionSet.can('orders.delete'), isFalse);
      expect(session.hasTenant, isTrue);
      expect(session.currency, 'AED');
      expect(session.timezone, 'Asia/Dubai');
    });

    test('finds roles and memberships by slug', () {
      const session = Session(
        user: user,
        tenants: [membership],
        roles: [
          TenantRoles(
            tenantId: 7,
            slug: 'dukavo-retail',
            roles: ['Owner'],
            permissions: [],
          ),
        ],
        permissions: [],
        permissionCatalogue: {},
        activeTenant: tenant,
      );

      expect(session.rolesForSlug('dukavo-retail')?.roles, ['Owner']);
      expect(session.membershipForSlug('dukavo-retail')?.name, 'Dukavo Retail');
      expect(session.rolesForSlug('missing'), isNull);
      expect(session.membershipForSlug('missing'), isNull);
    });

    test('falls back to the first membership without an active tenant', () {
      const session = Session(
        user: user,
        tenants: [membership],
        roles: [],
        permissions: [],
        permissionCatalogue: {},
      );

      expect(session.hasTenant, isFalse);
      expect(session.currency, 'AED');
      expect(session.timezone, 'Asia/Dubai');
    });

    test('falls back to USD and UTC with no memberships', () {
      const session = Session(
        user: user,
        tenants: [],
        roles: [],
        permissions: [],
        permissionCatalogue: {},
      );

      expect(session.currency, 'USD');
      expect(session.timezone, 'UTC');
    });

    test('a platform operator without a workspace is in platform mode', () {
      const operator = AuthUser(
        id: 9,
        name: 'Operator',
        email: 'operator@dukavo.com',
        status: 'active',
        isPlatformUser: true,
        isPlatformOperator: true,
      );
      const session = Session(
        user: operator,
        tenants: [],
        roles: [],
        permissions: [],
        permissionCatalogue: {},
      );

      expect(session.canUsePlatform, isTrue);
      expect(session.isPlatformMode, isTrue);
      expect(session.isPlatformOnly, isTrue);
    });

    test('a platform operator inside a workspace is in merchant mode', () {
      const operator = AuthUser(
        id: 9,
        name: 'Operator',
        email: 'operator@dukavo.com',
        status: 'active',
        isPlatformUser: true,
        isPlatformOperator: true,
      );
      const session = Session(
        user: operator,
        activeTenant: tenant,
        tenants: [membership],
        roles: [],
        permissions: [],
        permissionCatalogue: {},
      );

      expect(session.canUsePlatform, isTrue);
      expect(session.isPlatformMode, isFalse);
      expect(session.isPlatformOnly, isFalse);
    });

    test('a broader platform role never unlocks the operator console', () {
      const platformUser = AuthUser(
        id: 10,
        name: 'Support',
        email: 'support@dukavo.com',
        status: 'active',
        isPlatformUser: true,
      );
      const session = Session(
        user: platformUser,
        tenants: [],
        roles: [],
        permissions: [],
        permissionCatalogue: {},
      );

      // The backend's platform route gate only accepts the operator roles.
      expect(session.isPlatformUser, isTrue);
      expect(session.canUsePlatform, isFalse);
      expect(session.isPlatformMode, isFalse);
    });

    test('a merchant without a workspace has no platform capability', () {
      const session = Session(
        user: user,
        tenants: [],
        roles: [],
        permissions: [],
        permissionCatalogue: {},
      );

      expect(session.canUsePlatform, isFalse);
      expect(session.isPlatformOnly, isFalse);
      expect(session.hasMerchantAccess, isFalse);
      expect(session.isPlatformMode, isFalse);
    });
  });

  group('TenantMembership', () {
    test('converts to the active tenant shape', () {
      final active = membership.toActive();
      expect(active.id, membership.id);
      expect(active.slug, membership.slug);
      expect(active.currency, membership.currency);
      expect(active.isActive, isTrue);
    });
  });
}
