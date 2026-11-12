import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Small, non-sensitive preferences that must be available synchronously.
///
/// Credentials never live here: they belong in [SecureTokenStore]. This class
/// owns only presentation choices (theme, language) and the selected tenant
/// slug, which is also sent as `X-Tenant`.
class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _themeKey = 'dukavo.theme_mode';
  static const _localeKey = 'dukavo.locale';
  static const _tenantKey = 'dukavo.tenant_slug';

  ThemeMode get themeMode {
    switch (_prefs.getString(_themeKey)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) {
    return _prefs.setString(_themeKey, mode.name);
  }

  /// `null` means "follow the device language"; the app then falls back to
  /// English when the device language is not Arabic.
  Locale? get locale {
    final code = _prefs.getString(_localeKey);
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }

  Future<void> setLocale(Locale? locale) {
    if (locale == null) {
      return _prefs.remove(_localeKey);
    }
    return _prefs.setString(_localeKey, locale.languageCode);
  }

  static const _installationKey = 'dukavo.push_installation_id';

  /// A stable random id for this installation, created on first push boot.
  ///
  /// The FCM token rotates, so it cannot identify the phone; this value lets
  /// the backend replace the old token row instead of accumulating duplicates.
  String? get pushInstallationId => _prefs.getString(_installationKey);

  Future<void> setPushInstallationId(String id) {
    return _prefs.setString(_installationKey, id);
  }

  String? get tenantSlug => _prefs.getString(_tenantKey);

  Future<void> setTenantSlug(String? slug) {
    if (slug == null || slug.isEmpty) {
      return _prefs.remove(_tenantKey);
    }
    return _prefs.setString(_tenantKey, slug);
  }

  /// Help articles this account already answered "was this helpful?" for, so
  /// the question is not asked again on a later visit. The server dedupes the
  /// vote itself; this only keeps the widget quiet.
  static const _helpFeedbackKey = 'dukavo.help_feedback_answered';

  bool hasAnsweredHelpFeedback(String slug) =>
      (_prefs.getStringList(_helpFeedbackKey) ?? const <String>[])
          .contains(slug);

  Future<void> markHelpFeedbackAnswered(String slug) {
    final answered = _prefs.getStringList(_helpFeedbackKey) ?? <String>[];
    return _prefs.setStringList(_helpFeedbackKey, [...answered, slug]);
  }
}
