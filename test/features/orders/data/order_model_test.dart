import 'package:dukavo_mobile/features/orders/data/order_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderModel.fromJson', () {
    test('parses a fully loaded order resource', () {
      final model = OrderModel.fromJson(const {
        'id': 17,
        'order_number': 'ORD-000017',
        'store_id': 2,
        'customer_id': 9,
        'conversation_id': null,
        'status': 'confirmed',
        'status_label': 'Confirmed',
        'payment_status': 'partially_paid',
        'payment_status_label': 'Partially paid',
        'subtotal': '200.00',
        'discount_total': '10.00',
        'tax_total': 5,
        'shipping_total': 0,
        'grand_total': '195.00',
        'currency': 'AED',
        'customer_name': 'Walk-in customer',
        'customer_phone': '+971500000000',
        'notes': 'Deliver after 5pm',
        'item_count': 3,
        'allowed_transitions': ['processing', 'cancelled'],
        'customer': {
          'id': 9,
          'name': 'Mariam Ali',
          'email': 'mariam@example.com',
          'phone': '+971500000001',
        },
        'items': [
          {
            'id': 51,
            'product_id': 4,
            'product_variant_id': 12,
            'name': 'Linen shirt',
            'sku': 'LS-12',
            'unit_price': '100.00',
            'quantity': 2,
            'discount_total': '5.00',
            'tax_total': '2.50',
            'line_total': '195.00',
          },
        ],
        'status_history': [
          {
            'from_status': 'pending',
            'to_status': 'confirmed',
            'note': 'Paid deposit',
            'created_at': '2024-02-01T09:00:00Z',
            'user': {'name': 'Sara Hassan'},
          },
        ],
        'placed_at': '2024-02-01T08:55:00Z',
        'created_at': '2024-02-01T08:50:00Z',
      });

      final order = model.toEntity();
      expect(order.id, 17);
      expect(order.orderNumber, 'ORD-000017');
      expect(order.status, 'confirmed');
      expect(order.paymentStatus, 'partially_paid');
      expect(order.subtotal, 200);
      expect(order.discountTotal, 10);
      expect(order.taxTotal, 5);
      expect(order.shippingTotal, 0);
      expect(order.grandTotal, 195);
      expect(order.currency, 'AED');
      expect(order.itemCount, 3);
      expect(order.allowedTransitions, ['processing', 'cancelled']);
      expect(order.displayCustomer, 'Mariam Ali');
      expect(order.customer?.email, 'mariam@example.com');
      expect(order.items, hasLength(1));

      final item = order.items.single;
      expect(item.productVariantId, 12);
      expect(item.name, 'Linen shirt');
      expect(item.sku, 'LS-12');
      expect(item.quantity, 2);
      expect(item.unitPrice, 100);
      expect(item.lineTotal, 195);

      final history = order.statusHistory.single;
      expect(history.fromStatus, 'pending');
      expect(history.toStatus, 'confirmed');
      expect(history.status, 'confirmed');
      expect(history.actorName, 'Sara Hassan');
      expect(history.note, 'Paid deposit');
    });

    test('applies safe defaults for a minimal payload', () {
      final order = OrderModel.fromJson(const {}).toEntity();

      expect(order.id, 0);
      expect(order.orderNumber, '');
      expect(order.status, 'pending');
      expect(order.paymentStatus, 'unpaid');
      expect(order.currency, 'USD');
      expect(order.subtotal, 0);
      expect(order.grandTotal, 0);
      expect(order.allowedTransitions, isEmpty);
      expect(order.items, isEmpty);
      expect(order.statusHistory, isEmpty);
      expect(order.customer, isNull);
      expect(order.displayCustomer, '—');
    });

    test('ignores malformed nested collections', () {
      final order = OrderModel.fromJson(const {
        'items': 'not-a-list',
        'status_history': 42,
        'allowed_transitions': {'processing': true},
        'customer': 'not-a-map',
      }).toEntity();

      expect(order.items, isEmpty);
      expect(order.statusHistory, isEmpty);
      expect(order.allowedTransitions, isEmpty);
      expect(order.customer, isNull);
    });

    test('accepts a history entry whose actor is named actor', () {
      final order = OrderModel.fromJson(const {
        'status_history': [
          {
            'to_status': 'shipped',
            'actor': {'name': 'Omar'},
          },
        ],
      }).toEntity();

      expect(order.statusHistory.single.actorName, 'Omar');
      expect(order.statusHistory.single.fromStatus, isNull);
    });
  });
}
