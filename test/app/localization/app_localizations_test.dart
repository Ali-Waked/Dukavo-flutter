import 'dart:convert';
import 'dart:io';

import 'package:dukavo_mobile/app/localization/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLocalizations.t', () {
    final l10n = AppLocalizations.fromMap(const {
      'welcomeBack': 'Welcome back',
      'itemsCount': '{count} items',
      'mixed': 'Hello {name}, you have {count} orders',
    });

    test('returns the translated string for a known key', () {
      expect(l10n.t('welcomeBack'), 'Welcome back');
    });

    test('returns the key itself when a translation is missing', () {
      expect(l10n.t('missingKey'), 'missingKey');
    });

    test('substitutes a single placeholder', () {
      expect(l10n.t('itemsCount', args: {'count': 3}), '3 items');
    });

    test('substitutes every placeholder', () {
      expect(
        l10n.t('mixed', args: {'name': 'Sara', 'count': 2}),
        'Hello Sara, you have 2 orders',
      );
    });

    test('renders a null placeholder as an empty string', () {
      expect(l10n.t('itemsCount', args: {'count': null}), ' items');
    });

    test('knows whether it is Arabic', () {
      expect(l10n.isArabic, isFalse);
      expect(
        AppLocalizations.fromMap(const {}, locale: const Locale('ar')).isArabic,
        isTrue,
      );
    });
  });

  group('ARB catalog', () {
    Map<String, dynamic> load(String language) {
      final file = File('lib/app/localization/l10n/app_$language.arb');
      return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    }

    test('English and Arabic declare the same keys', () {
      final en = load('en');
      final ar = load('ar');

      expect(ar.keys.toSet(), en.keys.toSet());
    });

    test('every translated value is non-empty', () {
      for (final language in ['en', 'ar']) {
        final catalog = load(language);
        catalog.forEach((key, value) {
          if (key.startsWith('@')) return;
          expect(
            (value as String).trim(),
            isNotEmpty,
            reason: '$language/$key is empty',
          );
        });
      }
    });

    test('new storefront, marketing and platform keys are present', () {
      final en = load('en');
      for (final key in [
        'addToCart',
        'cartEmpty',
        'checkout',
        'placeOrder',
        'trackOrder',
        'subscribeToNewsletter',
        'joinWaitlist',
        'platformOverview',
        'recoverySummary',
        'inventoryIntelligence',
        'teamMembers',
      ]) {
        expect(en.containsKey(key), isTrue, reason: 'missing $key');
      }
    });
  });
}
