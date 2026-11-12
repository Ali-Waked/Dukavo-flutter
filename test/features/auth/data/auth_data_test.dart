import 'package:dukavo_mobile/features/auth/data/auth_data.dart';
import 'package:dukavo_mobile/features/auth/domain/auth_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the signed-in person display currency from /me', () {
    final model = AuthUserModel.fromJson(const {
      'id': 3,
      'name': 'Sara Hassan',
      'email': 'sara@dukavo.com',
      'status': 'active',
      'preferred_currency': 'jpy',
      'preferred_currency_name': 'Japanese yen',
      'preferred_currency_symbol': '¥',
      'preferred_currency_decimals': 0,
      'is_platform_user': true,
    });

    expect(model.preferredCurrency, 'jpy');
    expect(model.preferredCurrencyName, 'Japanese yen');
    expect(model.preferredCurrencyDecimals, 0);
    expect(model.isPlatformUser, isTrue);

    final user = model.toEntity();
    expect(user.preferredCurrency, 'jpy');
    expect(user.preferredCurrencySymbol, '¥');
  });

  test('defaults the preference when /me omits it', () {
    final model = AuthUserModel.fromJson(const {
      'id': 3,
      'name': 'Sara Hassan',
      'email': 'sara@dukavo.com',
    });

    expect(model.preferredCurrency, 'USD');
    expect(model.preferredCurrencyDecimals, 2);
    expect(model.isPlatformUser, isFalse);
  });

  test('parses the onboarding marker and the two-factor flag from /me', () {
    final model = AuthUserModel.fromJson(const {
      'id': 3,
      'name': 'Sara Hassan',
      'email': 'sara@dukavo.com',
      'preferences_initialized_at': '2026-11-10T08:00:00+00:00',
      'two_factor_enabled': true,
    });

    expect(model.preferencesInitializedAt, '2026-11-10T08:00:00+00:00');
    expect(model.twoFactorEnabled, isTrue);
    expect(model.toEntity().needsOnboarding, isFalse);
  });

  test('a challenge is not a session and carries no token', () {
    const challenge = TwoFactorChallenge(
      challengeToken: 'opaque-challenge',
      expiresAt: '2026-11-10T08:05:00+00:00',
    );
    const outcome = LoginOutcome.challenge(challenge);

    expect(outcome.requiresTwoFactor, isTrue);
    expect(outcome.session, isNull);
    expect(outcome.challenge?.challengeToken, 'opaque-challenge');
    expect(outcome.challenge?.methods, ['totp', 'recovery_code']);
  });
}
