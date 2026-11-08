import 'package:dukavo_mobile/core/currency/currency_catalogue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyOption', () {
    test('parses localized metadata and precision', () {
      final currency = CurrencyOption.fromJson(const {
        'code': 'kwd',
        'name': 'دينار كويتي',
        'name_en': 'Kuwaiti dinar',
        'name_ar': 'دينار كويتي',
        'symbol': 'د.ك',
        'symbol_en': 'KWD',
        'symbol_ar': 'د.ك',
        'decimals': 3,
      });

      expect(currency.code, 'KWD');
      expect(currency.name, 'دينار كويتي');
      expect(currency.nameEn, 'Kuwaiti dinar');
      expect(currency.decimals, 3);
      expect(currency.label, 'KWD · دينار كويتي');
    });

    test('searches code, names and symbols in either language', () {
      const currency = CurrencyOption(
        code: 'KWD',
        name: 'Kuwaiti dinar',
        nameEn: 'Kuwaiti dinar',
        nameAr: 'دينار كويتي',
        symbol: 'KWD',
        symbolEn: 'KWD',
        symbolAr: 'د.ك',
        decimals: 3,
      );

      expect(currency.matches(''), isTrue);
      expect(currency.matches('kw'), isTrue);
      expect(currency.matches('kuwait'), isTrue);
      expect(currency.matches('دينار'), isTrue);
      expect(currency.matches('د.ك'), isTrue);
      expect(currency.matches('euro'), isFalse);
    });

    test('falls back to the code when the server has no name', () {
      final currency = CurrencyOption.fromJson(const {'code': 'XYZ'});

      expect(currency.name, 'XYZ');
      expect(currency.label, 'XYZ');
      expect(currency.decimals, 2);
    });
  });

  group('CurrencyCatalogue', () {
    test('parses the server payload and finds a code', () {
      final catalogue = CurrencyCatalogue.fromJson(const {
        'default': 'usd',
        'locale': 'ar',
        'currencies': [
          {'code': 'USD', 'name': 'دولار أمريكي', 'decimals': 2},
          {'code': 'KWD', 'name': 'دينار كويتي', 'decimals': 3},
        ],
      });

      expect(catalogue.defaultCode, 'USD');
      expect(catalogue.locale, 'ar');
      expect(catalogue.currencies, hasLength(2));
      expect(catalogue.find('kwd')?.decimals, 3);
      expect(catalogue.find('EUR'), isNull);
    });

    test('ignores malformed entries instead of inventing currencies', () {
      final catalogue = CurrencyCatalogue.fromJson(const {
        'currencies': [
          {'name': 'No code'},
          {'code': 'JPY', 'name': 'Japanese yen', 'decimals': 0},
          'not-a-map',
        ],
      });

      expect(catalogue.currencies.single.code, 'JPY');
    });
  });
}
