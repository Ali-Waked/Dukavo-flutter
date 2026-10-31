import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The only place a Sanctum bearer token is written.
///
/// The token is also cached in memory so [ApiClient] can attach it to a
/// request without an async read on every call. The cache is hydrated once at
/// startup by [init].
class SecureTokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'dukavo.access_token';

  final FlutterSecureStorage _storage;
  String? _cachedToken;

  String? get token => _cachedToken;

  Future<void> init() async {
    _cachedToken = await _storage.read(key: _tokenKey);
  }

  Future<void> save(String token) async {
    _cachedToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> clear() async {
    _cachedToken = null;
    await _storage.delete(key: _tokenKey);
  }
}
