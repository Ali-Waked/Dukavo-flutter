import 'package:dukavo_mobile/core/api/api_exception.dart';
import 'package:dukavo_mobile/core/offline/cache_manager.dart';
import 'package:dukavo_mobile/core/offline/cache_scope.dart';
import 'package:dukavo_mobile/core/offline/connectivity.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CacheManager', () {
    test('serves a fresh copy with staleness metadata and expires old rows', () async {
      var now = DateTime(2026, 1, 1, 12);
      final cache = CacheManager(memoryStore(), clock: () => now)
        ..setScope(CacheScope.merchant(accountId: 4, tenantSlug: 'acme'));

      await cache.write(
        '/tenant/products',
        <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{'id': 1}
          ]
        },
      );

      final fresh = await cache.read('/tenant/products');
      expect(fresh, isNotNull);
      expect(fresh!.isStale, isFalse);
      expect(fresh.body['data'], isNotEmpty);

      // The catalogue is fresh for five minutes and may be shown for three
      // days while offline.
      now = now.add(const Duration(minutes: 6));
      final stale = await cache.read('/tenant/products');
      expect(stale, isNotNull);
      expect(stale!.isStale, isTrue);

      now = now.add(const Duration(days: 4));
      expect(await cache.read('/tenant/products'), isNull);
    });

    test('never shares merchant data between accounts or tenants', () async {
      final cache = CacheManager(memoryStore());

      cache.setScope(
        CacheScope.merchant(accountId: 1, tenantSlug: 'first'),
      );
      await cache.write('/tenant/orders', <String, dynamic>{
        'data': <dynamic>['first-account'],
      });

      cache.setScope(
        CacheScope.merchant(accountId: 1, tenantSlug: 'second'),
      );
      expect(await cache.read('/tenant/orders'), isNull);

      cache.setScope(
        CacheScope.merchant(accountId: 2, tenantSlug: 'first'),
      );
      expect(await cache.read('/tenant/orders'), isNull);

      cache.setScope(
        CacheScope.merchant(accountId: 1, tenantSlug: 'first'),
      );
      expect(await cache.read('/tenant/orders'), isNotNull);
    });

    test('public content is shared but platform data is operator-scoped',
        () async {
      final cache = CacheManager(memoryStore());

      cache.setScope(CacheScope.merchant(accountId: 9, tenantSlug: 'shop'));
      await cache.write('/public/faq', <String, dynamic>{
        'data': <dynamic>['question'],
      });
      cache.setScope(CacheScope.platform(3));
      expect(await cache.read('/public/faq'), isNotNull);

      await cache.write('/platform/tenants', <String, dynamic>{
        'data': <dynamic>['tenant'],
      });
      cache.setScope(CacheScope.platform(4));
      expect(await cache.read('/platform/tenants'), isNull);
    });

    test('a mutation invalidates its own resource, not the whole scope',
        () async {
      final cache = CacheManager(memoryStore())
        ..setScope(CacheScope.merchant(accountId: 5, tenantSlug: 'shop'));

      await cache.write('/tenant/products', <String, dynamic>{'data': 1});
      await cache.write('/tenant/orders', <String, dynamic>{'data': 2});

      await cache.invalidateMutation(
        'POST',
        '/tenant/products/123/images/reorder',
      );

      expect(await cache.read('/tenant/products'), isNull);
      expect(await cache.read('/tenant/orders'), isNotNull);
    });

    test('saves and clears the raw session snapshot', () async {
      final store = memoryStore();
      final cache = CacheManager(store);

      await cache.saveSession(<String, dynamic>{
        'user': <String, dynamic>{'id': 7, 'name': 'Sara'},
        'permissions': <String>['dashboard.view'],
      });

      final restored = await CacheManager(store).readSession();
      expect(restored, isNotNull);
      expect(restored!['user']['name'], 'Sara');

      await cache.clearSession();
      expect(await cache.readSession(), isNull);
    });
  });

  group('ApiClient offline reads', () {
    test('serves a cached GET without a network call', () async {
      final adapter = FakeHttpAdapter((options) async {
        return jsonBody(<String, dynamic>{
          'data': <String, dynamic>{'name': 'Cached catalogue'},
        });
      });
      final cache = CacheManager(memoryStore())
        ..setScope(CacheScope.merchant(accountId: 1, tenantSlug: 'shop'));
      final connectivity = ConnectivityController();
      final api = await buildTestApi(
        adapter: adapter,
        cache: cache,
        connectivity: connectivity,
      );

      final online = await api.get<Map<String, dynamic>>(
        '/tenant/products',
        decode: (data) => Map<String, dynamic>.from(data! as Map),
      );
      expect(online['name'], 'Cached catalogue');
      expect(adapter.calls, 1);

      connectivity.reportNetworkFailure();
      final offline = await api.get<Map<String, dynamic>>(
        '/tenant/products',
        decode: (data) => Map<String, dynamic>.from(data! as Map),
      );
      expect(offline['name'], 'Cached catalogue');
      expect(adapter.calls, 1);
    });

    test('falls back to the last copy when the network drops mid-session',
        () async {
      var fail = false;
      final adapter = FakeHttpAdapter((options) async {
        if (fail) throw networkFailure(options);
        return jsonBody(<String, dynamic>{
          'data': <String, dynamic>{'name': 'Saved catalogue'},
        });
      });
      final cache = CacheManager(memoryStore())
        ..setScope(CacheScope.merchant(accountId: 1, tenantSlug: 'shop'));
      final connectivity = ConnectivityController();
      final api = await buildTestApi(
        adapter: adapter,
        cache: cache,
        connectivity: connectivity,
      );

      await api.get<Map<String, dynamic>>(
        '/tenant/products',
        decode: (data) => Map<String, dynamic>.from(data! as Map),
      );

      fail = true;
      final fallback = await api.get<Map<String, dynamic>>(
        '/tenant/products',
        decode: (data) => Map<String, dynamic>.from(data! as Map),
      );
      expect(fallback['name'], 'Saved catalogue');
      expect(connectivity.isOffline, isTrue);
    });

    test('reports a clear offline error when nothing was saved', () async {
      final adapter = FakeHttpAdapter((options) async {
        throw networkFailure(options);
      });
      final connectivity = ConnectivityController()
        ..reportNetworkFailure();
      final api = await buildTestApi(
        adapter: adapter,
        cache: CacheManager(memoryStore()),
        connectivity: connectivity,
      );

      await expectLater(
        api.get<Map<String, dynamic>>('/tenant/orders'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.isOffline, 'offline', isTrue)
              .having((error) => error.isNetworkError, 'network', isTrue),
        ),
      );
      expect(adapter.calls, 0);
    });

    test('blocks online-only mutations while offline', () async {
      final adapter = FakeHttpAdapter((options) async {
        return jsonBody(<String, dynamic>{'data': <String, dynamic>{}});
      });
      final connectivity = ConnectivityController()
        ..reportNetworkFailure();
      final api = await buildTestApi(
        adapter: adapter,
        cache: CacheManager(memoryStore()),
        connectivity: connectivity,
      );

      await expectLater(
        api.post<Map<String, dynamic>>(
          '/tenant/orders',
          body: <String, dynamic>{'customer_id': 1},
          decode: (data) => <String, dynamic>{},
        ),
        throwsA(
          isA<ApiException>().having(
            (error) => error.isOffline,
            'offline',
            isTrue,
          ),
        ),
      );
      expect(adapter.calls, 0);
    });

    test('replayMutation bypasses the offline guard', () async {
      final adapter = FakeHttpAdapter((options) async {
        return jsonBody(<String, dynamic>{'data': <String, dynamic>{}});
      });
      final connectivity = ConnectivityController()
        ..reportNetworkFailure();
      final api = await buildTestApi(
        adapter: adapter,
        cache: CacheManager(memoryStore()),
        connectivity: connectivity,
      );

      await api.replayMutation('POST', '/notifications/read-all');
      expect(adapter.calls, 1);
    });
  });
}
