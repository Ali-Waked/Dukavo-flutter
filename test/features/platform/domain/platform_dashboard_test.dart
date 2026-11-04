import 'package:dukavo_mobile/features/platform/domain/platform_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlatformDashboard.growth', () {
    test('returns the percentage change against the previous window', () {
      const metric = PlatformMetric(total: 30, newCount: 12, previousNew: 10);

      expect(PlatformDashboard.growth(metric), 20);
    });

    test('stays null when the previous window had no rows', () {
      const metric = PlatformMetric(total: 3, newCount: 3, previousNew: 0);

      expect(PlatformDashboard.growth(metric), isNull);
    });

    test('stays null when either count is unavailable', () {
      expect(
        PlatformDashboard.growth(const PlatformMetric(total: 3)),
        isNull,
      );
      expect(
        PlatformDashboard.growth(
          const PlatformMetric(total: 3, newCount: 1),
        ),
        isNull,
      );
    });

    test('reports a decline as a negative percentage', () {
      const metric = PlatformMetric(total: 8, newCount: 4, previousNew: 10);

      expect(PlatformDashboard.growth(metric), -60);
    });
  });

  group('PlatformMetric', () {
    test('exposes status counters with a zero fallback', () {
      const metric = PlatformMetric(
        total: 10,
        extra: {'active': 7, 'suspended': 3},
      );

      expect(metric.extraValue('active'), 7);
      expect(metric.extraValue('missing'), 0);
    });
  });

  group('PlatformDashboard.statusFor', () {
    test('returns the matching list and an empty list for unknown keys', () {
      const dashboard = PlatformDashboard(
        rangeKey: '30d',
        bucket: 'day',
        from: '2026-01-01',
        until: '2026-01-31',
        tenants: PlatformMetric(total: 4),
        users: PlatformMetric(total: 9),
        waitlist: PlatformMetric(total: 2),
        contactMessages: PlatformMetric(total: 1),
        newsletterSubscribers: PlatformMetric(total: 5),
        plans: PlatformMetric(total: 3),
        series: [],
        status: {
          'tenants': [
            PlatformStatusCount(value: 'active', count: 3),
            PlatformStatusCount(value: 'suspended', count: 1),
          ],
        },
      );

      expect(dashboard.statusFor('tenants'), hasLength(2));
      expect(dashboard.statusFor('tenants').first.value, 'active');
      expect(dashboard.statusFor('users'), isEmpty);
    });
  });
}
