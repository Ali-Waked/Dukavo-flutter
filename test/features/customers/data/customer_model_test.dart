import 'package:dukavo_mobile/features/customers/data/customer_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomerModel.fromJson', () {
    test('parses the customer resource and its aggregates', () {
      final customer = CustomerModel.fromJson(const {
        'id': 9,
        'name': 'Mariam Ali',
        'email': 'mariam@example.com',
        'phone': '+971500000001',
        'status': 'active',
        'locale': 'ar',
        'notes': 'Prefers WhatsApp',
        'orders_count': 4,
        'total_spent': '1250.50',
        'last_order_at': '2024-02-01T09:00:00Z',
        'created_at': '2023-11-01T09:00:00Z',
      }).toEntity();

      expect(customer.id, 9);
      expect(customer.name, 'Mariam Ali');
      expect(customer.status, 'active');
      expect(customer.ordersCount, 4);
      expect(customer.totalSpent, 1250.5);
      expect(customer.lastOrderAt, '2024-02-01T09:00:00Z');
    });

    test('maps the address resource field names', () {
      final customer = CustomerModel.fromJson(const {
        'id': 9,
        'name': 'Mariam Ali',
        'addresses': [
          {
            'id': 3,
            'type': 'shipping',
            'contact_name': 'Mariam Ali',
            'line_one': 'Marina Walk 1',
            'line_two': 'Apartment 1204',
            'city': 'Dubai',
            'state': 'Dubai',
            'postal_code': '00000',
            'country': 'AE',
            'is_default': true,
          },
        ],
      }).toEntity();

      final address = customer.addresses.single;
      expect(address.id, 3);
      expect(address.label, 'Mariam Ali');
      expect(address.line1, 'Marina Walk 1');
      expect(address.line2, 'Apartment 1204');
      expect(address.city, 'Dubai');
      expect(address.country, 'AE');
      expect(address.isDefault, isTrue);
      expect(address.oneLine,
          'Marina Walk 1, Apartment 1204, Dubai, Dubai, 00000, AE');
    });

    test('accepts the legacy address field names', () {
      final customer = CustomerModel.fromJson(const {
        'addresses': [
          {
            'id': 4,
            'label': 'Billing',
            'line1': 'Sheikh Zayed Road',
            'line2': 'Tower 2',
          },
        ],
      }).toEntity();

      final address = customer.addresses.single;
      expect(address.label, 'Billing');
      expect(address.line1, 'Sheikh Zayed Road');
      expect(address.line2, 'Tower 2');
    });

    test('applies safe defaults for a sparse payload', () {
      final customer = CustomerModel.fromJson(const {}).toEntity();

      expect(customer.id, 0);
      expect(customer.name, '');
      expect(customer.status, 'active');
      expect(customer.addresses, isEmpty);
      expect(customer.totalSpent, isNull);
    });
  });
}
