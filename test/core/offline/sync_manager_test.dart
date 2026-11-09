import 'dart:async';

import 'package:dukavo_mobile/core/offline/cache_manager.dart';
import 'package:dukavo_mobile/core/offline/cache_scope.dart';
import 'package:dukavo_mobile/core/offline/connectivity.dart';
import 'package:dukavo_mobile/core/offline/offline_queue.dart';
import 'package:dukavo_mobile/core/offline/sync_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reconnecting flushes the safe queue and publishes one refresh epoch',
      () async {
    final store = memoryStore();
    final connectivity = ConnectivityController()..reportNetworkFailure();
    addTearDown(connectivity.dispose);

    final adapter = FakeHttpAdapter((options) async {
      return jsonBody(<String, dynamic>{'data': <String, dynamic>{}});
    });
    final cache = CacheManager(store);
    final api = await buildTestApi(
      adapter: adapter,
      cache: cache,
      connectivity: connectivity,
    );

    final queue = OfflineMutationQueue(store);
    addTearDown(queue.dispose);
    queue.setScope(
      CacheScope.merchant(accountId: 1, tenantSlug: 'shop').key,
    );
    await queue.load();
    await queue.enqueue(
      method: 'POST',
      path: '/notifications/read-all',
    );

    final sync = SyncManager(
      connectivity: connectivity,
      queue: queue,
      api: api,
      reconnectDelay: Duration.zero,
    );
    addTearDown(sync.dispose);
    sync.start();
    expect(sync.epoch, 0);

    final synced = Completer<void>();
    sync.addListener(() {
      if (sync.epoch == 1 && !synced.isCompleted) synced.complete();
    });

    connectivity.reportSuccess();

    // The reconnect handler schedules the flush asynchronously.
    await synced.future.timeout(const Duration(seconds: 5));

    expect(adapter.calls, 1);
    expect(queue.isEmpty, isTrue);
    expect(sync.epoch, 1);
    expect(sync.lastSyncedAt, isNotNull);
    expect(sync.isSyncing, isFalse);
  });

  test('a refresh-only sync still advances the epoch', () async {
    final connectivity = ConnectivityController()..reportSuccess();
    addTearDown(connectivity.dispose);
    final adapter = FakeHttpAdapter((options) async {
      return jsonBody(<String, dynamic>{'data': <String, dynamic>{}});
    });
    final api = await buildTestApi(
      adapter: adapter,
      cache: CacheManager(memoryStore()),
      connectivity: connectivity,
    );
    final queue = OfflineMutationQueue(memoryStore());
    addTearDown(queue.dispose);
    final sync = SyncManager(
      connectivity: connectivity,
      queue: queue,
      api: api,
    );
    addTearDown(sync.dispose);

    await sync.syncNow(flushQueue: false);

    expect(sync.epoch, 1);
    expect(adapter.calls, 0);
  });
}
