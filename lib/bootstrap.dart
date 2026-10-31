import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/config/app_config.dart';
import 'app/localization/app_localizations.dart';
import 'core/api/api_client.dart';
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

  final apiClient = ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    csrfUrl: AppConfig.csrfCookieUrl,
    tokenStore: tokenStore,
    preferences: preferences,
  );
  apiClient.setTenantSlug(preferences.tenantSlug);

  runApp(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(preferences),
        tokenStoreProvider.overrideWithValue(tokenStore),
        apiClientProvider.overrideWithValue(apiClient),
      ],
      child: const DukavoApp(),
    ),
  );
}
