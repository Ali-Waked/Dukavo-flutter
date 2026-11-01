import 'package:dukavo_mobile/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatters.currency', () {
    test('formats a USD amount with the requested locale', () {
      expect(
        Formatters.currency(1234.5, 'USD', locale: 'en_US'),
        r'$1,234.50',
      );
    });

    test('normalises a lower-case currency code', () {
      expect(
        Formatters.currency(10, 'usd', locale: 'en_US'),
        r'$10.00',
      );
    });

    test('falls back to USD when the code is empty', () {
      expect(Formatters.currency(0, '', locale: 'en_US'), r'$0.00');
    });

    test('supports compact notation', () {
      final compact = Formatters.currency(
        1200000,
        'USD',
        locale: 'en_US',
        compact: true,
      );
      expect(compact, contains(r'$'));
      expect(compact, isNot(contains('1,200,000')));
    });
  });

  group('Formatters.number', () {
    test('groups thousands', () {
      expect(Formatters.number(1234.5, locale: 'en_US'), '1,234.5');
    });

    test('formats whole numbers without a decimal part', () {
      expect(Formatters.number(42, locale: 'en_US'), '42');
    });
  });

  group('Formatters.percent', () {
    test('honours the requested precision', () {
      expect(
        Formatters.percent(12.345, locale: 'en_US', decimals: 1),
        '12.3%',
      );
    });

    test('formats zero decimals', () {
      expect(Formatters.percent(99.6, locale: 'en_US', decimals: 0), '100%');
    });
  });

  group('Formatters dates', () {
    test('returns an em dash for missing or invalid input', () {
      expect(Formatters.date(null), '—');
      expect(Formatters.date(''), '—');
      expect(Formatters.date('not-a-date'), '—');
      expect(Formatters.dateTime('not-a-date'), '—');
      expect(Formatters.time(null), '—');
      expect(Formatters.relative(null), '—');
    });

    test('formats an ISO timestamp', () {
      expect(
        Formatters.date('2024-01-15T10:30:00Z', locale: 'en_US'),
        'Jan 15, 2024',
      );
    });
  });

  group('Formatters.relative', () {
    test('describes recent moments compactly', () {
      final fiveMinutesAgo = DateTime.now()
          .subtract(const Duration(minutes: 5))
          .toUtc()
          .toIso8601String();
      expect(Formatters.relative(fiveMinutesAgo), '5m');

      final twoHoursAgo = DateTime.now()
          .subtract(const Duration(hours: 2))
          .toUtc()
          .toIso8601String();
      expect(Formatters.relative(twoHoursAgo), '2h');
    });

    test('falls back to an absolute date for older timestamps', () {
      final old = DateTime.utc(2024, 1, 15, 10, 30).toIso8601String();
      expect(
        Formatters.relative(old, locale: 'en_US'),
        Formatters.date(old, locale: 'en_US'),
      );
    });
  });

  group('Formatters.initials', () {
    test('uses the first and last name', () {
      expect(Formatters.initials('Ada Lovelace'), 'AL');
    });

    test('uses a single letter for one name', () {
      expect(Formatters.initials('Dukavo'), 'D');
    });

    test('collapses whitespace', () {
      expect(Formatters.initials('  Ada   Byron   Lovelace  '), 'AL');
    });

    test('handles an empty name', () {
      expect(Formatters.initials('   '), '?');
    });
  });
}
