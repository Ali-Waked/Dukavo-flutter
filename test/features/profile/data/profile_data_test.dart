import 'package:dukavo_mobile/features/profile/data/profile_data.dart';
import 'package:dukavo_mobile/features/profile/domain/profile_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the profile display currency', () {
    final profile = ProfileModel.fromJson(const {
      'id': 7,
      'name': 'Sara Hassan',
      'email': 'sara@dukavo.com',
      'status': 'active',
      'preferred_currency': 'KWD',
      'preferred_currency_name': 'دينار كويتي',
      'preferred_currency_symbol': 'د.ك',
      'preferred_currency_decimals': 3,
    });

    expect(profile.preferredCurrency, 'KWD');
    expect(profile.preferredCurrencyName, 'دينار كويتي');
    expect(profile.preferredCurrencyDecimals, 3);
  });

  test('defaults to USD when the server omits the preference', () {
    final profile = ProfileModel.fromJson(const {
      'id': 7,
      'name': 'Sara Hassan',
      'email': 'sara@dukavo.com',
    });

    expect(profile.preferredCurrency, 'USD');
    expect(profile.preferredCurrencyDecimals, 2);
  });

  test('sends only the fields being changed', () {
    const draft = ProfileUpdateDraft(preferredCurrency: 'JPY');

    expect(draft.toJson(), {'preferred_currency': 'JPY'});
  });

  test('parses the location, display and security blocks', () {
    final profile = ProfileModel.fromJson(const {
      'id': 7,
      'name': 'Sara Hassan',
      'email': 'sara@dukavo.com',
      'status': 'active',
      'bio': 'Builds things.',
      'city': 'Dubai',
      'timezone': 'Asia/Dubai',
      'preferences_initialized_at': '2026-11-10T08:00:00+00:00',
      'location': {
        'country_code': 'AE',
        'city': 'Dubai',
        'timezone': 'Asia/Dubai',
        'country': {
          'iso2': 'AE',
          'name': 'الإمارات العربية المتحدة',
          'name_en': 'United Arab Emirates',
          'name_ar': 'الإمارات العربية المتحدة',
          'native': 'دولة الإمارات العربية المتحدة',
          'dial_code': '971',
          'currency': 'AED',
          'flag': '🇦🇪',
        },
      },
      'display': {
        'theme': 'dark',
        'date_format': 'YYYY-MM-DD',
        'time_format': '12h',
      },
      'two_factor': {
        'enabled': true,
        'pending': false,
        'confirmed_at': '2026-11-09T12:00:00+00:00',
        'recovery_codes_count': 6,
      },
      'profile_completion': {
        'percentage': 80,
        'completed': ['name', 'email'],
        'missing': ['phone'],
      },
    });

    expect(profile.bio, 'Builds things.');
    expect(profile.city, 'Dubai');
    expect(profile.timezone, 'Asia/Dubai');
    expect(profile.theme, 'dark');
    expect(profile.dateFormat, 'YYYY-MM-DD');
    expect(profile.timeFormat, '12h');
    expect(profile.country?.iso2, 'AE');
    expect(profile.country?.dialCode, '971');
    expect(profile.needsOnboarding, isFalse);
    expect(profile.twoFactor.enabled, isTrue);
    expect(profile.twoFactor.recoveryCodesCount, 6);
    expect(profile.completion.percentage, 80);
    expect(profile.completion.missing, ['phone']);
  });

  test('treats a missing initialisation timestamp as onboarding pending', () {
    final profile = ProfileModel.fromJson(const {
      'id': 7,
      'name': 'Sara Hassan',
      'email': 'sara@dukavo.com',
    });

    expect(profile.needsOnboarding, isTrue);
    expect(profile.country, isNull);
  });
}
