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

    test('parses the latest online attempt without trusting a redirect', () {
      final order = ShopOrder.fromJson(const {
        'order_number': 'ORD-000043',
        'payment_status': 'unpaid',
        'payment_method': 'online',
        'payment_method_label': 'Pay online',
        'currency': 'SAR',
        'payment': {
          'status': 'pending',
          'status_label': 'Pending',
          'method_code': 'mada',
          'attempt_number': 2,
          'amount': '245.00',
          'currency': 'SAR',
          'provider_name': 'Tap Payments',
          'checkout_url': 'https://checkout.tap.test/ch_123',
          'failure_reason': null,
          'reference': '••••ch_123',
          'retry_allowed': false,
          'expires_at': '2026-01-02T11:00:00Z',
          'paid_at': null,
        },
      });

      expect(order.paymentMethod, 'online');
      expect(order.payment?.methodCode, 'mada');
      expect(order.payment?.attemptNumber, 2);
      expect(order.payment?.checkoutUrl, 'https://checkout.tap.test/ch_123');
      expect(order.payment?.isPaid, isFalse);
      expect(order.payment?.isPending, isTrue);
      expect(order.payment?.retryAllowed, isFalse);
    });

    test('keeps bank transfer and cash orders free of a payment attempt', () {
      final order = ShopOrder.fromJson(const {
        'order_number': 'ORD-000044',
        'payment_status': 'unpaid',
        'payment_method': 'bank_transfer',
        'payment_method_label': 'Bank transfer',
        'currency': 'SAR',
      });

      expect(order.paymentMethod, 'bank_transfer');
      expect(order.payment, isNull);
    });
  });

  group('ShopPaymentMethod.fromJson', () {
    test('parses nested online rails and their provider environment', () {
      final method = ShopPaymentMethod.fromJson(const {
        'code': 'online',
        'label': 'Pay online',
        'description': 'Pay with a card.',
        'available': true,
        'unavailable_reason': null,
        'instructions': null,
        'methods': [
          {
            'code': 'card',
            'label': 'Card',
            'description': 'Pay with a debit or credit card.',
            'kind': 'card',
            'provider': 'tap',
            'provider_name': 'Tap Payments',
            'environment': 'sandbox',
          },
          {
            'code': 'apple_pay',
            'label': 'Apple Pay',
            'description': 'Pay with Apple Pay.',
            'kind': 'wallet',
            'provider': 'tap',
            'provider_name': 'Tap Payments',
            'environment': 'sandbox',
          },
        ],
      });

      expect(method.available, isTrue);
      expect(method.methods, hasLength(2));
      expect(method.methods.first.code, 'card');
      expect(method.methods.last.provider, 'tap');
      expect(method.methods.last.environment, 'sandbox');
    });

    test('a disabled method still carries the server reason', () {
      final method = ShopPaymentMethod.fromJson(const {
        'code': 'online',
        'label': 'Pay online',
        'description': 'Pay with a card.',
        'available': false,
        'unavailable_reason':
            'No verified sandbox payment provider connection is configured for this store.',
        'methods': [],
      });

      expect(method.available, isFalse);
      expect(method.methods, isEmpty);
      expect(method.unavailableReason, contains('verified sandbox'));
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

    test('parses the copy the server already resolved to one language', () {
      final zone = ShopShippingZone.fromJson(const {
        'id': 3,
        'name': 'توصيل الرياض',
        'description': 'طلبات داخل الرياض.',
        'method_name': 'التوصيل العادي',
        'method_description': 'يتم التسليم خلال يومي عمل.',
        'delivery_instructions': 'اتصل عند الوصول.',
        'terms': 'التوصيل مجاني فوق ٣٠٠.',
        'locale': 'ar',
        'city': 'Riyadh',
        'areas': ['Olaya'],
        'fee': 15,
        'free_shipping_threshold': 300,
      });

      expect(zone.name, 'توصيل الرياض');
      expect(zone.methodName, 'التوصيل العادي');
      expect(zone.methodDescription, 'يتم التسليم خلال يومي عمل.');
      expect(zone.deliveryInstructions, 'اتصل عند الوصول.');
      expect(zone.terms, 'التوصيل مجاني فوق ٣٠٠.');
      expect(zone.locale, 'ar');
      expect(zone.fee, 15);
      expect(zone.freeShippingThreshold, 300);
      expect(zone.areas, ['Olaya']);
    });

    test('a public zone never exposes a raw translations document', () {
      final zone = ShopShippingZone.fromJson(const {
        'name': 'Cairo delivery',
        'translations': {
          'ar': {'name': 'توصيل القاهرة'},
        },
      });

      expect(zone.name, 'Cairo delivery');
      expect(zone.locale, isNull);
    });
  });
}
