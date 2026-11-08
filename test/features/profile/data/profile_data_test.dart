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
}
