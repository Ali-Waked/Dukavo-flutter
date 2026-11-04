import 'package:dukavo_mobile/features/shop/domain/shop_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StorefrontInfo.fromJson', () {
    test('parses the public storefront envelope', () {
      final info = StorefrontInfo.fromJson(const {
        'name': 'Layla Home',
        'slug': 'layla-home',
        'tenant_slug': 'layla',
        'description': 'Homeware',
        'logo_url': 'https://cdn.example.com/logo.png',
        'email': 'hello@example.com',
        'phone': '+966500000000',
        'currency': 'SAR',
        'currency_symbol': 'ر.س',
        'currency_decimals': 2,
        'timezone': 'Asia/Riyadh',
        'settings': {
          'tagline': 'Made for living',
          'about': 'A small studio.',
          'hero_image_url': 'https://cdn.example.com/hero.png',
          'delivery_note': 'Next day in Riyadh.',
          'return_policy': '14 days',
          'address': 'Riyadh',
          'whatsapp_number': '+966500000001',
          'opening_hours': '9–5',
        },
      });

      expect(info.name, 'Layla Home');
      expect(info.tenantSlug, 'layla');
      expect(info.currency, 'SAR');
      expect(info.currencyDecimals, 2);
      expect(info.tagline, 'Made for living');
      expect(info.whatsappNumber, '+966500000001');
    });

    test('falls back honestly when optional values are missing', () {
      final info = StorefrontInfo.fromJson(const {'name': 'Bare shop'});

      expect(info.currency, 'USD');
      expect(info.timezone, 'UTC');
      expect(info.currencyDecimals, 2);
      expect(info.settings, isEmpty);
      expect(info.tagline, isNull);
    });
  });

  group('ShopProduct.fromJson', () {
    test('keeps catalogue data and selects the primary image', () {
      final product = ShopProduct.fromJson(const {
        'slug': 'linen-shirt',
        'name': 'Linen shirt',
        'description': 'Soft linen.',
        'price': '120.50',
        'currency': 'AED',
        'in_stock': true,
        'available': 7,
        'category': {'name': 'Shirts', 'slug': 'shirts'},
        'images': [
          {'url': 'https://cdn.example.com/one.png', 'is_primary': false},
          {'url': 'https://cdn.example.com/two.png', 'is_primary': true},
        ],
        'variants': [
          {
            'id': 10,
            'name': 'Small',
            'price': '120.50',
            'available': 3,
            'in_stock': true,
          },
          {
            'id': 11,
            'name': 'Medium',
            'price': '125.00',
            'available': 4,
            'in_stock': true,
            'is_default': true,
          },
        ],
      });

      expect(product.price, 120.5);
      expect(product.categoryName, 'Shirts');
      expect(product.primaryImageUrl, 'https://cdn.example.com/two.png');
      expect(product.defaultVariant?.id, 11);
      expect(product.variants, hasLength(2));
    });

    test('falls back to the first image and variant when none is marked', () {
      final product = ShopProduct.fromJson(const {
        'slug': 'mug',
        'name': 'Mug',
        'images': [
          {'url': 'https://cdn.example.com/mug.png'},
        ],
        'variants': [
          {'id': 1, 'name': 'Default', 'price': 20},
        ],
      });

      expect(product.primaryImageUrl, 'https://cdn.example.com/mug.png');
      expect(product.defaultVariant?.id, 1);
      expect(product.inStock, isFalse);
      expect(product.available, 0);
    });
  });

  group('ShopOrder.fromJson', () {
    test('parses the customer-safe order and its totals', () {
      final order = ShopOrder.fromJson(const {
        'order_number': 'ORD-000042',
        'status': 'pending',
        'status_label': 'Pending',
        'payment_status': 'unpaid',
        'payment_status_label': 'Unpaid',
        'payment_method_label': 'Cash on delivery',
        'subtotal': '200.00',
        'discount_total': '0',
        'tax_total': '30.00',
        'shipping_total': '15.00',
        'grand_total': '245.00',
        'currency': 'SAR',
        'customer_name': 'Noura',
        'customer_phone': '+966500000000',
        'shipping_address': {'line_one': 'King Fahd Rd', 'city': 'Riyadh'},
        'items': [
          {
            'name': 'Linen shirt',
            'sku': 'LS-10',
            'quantity': 2,
            'unit_price': '100.00',
            'line_total': '200.00',
          },
        ],
        'placed_at': '2026-01-02T10:00:00Z',
        'tracking_token': 'tok_123',
      });

      expect(order.orderNumber, 'ORD-000042');
      expect(order.grandTotal, 245);
      expect(order.shippingAddress['city'], 'Riyadh');
      expect(order.items.single.quantity, 2);
      expect(order.items.single.lineTotal, 200);
      expect(order.trackingToken, 'tok_123');
    });
  });

  group('ShopShippingZone.fromJson', () {
    test('parses areas and an optional free-shipping threshold', () {
      final zone = ShopShippingZone.fromJson(const {
        'id': 3,
        'name': 'Riyadh',
        'city': 'Riyadh',
        'areas': ['Olaya', 'Malaz'],
        'fee': '15.00',
        'free_shipping_threshold': '300.00',
      });

      expect(zone.city, 'Riyadh');
      expect(zone.areas, ['Olaya', 'Malaz']);
      expect(zone.fee, 15);
      expect(zone.freeShippingThreshold, 300);
    });
  });
}
