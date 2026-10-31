import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_client.dart';
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
