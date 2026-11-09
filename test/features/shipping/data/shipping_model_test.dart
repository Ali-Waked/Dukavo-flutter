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

    test('keeps both languages without changing the fee', () {
      final zone = ShippingZoneModel.fromJson(const {
        'id': 7,
        'name': 'Cairo delivery',
        'description': 'Orders inside Cairo.',
        'method_name': 'Standard delivery',
        'method_description': 'Delivered in two working days.',
        'delivery_instructions': 'Call on arrival.',
        'terms': 'Free above the threshold.',
        'translations': {
          'ar': {
            'name': 'توصيل القاهرة',
            'description': 'طلبات داخل القاهرة.',
            'method_name': 'التوصيل العادي',
            'method_description': 'يتم التسليم خلال يومي عمل.',
            'delivery_instructions': 'اتصل عند الوصول.',
            'terms': 'التوصيل مجاني فوق الحد المحدد.',
          },
        },
        'fee': 15,
        'free_shipping_threshold': 75,
      }).toEntity();

      expect(zone.name, 'Cairo delivery');
      expect(zone.methodName, 'Standard delivery');
      expect(zone.arabicCopy.name, 'توصيل القاهرة');
      expect(zone.arabicCopy.methodName, 'التوصيل العادي');
      expect(zone.arabicCopy.deliveryInstructions, 'اتصل عند الوصول.');
      expect(zone.fee, 15);
      expect(zone.freeShippingThreshold, 75);
    });

    test('reads the Arabic aliases when no translations document is present',
        () {
      final zone = ShippingZoneModel.fromJson(const {
        'name': 'Alexandria delivery',
        'name_ar': 'توصيل الإسكندرية',
        'delivery_instructions_ar': 'اتصل قبل التسليم.',
      }).toEntity();

      expect(zone.arabicCopy.name, 'توصيل الإسكندرية');
      expect(zone.arabicCopy.deliveryInstructions, 'اتصل قبل التسليم.');
      expect(zone.arabicCopy.methodName, isNull);
    });

    test('an English-only zone keeps an empty Arabic copy', () {
      final zone = ShippingZoneModel.fromJson(const {
        'name': 'Legacy zone',
        'fee': 7,
      }).toEntity();

      expect(zone.arabicCopy.isEmpty, isTrue);
      expect(zone.fee, 7);
    });
  });
}
