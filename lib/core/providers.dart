import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_client.dart';
import 'offline/cache_manager.dart';
import 'offline/cache_store.dart';
import 'offline/connectivity.dart';
import 'offline/memory_cache_store.dart';
import 'offline/offline_queue.dart';
import 'offline/sync_manager.dart';
import 'storage/app_preferences.dart';
import 'storage/secure_token_store.dart';

/// These providers are overridden in `bootstrap.dart` with instances built
/// after the async platform channels have answered. Nothing else constructs a
/// client, a token store or a preferences object.
final appPreferencesProvider = Provider<AppPreferences>((ref) {
  throw UnimplementedError('appPreferencesProvider must be overridden.');
});

final tokenStoreProvider = Provider<SecureTokenStore>((ref) {
  throw UnimplementedError('tokenStoreProvider must be overridden.');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('apiClientProvider must be overridden.');
});

/// The storage behind the offline cache. Bootstrap replaces the in-memory
/// default with SQLite once the platform database is open.
final cacheStoreProvider = Provider<CacheStore>((ref) {
  return MemoryCacheStore();
});

final cacheManagerProvider = Provider<CacheManager>((ref) {
  final manager = CacheManager(ref.watch(cacheStoreProvider));
  ref.onDispose(manager.dispose);
  return manager;
});

final connectivityProvider = Provider<ConnectivityController>((ref) {
  final controller = ConnectivityController();
  ref.onDispose(controller.dispose);
  return controller;
});

final offlineQueueProvider = Provider<OfflineMutationQueue>((ref) {
  final queue = OfflineMutationQueue(ref.watch(cacheStoreProvider));
  ref.onDispose(queue.dispose);
  return queue;
});

/// Flushes the safe queue and publishes a refresh epoch after reconnecting.
///
/// Nothing here touches the router, so a restored connection cannot move a
/// merchant away from the screen they were reading.
final syncManagerProvider = Provider<SyncManager>((ref) {
  final manager = SyncManager(
    connectivity: ref.watch(connectivityProvider),
    queue: ref.watch(offlineQueueProvider),
    api: ref.watch(apiClientProvider),
  );
  manager.start();
  ref.onDispose(manager.dispose);
  return manager;
});

/// Increments once per completed reconnect sync.
final syncEpochProvider = Provider<int>((ref) {
  return ref.watch(syncManagerProvider.select((manager) => manager.epoch));
});

/// Ask a list controller to refetch after a reconnect, without invalidating it
/// (which would discard the saved page while the refresh is in flight).
void refreshOnReconnect(
  Ref ref,
  FutureOr<void> Function() refresh,
) {
  ref.listen<int>(syncEpochProvider, (previous, next) {
    if (previous == null || next <= previous) return;
    unawaited(Future<void>.sync(refresh));
  });
}
