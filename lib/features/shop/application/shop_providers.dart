import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_controller.dart';
import '../../../core/providers.dart';
import '../data/shop_repository.dart';
import '../domain/shop_models.dart';

/// Identifies one public storefront. Two stores can share a slug in different
/// tenants, so both halves are part of the key.
class ShopRef {
  const ShopRef(this.tenant, this.store);

  final String tenant;
  final String store;

  String get key => '$tenant/$store';

  @override
  bool operator ==(Object other) =>
      other is ShopRef && other.tenant == tenant && other.store == store;

  @override
  int get hashCode => Object.hash(tenant, store);
}

class ShopOrderRef {
  const ShopOrderRef(this.tenant, this.store, this.token);

  final String tenant;
  final String store;
  final String token;

  @override
  bool operator ==(Object other) =>
      other is ShopOrderRef &&
      other.tenant == tenant &&
      other.store == store &&
      other.token == token;

  @override
  int get hashCode => Object.hash(tenant, store, token);
}

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository(ref.watch(apiClientProvider));
});

final shopInfoProvider =
    FutureProvider.autoDispose.family<StorefrontInfo, ShopRef>((ref, shop) {
  // Store copy and direction are language-specific; a switch must re-fetch.
  ref.watch(effectiveLocaleProvider);
  return ref.watch(shopRepositoryProvider).info(shop.tenant, shop.store);
});

final shopCategoriesProvider =
    FutureProvider.autoDispose.family<List<ShopCategory>, ShopRef>((ref, shop) {
  ref.watch(effectiveLocaleProvider);
  return ref.watch(shopRepositoryProvider).categories(shop.tenant, shop.store);
});

final shopProductProvider = FutureProvider.autoDispose
    .family<ShopProduct, (ShopRef, String)>((ref, args) {
  final (shop, slug) = args;
  ref.watch(effectiveLocaleProvider);
  return ref
      .watch(shopRepositoryProvider)
      .product(shop.tenant, shop.store, slug);
});

final shopShippingProvider = FutureProvider.autoDispose
    .family<List<ShopShippingZone>, ShopRef>((ref, shop) {
  // Shipping copy is resolved by the API from the request language, so a
  // language switch must reload it. Fees and coverage do not change.
  ref.watch(effectiveLocaleProvider);
  return ref
      .watch(shopRepositoryProvider)
      .shippingZones(shop.tenant, shop.store);
});

final shopPaymentsProvider = FutureProvider.autoDispose
    .family<List<ShopPaymentMethod>, ShopRef>((ref, shop) {
  return ref
      .watch(shopRepositoryProvider)
      .paymentMethods(shop.tenant, shop.store);
});

final shopOrderProvider =
    FutureProvider.autoDispose.family<ShopOrder, ShopOrderRef>((ref, order) {
  return ref
      .watch(shopRepositoryProvider)
      .order(order.tenant, order.store, order.token);
});

/// The cart is held on the client because there is no cart endpoint; the server
/// re-resolves every price, fee and total at checkout, so a tampered local cart
/// cannot change what is charged.
class CartNotifier extends StateNotifier<List<ShopCartLine>> {
  CartNotifier() : super(const []);

  void add(ShopCartLine line) {
    final index = state.indexWhere(
      (existing) => existing.variantId == line.variantId,
    );
    if (index == -1) {
      state = [...state, line];
      return;
    }
    final existing = state[index];
    final quantity = (existing.quantity + line.quantity).clamp(
      1,
      existing.maxQuantity <= 0 ? 999 : existing.maxQuantity,
    );
    state = [
      ...state.sublist(0, index),
      existing.copyWith(quantity: quantity),
      ...state.sublist(index + 1),
    ];
  }

  void setQuantity(int variantId, int quantity) {
    if (quantity <= 0) {
      remove(variantId);
      return;
    }
    state = [
      for (final line in state)
        if (line.variantId == variantId)
          line.copyWith(
            quantity: line.maxQuantity > 0
                ? quantity.clamp(1, line.maxQuantity)
                : quantity,
          )
        else
          line,
    ];
  }

  void remove(int variantId) {
    state = state.where((line) => line.variantId != variantId).toList();
  }

  void clear() => state = const [];

  int get itemCount => state.fold(0, (total, line) => total + line.quantity);

  num get subtotal => state.fold(0, (total, line) => total + line.lineTotal);
}

final cartProvider =
    StateNotifierProvider.family<CartNotifier, List<ShopCartLine>, ShopRef>(
  (ref, shop) => CartNotifier(),
);
