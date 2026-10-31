import 'package:flutter/foundation.dart';

/// Compile-time configuration for the Dukavo API.
///
/// The base URL can be overridden without editing source:
///
///   flutter run --dart-define=DUKAVO_API_BASE_URL=https://api.dukavo.com/api/v1
///
/// Defaults are chosen so that a developer running the Laravel backend with
/// `php artisan serve` can launch the app on either simulator immediately.
class AppConfig {
  const AppConfig._();

  static const String _override = String.fromEnvironment(
    'DUKAVO_API_BASE_URL',
    defaultValue: '',
  );

  /// `.../api/v1`, matching `routes/api.php` in the backend.
  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    return 'http://10.0.2.2:8000/api/v1';
  }

  /// Sanctum's cookie endpoint lives at the application root, not under `/api`.
  static String get csrfCookieUrl {
    final uri = Uri.parse(apiBaseUrl);
    return uri.replace(path: '/sanctum/csrf-cookie', query: null).toString();
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String appVersion = '1.0.0';
  static const String privacyUrl = 'https://dukavo.com/privacy';
  static const String termsUrl = 'https://dukavo.com/terms';
}
