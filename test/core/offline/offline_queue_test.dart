import 'package:dukavo_mobile/core/api/api_exception.dart';
import 'package:dukavo_mobile/core/offline/cache_scope.dart';
import 'package:dukavo_mobile/core/offline/offline_queue.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OfflineSafety', () {
    test('allows only idempotent read-state mutations', () {
      expect(
        OfflineSafety.isSafe('POST', '/notifications/read-all'),
        isTrue,
      );
      expect(
        OfflineSafety.isSafe('POST', '/notifications/abc/read'),
        isTrue,
      );
      expect(
        OfflineSafety.isSafe('POST', '/tenant/conversations/12/read'),
        isTrue,
      );

      expect(
        OfflineSafety.isSafe('POST', '/tenant/orders'),
        isFalse,
        reason: 'orders move money and stock',
      );
      expect(
        OfflineSafety.isSafe('PATCH', '/tenant/inventory/adjust'),
        isFalse,
      );
      expect(
        OfflineSafety.isSafe('POST', '/tenant/stores/1/payments'),
        isFalse,
      );
      expect(
        OfflineSafety.isSafe('DELETE', '/notifications/abc'),
        isFalse,
      );
    });
  });

  group('OfflineMutationQueue', () {
    test('rejects online-only work', () async {
      final queue = OfflineMutationQueue(memoryStore());
      addTearDown(queue.dispose);
      await queue.load();

      expect(
        () => queue.enqueue(method: 'POST', path: '/tenant/orders'),
        throwsArgumentError,
      );
    });

    test('persists in order and reloads the same account scope', () async {
      var now = DateTime(2026, 1, 1, 12);
      final store = memoryStore();
      final scope = CacheScope.merchant(accountId: 1, tenantSlug: 'shop').key;

      final queue = OfflineMutationQueue(store, clock: () => now);
      addTearDown(queue.dispose);
      queue.setScope(scope);
      await queue.load();

      await queue.enqueue(
        method: 'POST',
        path: '/notifications/read-all',
      );
      now = now.add(const Duration(seconds: 1));
      await queue.enqueue(
        method: 'POST',
        path: '/tenant/conversations/8/read',
      );
      expect(queue.length, 2);

      final reloaded = OfflineMutationQueue(store);
      addTearDown(reloaded.dispose);
      reloaded.setScope(scope);
      await reloaded.load();
      expect(
        reloaded.pending.map((mutation) => mutation.path).toList(),
        <String>[
          '/notifications/read-all',
          '/tenant/conversations/8/read',
        ],
      );
    });

    test('never shows another account queue', () async {
      final store = memoryStore();
      final queue = OfflineMutationQueue(store);
      addTearDown(queue.dispose);
      queue.setScope(
        CacheScope.merchant(accountId: 1, tenantSlug: 'one').key,
      );
      await queue.load();
      await queue.enqueue(
        method: 'POST',
        path: '/notifications/read-all',
      );

      queue.setScope(
        CacheScope.merchant(accountId: 2, tenantSlug: 'two').key,
      );
      await queue.load();
      expect(queue.isEmpty, isTrue);

      queue.setScope(
        CacheScope.merchant(accountId: 1, tenantSlug: 'one').key,
      );
      await queue.load();
      expect(queue.length, 1);
    });

    test('flushes in order and removes successful entries', () async {
      final queue = OfflineMutationQueue(memoryStore());
      addTearDown(queue.dispose);
      await queue.load();
      await queue.enqueue(method: 'POST', path: '/notifications/read-all');
      await queue.enqueue(
        method: 'POST',
        path: '/notifications/abc/read',
      );

      final replayed = <String>[];
      await queue.flush(
        execute: (mutation) async => replayed.add(mutation.path),
        isOnline: () => true,
      );

      expect(replayed, <String>[
        '/notifications/read-all',
        '/notifications/abc/read',
      ]);
      expect(queue.isEmpty, isTrue);
    });

    test('keeps the queue intact when the connection drops', () async {
      final queue = OfflineMutationQueue(memoryStore());
      addTearDown(queue.dispose);
      await queue.load();
      await queue.enqueue(method: 'POST', path: '/notifications/read-all');
      await queue.enqueue(
        method: 'POST',
        path: '/notifications/abc/read',
      );

      var online = true;
      await queue.flush(
        execute: (mutation) async {
          online = false;
          throw ApiException('offline', isNetworkError: true);
        },
        isOnline: () => online,
      );

      expect(queue.length, 2);
      expect(queue.pending.first.attempts, 0);
    });

    test('drops a permanently rejected mutation and records the reason',
        () async {
      final queue = OfflineMutationQueue(memoryStore());
      addTearDown(queue.dispose);
      await queue.load();
      await queue.enqueue(method: 'POST', path: '/notifications/read-all');
      await queue.enqueue(
        method: 'POST',
        path: '/notifications/abc/read',
      );

      var calls = 0;
      await queue.flush(
        execute: (mutation) async {
          calls += 1;
          if (calls == 1) {
            throw ApiException('gone', statusCode: 404);
          }
        },
        isOnline: () => true,
      );

      expect(calls, 2);
      expect(queue.isEmpty, isTrue);
      expect(queue.failures, <String>['gone']);
    });
  });
}
