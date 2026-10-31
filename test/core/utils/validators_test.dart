import 'package:dukavo_mobile/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.required', () {
    test('rejects null, empty and whitespace-only values', () {
      expect(Validators.required(null), isNotNull);
      expect(Validators.required(''), isNotNull);
      expect(Validators.required('   '), isNotNull);
    });

    test('accepts a non-empty value', () {
      expect(Validators.required('Dukavo'), isNull);
    });
  });

  group('Validators.email', () {
    test('accepts a valid address', () {
      expect(Validators.email('owner@dukavo.com'), isNull);
      expect(Validators.email('  owner@dukavo.com  '), isNull);
    });

    test('rejects a missing or malformed address', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email('owner'), isNotNull);
      expect(Validators.email('owner@dukavo'), isNotNull);
      expect(Validators.email('owner @dukavo.com'), isNotNull);
    });
  });

  group('Validators.minLength', () {
    test('returns an error below the minimum', () {
      final validator = Validators.minLength(8);
      expect(validator('short'), isNotNull);
      expect(validator(null), isNotNull);
    });

    test('accepts the minimum and longer values', () {
      final validator = Validators.minLength(8);
      expect(validator('12345678'), isNull);
      expect(validator('a much longer password'), isNull);
    });
  });

  group('Validators.number', () {
    test('accepts integers, decimals and blanks', () {
      expect(Validators.number('12'), isNull);
      expect(Validators.number('12.5'), isNull);
      expect(Validators.number('  '), isNull);
      expect(Validators.number(null), isNull);
    });

    test('rejects non-numeric input', () {
      expect(Validators.number('twelve'), isNotNull);
    });
  });
}
