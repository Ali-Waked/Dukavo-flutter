import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/paginated.dart';
import '../../../core/pagination/paginated_notifier.dart';
import '../../../core/providers.dart';
import '../data/product_data.dart';
import '../domain/product_domain.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    ProductRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

class ProductListNotifier extends PaginatedNotifier<Product> {
  ProductListNotifier(this._repository, this._ref);

  final ProductRepository _repository;
  final Ref _ref;

  String? search;
  String? status;
  bool lowStock = false;

  @override
  Future<Paginated<Product>> fetchPage(int page) {
    return _repository.list(
      search: search,
      status: status,
      lowStock: lowStock,
      page: page,
    );
  }

  Future<void> setSearch(String value) async {
    final next = value.trim().isEmpty ? null : value.trim();
    if (next == search) return;
    search = next;
    await reload();
  }

  Future<void> setStatus(String? value) async {
    if (value == status) return;
    status = value;
    await reload();
  }

  Future<void> setLowStock(bool value) async {
    if (value == lowStock) return;
    lowStock = value;
    await reload();
  }

  Future<void> delete(Product product) async {
    await _repository.delete(product.slug);
    state = state.copyWith(
      items: state.items.where((item) => item.id != product.id).toList(),
      total: state.total > 0 ? state.total - 1 : 0,
    );
    _ref.invalidate(productDetailProvider(product.slug));
  }
}

final productListProvider =
    StateNotifierProvider<ProductListNotifier, PaginatedState<Product>>((ref) {
  return ProductListNotifier(ref.watch(productRepositoryProvider), ref);
});

final productDetailProvider =
    FutureProvider.family<Product, String>((ref, slug) {
  return ref.watch(productRepositoryProvider).get(slug);
});

/// The catalogue flattened into pickable lines for the order builder.
///
/// Orders are priced by the server, but a line still needs a variant id, so
/// every variant is offered separately with its own price for the estimate.
class ProductOption {
  const ProductOption({
    required this.product,
    required this.variant,
  });

  final Product product;
  final ProductVariant variant;

  String get label =>
      product.variants.length <= 1 ? product.name : '${product.name} · ${variant.name}';
}

final productOptionsProvider = FutureProvider<List<ProductOption>>((ref) async {
  final page = await ref.watch(productRepositoryProvider).list(
        status: 'active',
        perPage: 100,
      );
  return [
    for (final product in page.items)
      for (final variant in product.variants)
        ProductOption(product: product, variant: variant),
  ];
});

/// Writes invalidate the list and the affected detail so every screen agrees.
class ProductActions {
  ProductActions(this._ref);

  final Ref _ref;

  Future<Product> create(ProductDraft draft) async {
    final product = await _ref.read(productRepositoryProvider).create(draft);
    _ref.invalidate(productListProvider);
    return product;
  }

  Future<Product> update(String slug, ProductDraft draft) async {
    final product =
        await _ref.read(productRepositoryProvider).update(slug, draft);
    _ref.invalidate(productListProvider);
    _ref.invalidate(productDetailProvider(slug));
    return product;
  }

  Future<void> delete(String slug) async {
    await _ref.read(productRepositoryProvider).delete(slug);
    _ref.invalidate(productListProvider);
    _ref.invalidate(productDetailProvider(slug));
  }
}

final productActionsProvider = Provider<ProductActions>(ProductActions.new);
