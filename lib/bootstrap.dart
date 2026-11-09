import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/config/app_config.dart';
import 'app/localization/app_localizations.dart';
import 'core/api/api_client.dart';
import 'core/offline/cache_manager.dart';
import 'core/offline/cache_store.dart';
import 'core/offline/connectivity.dart';
import 'core/offline/memory_cache_store.dart';
import 'core/offline/offline_queue.dart';
import 'core/offline/sqlite_cache_store.dart';
import 'core/providers.dart';
import 'core/storage/app_preferences.dart';
import 'core/storage/secure_token_store.dart';

/// Builds every long-lived dependency once, before the first frame.
///
/// The three core providers throw until they are overridden here, which makes
/// it impossible to construct a second HTTP client or token store by accident.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = AppPreferences(await SharedPreferences.getInstance());
  final tokenStore = SecureTokenStore();
  await tokenStore.init();

  // The ARB files are bundled assets rather than generated classes, so they
  // must be in memory before the first `MaterialApp` frame.
  await AppLocalizations.preload();

  // SQLite keeps cached reads across launches. If the platform cannot open a
  // database (a desktop build without sqflite, for example), the app still
  // works for this session with the in-memory store.
  CacheStore cacheStore = SqliteCacheStore();
  try {
    await cacheStore.open();
  } catch (_) {
    cacheStore = MemoryCacheStore();
    await cacheStore.open();
  }
  final cacheManager = CacheManager(cacheStore);
  await cacheManager.open();
  cacheManager.setLanguage(
    WidgetsBinding.instance.platformDispatcher.locale.languageCode,
  );

  final connectivity = ConnectivityController(
    probe: HttpConnectivityProbe(baseUrl: AppConfig.apiBaseUrl).call,
  );

  final apiClient = ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    csrfUrl: AppConfig.csrfCookieUrl,
    tokenStore: tokenStore,
    preferences: preferences,
    cache: cacheManager,
    connectivity: connectivity,
  );
  apiClient.setTenantSlug(preferences.tenantSlug);

  final offlineQueue = OfflineMutationQueue(cacheStore);
  connectivity.start();

  runApp(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(preferences),
        tokenStoreProvider.overrideWithValue(tokenStore),
        apiClientProvider.overrideWithValue(apiClient),
        cacheStoreProvider.overrideWithValue(cacheStore),
        cacheManagerProvider.overrideWithValue(cacheManager),
        connectivityProvider.overrideWithValue(connectivity),
        offlineQueueProvider.overrideWithValue(offlineQueue),
      ],
      child: const DukavoApp(),
    ),
  );
}
