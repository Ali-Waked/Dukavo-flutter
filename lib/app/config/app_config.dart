/// Compile-time configuration for the Dukavo API.
///
/// The base URL can be overridden without editing source:
///
///   flutter run --dart-define=DUKAVO_API_BASE_URL=https://api.dukavo.com/api/v1
///
/// The default points at the deployed Dukavo backend. Local development can
/// still override it with the emulator or LAN address.
class AppConfig {
  const AppConfig._();

  /// The one place to change the API origin for release builds.
  static const String defaultApiBaseUrl =
      'https://dukavo-backend.ethiodeploy.app/api/v1';

  static const String _override = String.fromEnvironment(
    'DUKAVO_API_BASE_URL',
    defaultValue: '',
  );

  /// `.../api/v1`, matching `routes/api.php` in the backend.
  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    return defaultApiBaseUrl;
  }

  /// Sanctum's cookie endpoint lives at the application root, not under `/api`.
  static String get csrfCookieUrl {
    final uri = Uri.parse(apiBaseUrl);
    return uri.replace(path: '/sanctum/csrf-cookie', query: null).toString();
  }

  /// Public shop base, shown to merchants as the link they can share.
  ///
  /// In development the Vue app and the API share an origin, so stripping the
  /// API path is correct. A deployment that serves them from different hosts
  /// should set `DUKAVO_WEB_BASE_URL`.
  static const String _webOverride = String.fromEnvironment(
    'DUKAVO_WEB_BASE_URL',
    defaultValue: '',
  );

  static String get webBaseUrl {
    if (_webOverride.isNotEmpty) {
      return _webOverride.replaceAll(RegExp(r'/+$'), '');
    }
    final uri = Uri.parse(apiBaseUrl);
    return uri.replace(path: '', query: null, fragment: null).toString();
  }

  static String shopUrl(
      {required String tenantSlug, required String storeSlug}) {
    return '$webBaseUrl/shop/$tenantSlug/$storeSlug';
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String appVersion = '1.0.0';
  static const String privacyUrl = 'https://dukavo.com/privacy';
  static const String termsUrl = 'https://dukavo.com/terms';
}
