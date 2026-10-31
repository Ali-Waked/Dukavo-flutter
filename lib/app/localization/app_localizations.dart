import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// ARB-backed localisation without code generation.
///
/// The two ARB files are the single source of truth for copy. They are bundled
/// as assets and loaded once during bootstrap, so a build works with or without
/// `flutter gen-l10n` and no generated file has to be committed.
class AppLocalizations {
  AppLocalizations(this.locale, Map<String, String> values)
      : _values = Map<String, String>.unmodifiable(values);

  final Locale locale;
  final Map<String, String> _values;

  static const supportedLocales = <Locale>[Locale('en'), Locale('ar')];
  static const fallbackLocale = Locale('en');

  static final Map<String, AppLocalizations> _cache =
      <String, AppLocalizations>{};

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static Future<void> preload() async {
    for (final locale in supportedLocales) {
      _cache[locale.languageCode] = await _load(locale);
    }
  }

  static Future<AppLocalizations> _load(Locale locale) async {
    final code = locale.languageCode == 'ar' ? 'ar' : 'en';
    final raw = await rootBundle
        .loadString('lib/app/localization/l10n/app_$code.arb');
    final decoded = jsonDecode(raw);
    final values = <String, String>{};
    if (decoded is Map) {
      decoded.forEach((key, value) {
        if (key is String && !key.startsWith('@') && value is String) {
          values[key] = value;
        }
      });
    }
    return AppLocalizations(Locale(code), values);
  }

  static AppLocalizations of(BuildContext context) {
    final localizations =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    return localizations ?? forLocale(Localizations.localeOf(context));
  }

  static AppLocalizations forLocale(Locale locale) {
    final cached = _cache[locale.languageCode];
    if (cached != null) return cached;
    return _cache[fallbackLocale.languageCode] ??
        AppLocalizations(fallbackLocale, const <String, String>{});
  }

  /// A deterministic instance for widget tests and previews.
  @visibleForTesting
  static AppLocalizations fromMap(
    Map<String, String> values, {
    Locale locale = fallbackLocale,
  }) {
    return AppLocalizations(locale, values);
  }

  /// Translate [key], substituting `{name}` placeholders from [args].
  ///
  /// A missing key returns the key itself. That is deliberate: a visible key in
  /// a screenshot is a better failure than an empty button.
  String t(String key, {Map<String, Object?>? args}) {
    var value = _values[key] ?? key;
    if (args != null && args.isNotEmpty) {
      args.forEach((name, replacement) {
        value = value.replaceAll('{$name}', '${replacement ?? ''}');
      });
    }
    return value;
  }

  bool get isArabic => locale.languageCode == 'ar';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supported) => supported.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(
      AppLocalizations.forLocale(locale),
    );
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String tr(String key, {Map<String, Object?>? args}) =>
      l10n.t(key, args: args);
}
