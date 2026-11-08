import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/storage/app_preferences.dart';

/// The user's interface language. `null` follows the device language.
class LocaleController extends StateNotifier<Locale?> {
  LocaleController(this._preferences) : super(_preferences.locale);

  final AppPreferences _preferences;

  Future<void> setLocale(Locale? locale) async {
    await _preferences.setLocale(locale);
    state = locale;
  }

  Future<void> toggle() async {
    final current = state?.languageCode ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    await setLocale(Locale(current == 'ar' ? 'en' : 'ar'));
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale?>((ref) {
  return LocaleController(ref.watch(appPreferencesProvider));
});

/// The language the app is actually rendering in.
///
/// [localeControllerProvider] is `null` when the user follows the device. The
/// router and the public API both need a concrete `en`/`ar` code, so resolve the
/// same fallback Flutter uses: Arabic when the device asks for it, English
/// otherwise. Watching this provider also makes API reads language-aware.
final effectiveLocaleProvider = Provider<Locale>((ref) {
  final selected = ref.watch(localeControllerProvider);
  if (selected != null) {
    return Locale(selected.languageCode == 'ar' ? 'ar' : 'en');
  }
  final device = WidgetsBinding.instance.platformDispatcher.locale;
  return Locale(device.languageCode == 'ar' ? 'ar' : 'en');
});

/// Light, dark or system. Persisted in [AppPreferences].
class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController(this._preferences) : super(_preferences.themeMode);

  final AppPreferences _preferences;

  Future<void> setMode(ThemeMode mode) async {
    await _preferences.setThemeMode(mode);
    state = mode;
  }
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController(ref.watch(appPreferencesProvider));
});
