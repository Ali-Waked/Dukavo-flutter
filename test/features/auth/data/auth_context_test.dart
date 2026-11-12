import 'package:dio/dio.dart';
import 'package:dukavo_mobile/core/api/api_client.dart';
import 'package:dukavo_mobile/core/offline/cache_manager.dart';
import 'package:dukavo_mobile/core/offline/connectivity.dart';
import 'package:dukavo_mobile/core/storage/app_preferences.dart';
import 'package:dukavo_mobile/features/auth/data/auth_data.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../core/offline/support.dart';

/// The context resolution contract the app depends on:
///
/// * a platform operator starts at platform level, even when the account also
///   belongs to merchant workspaces;
/// * a merchant is placed inside a workspace;
/// * switching context only changes the tenant header, never the token.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('sign-in context', () {
    test('a platform-only operator lands in platform mode', () async {
      final adapter = _adapter(
        me: (_) => _sessionJson(operator: true),
      );
      final harness = await _harness(adapter);

      final outcome = await harness.repository.login(
        email: 'sara@dukavo.com',
        password: 'secret',
      );
      final session = outcome.session!;

      expect(session.canUsePlatform, isTrue);
      expect(session.isPlatformOnly, isTrue);
      expect(session.isPlatformMode, isTrue);
      expect(session.activeTenant, isNull);
      expect(harness.preferences.tenantSlug, isNull);
      expect(harness.tokens.token, 'token-1');
    });

    test('a platform operator with memberships is not dropped into one',
        () async {
      final headers = <String?>[];
      final adapter = _adapter(
        me: (_) => _sessionJson(
          operator: true,
          tenantSlugs: const <String>['alpha', 'beta'],
        ),
        headers: headers,
      );
      final harness = await _harness(adapter);

      final outcome = await harness.repository.login(
        email: 'sara@dukavo.com',
        password: 'secret',
      );
      final session = outcome.session!;

      // The regression: auto-activating tenants.first hid the platform console.
      expect(session.activeTenant, isNull);
      expect(session.tenants, hasLength(2));
      expect(session.isPlatformMode, isTrue);
      expect(harness.preferences.tenantSlug, isNull);
      expect(headers, <String?>[null],
          reason: 'the operator session is resolved without a tenant header');
    });

    test('a merchant with one membership is placed inside it', () async {
      final adapter = _adapter(
        me: (header) => header == null
            ? _sessionJson(tenantSlugs: const <String>['alpha'])
            : _sessionJson(
                tenantSlugs: const <String>['alpha'],
                activeSlug: header,
              ),
      );
      final harness = await _harness(adapter);

      final outcome = await harness.repository.login(
        email: 'sara@dukavo.com',
        password: 'secret',
      );
      final session = outcome.session!;

      expect(session.canUsePlatform, isFalse);
      expect(session.activeTenant?.slug, 'alpha');
      expect(session.isPlatformMode, isFalse);
      expect(harness.preferences.tenantSlug, 'alpha');
    });

    test('a merchant with several memberships activates the first active one',
        () async {
      final adapter = _adapter(
        me: (header) => header == null
            ? _sessionJson(tenantSlugs: const <String>['alpha', 'beta'])
            : _sessionJson(
                tenantSlugs: const <String>['alpha', 'beta'],
                activeSlug: header,
              ),
      );
      final harness = await _harness(adapter);

      final session = (await harness.repository.login(
        email: 'sara@dukavo.com',
        password: 'secret',
      ))
          .session!;

      expect(session.activeTenant?.slug, 'alpha');
      expect(harness.preferences.tenantSlug, 'alpha');
    });

    test('an account without a workspace gets no platform capability',
        () async {
      final adapter = _adapter(me: (_) => _sessionJson());
      final harness = await _harness(adapter);

      final session = (await harness.repository.login(
        email: 'sara@dukavo.com',
        password: 'secret',
      ))
          .session!;

      expect(session.canUsePlatform, isFalse);
      expect(session.isPlatformOnly, isFalse);
      expect(session.hasMerchantAccess, isFalse);
      expect(session.isPlatformMode, isFalse);
      expect(session.activeTenant, isNull);
    });
  });

  group('context switching', () {
    test('moves a dual-capability account between platform and merchant mode',
        () async {
      final adapter = _adapter(
        me: (header) {
          if (header == null) {
            return _sessionJson(
              operator: true,
              tenantSlugs: const <String>['alpha', 'beta'],
            );
          }
          return _sessionJson(
            operator: true,
            tenantSlugs: const <String>['alpha', 'beta'],
            activeSlug: header,
          );
        },
      );
      final harness = await _harness(adapter, storedSlug: 'alpha');

      final restored = await harness.repository.restoreSession();
      expect(restored?.activeTenant?.slug, 'alpha');
      expect(restored?.isPlatformMode, isFalse);

      final platform = await harness.repository.enterPlatformMode();
      expect(platform.activeTenant, isNull);
      expect(platform.isPlatformMode, isTrue);
      expect(harness.preferences.tenantSlug, isNull);
      expect(harness.tokens.token, 'token-1',
          reason: 'a context switch never discards the bearer token');

      final merchant = await harness.repository.switchTenant('beta');
      expect(merchant.activeTenant?.slug, 'beta');
      expect(merchant.isPlatformMode, isFalse);
      expect(harness.preferences.tenantSlug, 'beta');
      expect(harness.tokens.token, 'token-1');
    });

    test('a refused switch keeps the previous workspace context', () async {
      final adapter = FakeHttpAdapter((options) async {
        final tenant = _tenantHeader(options);
        if (tenant == null) throw networkFailure(options);
        return jsonBody(<String, dynamic>{
          'data': _sessionJson(
            operator: true,
            tenantSlugs: const <String>['alpha'],
            activeSlug: tenant,
          ),
        });
      });
      final harness = await _harness(adapter, storedSlug: 'alpha');

      final restored = await harness.repository.restoreSession();
      expect(restored?.activeTenant?.slug, 'alpha');

      await expectLater(
        harness.repository.enterPlatformMode(),
        throwsA(isA<Exception>()),
      );

      // The UI stayed in merchant mode, so the persisted marker and the header
      // must still point at the workspace the user is looking at.
      expect(harness.preferences.tenantSlug, 'alpha');
      expect(harness.api.tenantSlug, 'alpha');
      expect(harness.tokens.token, 'token-1');
    });
  });

  group('session restoration', () {
    test('restores platform mode when no workspace was saved', () async {
      final adapter = _adapter(
        me: (_) => _sessionJson(
          operator: true,
          tenantSlugs: const <String>['alpha'],
        ),
      );
      final harness = await _harness(adapter);

      final session = await harness.repository.restoreSession();

      expect(session?.activeTenant, isNull);
      expect(session?.isPlatformMode, isTrue);
      expect(harness.preferences.tenantSlug, isNull);
    });

    test('restores the saved merchant workspace', () async {
      final adapter = _adapter(
        me: (header) => _sessionJson(
          operator: true,
          tenantSlugs: const <String>['alpha', 'beta'],
          activeSlug: header,
        ),
      );
      final harness = await _harness(adapter, storedSlug: 'beta');

      final session = await harness.repository.restoreSession();

      expect(session?.activeTenant?.slug, 'beta');
      expect(session?.isPlatformMode, isFalse);
      expect(harness.preferences.tenantSlug, 'beta');
    });

    test('keeps the cached platform context when the network is unreachable',
        () async {
      final cache = CacheManager(memoryStore());
      await cache.saveSession(
        _sessionJson(operator: true, tenantSlugs: const <String>['alpha']),
      );
      final preferences = await testPreferences();
      final tokens = FakeTokenStore('token-1');
      final connectivity = ConnectivityController()..reportNetworkFailure();
      final adapter = FakeHttpAdapter((options) async {
        throw networkFailure(options);
      });
      final api = await buildTestApi(
        adapter: adapter,
        cache: cache,
        connectivity: connectivity,
        tokens: tokens,
        preferences: preferences,
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
      expect(session!.isPlatformMode, isTrue);
      expect(session.activeTenant, isNull);
      expect(adapter.calls, 0);
    });

    test('an expired token clears the stored context instead of guessing',
        () async {
      final cache = CacheManager(memoryStore());
      await cache.saveSession(
        _sessionJson(operator: true, tenantSlugs: const <String>['alpha']),
      );
      final preferences = await testPreferences();
      await preferences.setTenantSlug('alpha');
      final tokens = FakeTokenStore('expired-token');
      final adapter = FakeHttpAdapter(
        (options) async => jsonBody(
          <String, dynamic>{'message': 'Unauthenticated.'},
          statusCode: 401,
        ),
      );
      final api = await buildTestApi(
        adapter: adapter,
        cache: cache,
        tokens: tokens,
        preferences: preferences,
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
      expect(preferences.tenantSlug, isNull);
      expect(await cache.readSession(), isNull);
    });
  });
}

/* ------------------------------------------------------------------ helpers */

class _Harness {
  _Harness(this.repository, this.preferences, this.tokens, this.api);

  final AuthRepositoryImpl repository;
  final AppPreferences preferences;
  final FakeTokenStore tokens;
  final ApiClient api;
}

Future<_Harness> _harness(
  FakeHttpAdapter adapter, {
  String? storedSlug,
  String? token = 'token-1',
}) async {
  final cache = CacheManager(memoryStore());
  final preferences = await testPreferences();
  if (storedSlug != null) await preferences.setTenantSlug(storedSlug);
  final tokens = FakeTokenStore(token);
  final connectivity = ConnectivityController()..reportSuccess();
  final api = await buildTestApi(
    adapter: adapter,
    cache: cache,
    connectivity: connectivity,
    tokens: tokens,
    preferences: preferences,
  );
  final repository = AuthRepositoryImpl(
    remote: AuthRemoteDataSource(api),
    tokenStore: tokens,
    preferences: preferences,
    apiClient: api,
    cache: cache,
  );
  return _Harness(repository, preferences, tokens, api);
}

FakeHttpAdapter _adapter({
  required Map<String, dynamic> Function(String? tenant) me,
  List<String?>? headers,
}) {
  return FakeHttpAdapter((options) async {
    if (options.path.contains('/auth/login')) {
      return jsonBody(<String, dynamic>{
        'data': <String, dynamic>{
          'token': 'token-1',
          'token_type': 'Bearer',
        },
      });
    }
    if (options.path.endsWith('/me')) {
      final tenant = _tenantHeader(options);
      headers?.add(tenant);
      return jsonBody(<String, dynamic>{'data': me(tenant)});
    }
    return jsonBody(<String, dynamic>{'data': <String, dynamic>{}});
  });
}

String? _tenantHeader(RequestOptions options) {
  for (final entry in options.headers.entries) {
    if (entry.key.toLowerCase() == 'x-tenant') {
      return entry.value?.toString();
    }
  }
  return null;
}

Map<String, dynamic> _sessionJson({
  bool operator = false,
  List<String> tenantSlugs = const <String>[],
  String? activeSlug,
}) {
  final tenants = <Map<String, dynamic>>[
    for (var index = 0; index < tenantSlugs.length; index++)
      <String, dynamic>{
        'id': index + 1,
        'name': _title(tenantSlugs[index]),
        'slug': tenantSlugs[index],
        'status': 'active',
        'currency': 'USD',
        'timezone': 'UTC',
        'is_active': true,
      },
  ];

  Map<String, dynamic>? activeTenant;
  if (activeSlug != null) {
    for (final tenant in tenants) {
      if (tenant['slug'] == activeSlug) {
        activeTenant = tenant;
        break;
      }
    }
  }

  return <String, dynamic>{
    'user': <String, dynamic>{
      'id': 1,
      'name': 'Sara Hassan',
      'email': 'sara@dukavo.com',
      'status': 'active',
      'is_platform_user': operator,
      'is_platform_operator': operator,
    },
    'active_tenant': activeTenant,
    'tenants': tenants,
    'roles': <dynamic>[],
    'permissions': <String>[],
    'permission_catalogue': <String, dynamic>{},
  };
}

String _title(String slug) {
  if (slug.isEmpty) return slug;
  return '${slug[0].toUpperCase()}${slug.substring(1)}';
}
