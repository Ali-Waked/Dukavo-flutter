import 'package:dukavo_mobile/features/shop/application/shop_providers.dart';
import 'package:dukavo_mobile/features/shop/domain/shop_models.dart';
import 'package:flutter_test/flutter_test.dart';

ShopCartLine line({
  required int variantId,
  int quantity = 1,
  num unitPrice = 100,
  int maxQuantity = 10,
}) {
  return ShopCartLine(
    productSlug: 'product-$variantId',
    productName: 'Product $variantId',
    variantId: variantId,
    variantName: 'Default',
    unitPrice: unitPrice,
    currency: 'SAR',
    quantity: quantity,
    imageUrl: null,
    maxQuantity: maxQuantity,
  );
}

void main() {
  group('CartNotifier', () {
    test('starts empty with a zero subtotal', () {
      final cart = CartNotifier();

      expect(cart.state, isEmpty);
      expect(cart.itemCount, 0);
      expect(cart.subtotal, 0);
    });

    test('adds a new variant and merges quantities for an existing one', () {
      final cart = CartNotifier()..add(line(variantId: 1, quantity: 2));

      expect(cart.state, hasLength(1));
      expect(cart.itemCount, 2);

      cart.add(line(variantId: 1, quantity: 3));
      expect(cart.state, hasLength(1));
      expect(cart.state.single.quantity, 5);
      expect(cart.subtotal, 500);
    });

    test('never exceeds the available quantity when merging', () {
      final cart = CartNotifier()
        ..add(line(variantId: 1, quantity: 8, maxQuantity: 9))
        ..add(line(variantId: 1, quantity: 5, maxQuantity: 9));

      expect(cart.state.single.quantity, 9);
    });

    test('clamps setQuantity and removes at zero or below', () {
      final cart = CartNotifier()
        ..add(line(variantId: 1, quantity: 1, maxQuantity: 4));

      cart.setQuantity(1, 99);
      expect(cart.state.single.quantity, 4);

      cart.setQuantity(1, 0);
      expect(cart.state, isEmpty);
    });

    test('keeps separate variants and removes only the requested one', () {
      final cart = CartNotifier()
        ..add(line(variantId: 1, quantity: 1))
        ..add(line(variantId: 2, quantity: 2));

      expect(cart.itemCount, 3);
      expect(cart.subtotal, 300);

      cart.remove(1);
      expect(cart.state.single.variantId, 2);
      expect(cart.itemCount, 2);
    });

    test('clears every line', () {
      final cart = CartNotifier()
        ..add(line(variantId: 1))
        ..add(line(variantId: 2))
        ..clear();

      expect(cart.state, isEmpty);
      expect(cart.subtotal, 0);
    });
  });

  group('ShopRef', () {
    test('keys and compares by tenant and store', () {
      const first = ShopRef('tenant-a', 'store-1');
      const same = ShopRef('tenant-a', 'store-1');
      const otherTenant = ShopRef('tenant-b', 'store-1');

      expect(first, same);
      expect(first.hashCode, same.hashCode);
      expect(first, isNot(otherTenant));
      expect(first.key, 'tenant-a/store-1');
    });
  });
}
