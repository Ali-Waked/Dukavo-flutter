import 'package:dukavo_mobile/features/analytics/domain/analytics_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsQuery', () {
    test('two queries with the same fields are equal', () {
      const a = AnalyticsQuery(
        from: '2024-01-01',
        until: '2024-01-31',
        storeId: 2,
        currency: 'AED',
        productLimit: 5,
      );
      const b = AnalyticsQuery(
        from: '2024-01-01',
        until: '2024-01-31',
        storeId: 2,
        currency: 'AED',
        productLimit: 5,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('a different range is not equal', () {
      const a = AnalyticsQuery(from: '2024-01-01', until: '2024-01-31');
      const b = AnalyticsQuery(from: '2024-02-01', until: '2024-02-29');

      expect(a, isNot(b));
    });

    test('a different store or currency is not equal', () {
      const base = AnalyticsQuery(storeId: 1, currency: 'USD');

      expect(base, isNot(const AnalyticsQuery(storeId: 2, currency: 'USD')));
      expect(base, isNot(const AnalyticsQuery(storeId: 1, currency: 'AED')));
    });

    test('defaults to a ten-product limit', () {
      expect(const AnalyticsQuery().productLimit, 10);
    });
  });

  group('AnalyticsKpi', () {
    test('recognises currency KPIs', () {
      const kpi = AnalyticsKpi(
        key: 'revenue',
        label: 'Revenue',
        value: 1000,
        unit: 'currency',
      );

      expect(kpi.isCurrency, isTrue);
    });

    test('treats a percentage or count KPI as non-currency', () {
      const kpi = AnalyticsKpi(
        key: 'orders',
        label: 'Orders',
        value: 12,
        unit: 'count',
      );

      expect(kpi.isCurrency, isFalse);
      expect(kpi.direction, 'flat');
      expect(kpi.definition, '');
    });
  });
}
