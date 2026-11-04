import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/api/paginated.dart';
import '../domain/shop_models.dart';

class ShopRepository {
  ShopRepository(this._api);

  final ApiClient _api;

  Future<StorefrontInfo> info(String tenant, String store) async {
    final data = await _api.get<JsonMap>(
      ApiPaths.publicStorefront(tenant, store),
      decode: _asMap,
    );
    return StorefrontInfo.fromJson(data);
  }

  Future<List<ShopCategory>> categories(String tenant, String store) async {
    final data = await _api.get<List<dynamic>>(
      ApiPaths.publicStorefrontCategories(tenant, store),
      decode: (value) => value is List ? value : const <dynamic>[],
    );
    return data
        .whereType<Map>()
        .map((entry) => ShopCategory.fromJson(
              Map<String, dynamic>.from(entry),
            ))
        .toList();
  }

  Future<Paginated<ShopProduct>> products(
    String tenant,
    String store, {
    String? search,
    String? category,
    String? sort,
    int page = 1,
    int perPage = 24,
  }) {
    return _api.list<ShopProduct>(
      ApiPaths.publicStorefrontProducts(tenant, store),
      query: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
        if (sort != null && sort.isNotEmpty) 'sort': sort,
        'page': page,
        'per_page': perPage,
      },
      item: ShopProduct.fromJson,
    );
  }

  Future<ShopProduct> product(
    String tenant,
    String store,
    String slug,
  ) async {
    final data = await _api.get<JsonMap>(
      ApiPaths.publicStorefrontProduct(tenant, store, slug),
      decode: _asMap,
    );
    return ShopProduct.fromJson(data);
  }

  Future<List<ShopShippingZone>> shippingZones(
    String tenant,
    String store,
  ) async {
    final data = await _api.get<List<dynamic>>(
      ApiPaths.publicStorefrontShipping(tenant, store),
      decode: (value) => value is List ? value : const <dynamic>[],
    );
    return data
        .whereType<Map>()
        .map((entry) => ShopShippingZone.fromJson(
              Map<String, dynamic>.from(entry),
            ))
        .toList();
  }

  Future<List<ShopPaymentMethod>> paymentMethods(
    String tenant,
    String store,
  ) async {
    final data = await _api.get<JsonMap>(
      ApiPaths.publicStorefrontPayments(tenant, store),
      decode: _asMap,
    );
    final raw = data['methods'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((entry) => ShopPaymentMethod.fromJson(
              Map<String, dynamic>.from(entry),
            ))
        .toList();
  }

  Future<ShopOrder> checkout(
    String tenant,
    String store,
    Map<String, dynamic> body,
  ) async {
    final data = await _api.post<JsonMap>(
      ApiPaths.publicStorefrontCheckout(tenant, store),
      body: body,
      decode: _asMap,
    );
    return ShopOrder.fromJson(data);
  }

  Future<ShopOrder> order(
    String tenant,
    String store,
    String token,
  ) async {
    final data = await _api.get<JsonMap>(
      ApiPaths.publicStorefrontOrder(tenant, store, token),
      decode: _asMap,
    );
    return ShopOrder.fromJson(data);
  }

  JsonMap _asMap(Object? data) =>
      data is Map ? Map<String, dynamic>.from(data) : const <String, dynamic>{};
}
