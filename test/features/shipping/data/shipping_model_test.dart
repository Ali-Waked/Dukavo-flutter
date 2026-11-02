import 'package:dukavo_mobile/features/shipping/data/shipping_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShippingZoneModel.fromJson', () {
    test('parses numeric strings, areas and the free-delivery threshold', () {
      final zone = ShippingZoneModel.fromJson(const {
        'id': 3,
        'name': 'Cairo delivery',
        'city': 'Cairo',
        'areas': ['zamalek', 'maadi'],
        'fee': '15.50',
        'free_shipping_threshold': '75.00',
        'is_active': true,
        'sort_order': 2,
        'created_at': '2024-02-01T09:00:00Z',
      }).toEntity();

      expect(zone.id, 3);
      expect(zone.name, 'Cairo delivery');
      expect(zone.city, 'Cairo');
      expect(zone.areas, ['zamalek', 'maadi']);
      expect(zone.fee, 15.5);
      expect(zone.freeShippingThreshold, 75);
      expect(zone.isActive, isTrue);
      expect(zone.sortOrder, 2);
      expect(zone.coverage, 'Cairo · zamalek · maadi');
    });

    test('applies safe defaults for a minimal payload', () {
      final zone = ShippingZoneModel.fromJson(const {}).toEntity();

      expect(zone.id, 0);
      expect(zone.name, '');
      expect(zone.city, isNull);
      expect(zone.areas, isEmpty);
      expect(zone.fee, 0);
      expect(zone.freeShippingThreshold, isNull);
      expect(zone.isActive, isTrue);
      expect(zone.coverage, '');
    });

    test('ignores malformed areas', () {
      final zone = ShippingZoneModel.fromJson(const {
        'areas': 'not-a-list',
      }).toEntity();

      expect(zone.areas, isEmpty);
    });
  });
}
