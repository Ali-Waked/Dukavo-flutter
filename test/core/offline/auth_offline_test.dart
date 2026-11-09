import 'package:dukavo_mobile/core/offline/cache_manager.dart';
import 'package:dukavo_mobile/core/offline/cache_scope.dart';
import 'package:dukavo_mobile/core/offline/connectivity.dart';
import 'package:dukavo_mobile/features/auth/data/auth_data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

Map<String, dynamic> _sessionJson({
  int userId = 7,
  String tenantSlug = 'shop',
  bool platform = false,
}) {
  return <String, dynamic>{
    'user': <String, dynamic>{
      'id': userId,
      'name': 'Sara',
      'email': 'sara@dukavo.com',
      'status': 'active',
      'is_platform_user': platform,
    },
    'active_tenant': <String, dynamic>{
      'id': 1,
      'name': 'Shop',
      'slug': tenantSlug,
      'status': 'active',
      'currency': 'USD',
      'timezone': 'UTC',
      'is_active': true,
    },
    'tenants': <dynamic>[
      <String, dynamic>{
        'id': 1,
        'name': 'Shop',
        'slug': tenantSlug,
        'status': 'active',
        'currency': 'USD',
        'timezone': 'UTC',
        'is_active': true,
      }
    ],
    'roles': <dynamic>[],
    'permissions': <String>['dashboard.view', 'products.view'],
    'permission_catalogue': <String, dynamic>{},
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('restores a cached session while the network is unreachable', () async {
    final store = memoryStore();
    final cache = CacheManager(store);
    await cache.saveSession(_sessionJson());

    final preferences = await testPreferences();
    await preferences.setTenantSlug('shop');
    final tokens = FakeTokenStore('remembered-token');
    final connectivity = ConnectivityController()..reportNetworkFailure();
    final adapter = FakeHttpAdapter((options) async {
      throw networkFailure(options);
    });
    final api = await buildTestApi(
      adapter: adapter,
      cache: cache,
      connectivity: connectivity,
    );
    final repository = AuthRepositoryImpl(
      remote: AuthRemoteDataSource(api),
      tokenStore: tokens,
      preferences: preferences,
      apiClient: api,
      cache: cache,
    );

    final session = await repository.restoreSession();

    expect(session, isNotNull);
    expect(session!.user.id, 7);
    expect(session.activeTenant?.slug, 'shop');
    expect(session.permissionSet.canViewProducts, isTrue);
    expect(adapter.calls, 0, reason: 'offline startup never waits for HTTP');
    expect(
      cache.scope,
      CacheScope.merchant(accountId: 7, tenantSlug: 'shop'),
    );
  });

  test('saves the session and scopes cache after a successful restore',
      () async {
    final store = memoryStore();
    final cache = CacheManager(store);
    final preferences = await testPreferences();
    await preferences.setTenantSlug('shop');
    final tokens = FakeTokenStore('token');
    final connectivity = ConnectivityController()..reportSuccess();
    final adapter = FakeHttpAdapter((options) async {
      return jsonBody(<String, dynamic>{'data': _sessionJson()});
    });
    final api = await buildTestApi(
      adapter: adapter,
      cache: cache,
      connectivity: connectivity,
    );
    final repository = AuthRepositoryImpl(
      remote: AuthRemoteDataSource(api),
      tokenStore: tokens,
      preferences: preferences,
      apiClient: api,
      cache: cache,
    );

    final session = await repository.restoreSession();

    expect(session, isNotNull);
    expect(await cache.readSession(), isNotNull);
    expect(
      cache.scope,
      CacheScope.merchant(accountId: 7, tenantSlug: 'shop'),
    );
  });

  test('a 401 clears the token, session snapshot and scoped cache', () async {
    final store = memoryStore();
    final cache = CacheManager(store)
      ..setScope(CacheScope.merchant(accountId: 7, tenantSlug: 'shop'));
    await cache.saveSession(_sessionJson());
    await cache.write('/tenant/products', <String, dynamic>{'data': 1});

    final preferences = await testPreferences();
    await preferences.setTenantSlug('shop');
    final tokens = FakeTokenStore('expired-token');
    final connectivity = ConnectivityController()..reportSuccess();
    final adapter = FakeHttpAdapter((options) async {
      return jsonBody(
        <String, dynamic>{'message': 'Unauthenticated.'},
        statusCode: 401,
      );
    });
    final api = await buildTestApi(
      adapter: adapter,
      cache: cache,
      connectivity: connectivity,
    );
    final repository = AuthRepositoryImpl(
      remote: AuthRemoteDataSource(api),
      tokenStore: tokens,
      preferences: preferences,
      apiClient: api,
      cache: cache,
    );

    final session = await repository.restoreSession();

    expect(session, isNull);
    expect(tokens.token, isNull);
    expect(await cache.readSession(), isNull);
    expect(cache.scope, CacheScope.public);
    expect(await cache.read('/tenant/products'), isNull);
  });
}
