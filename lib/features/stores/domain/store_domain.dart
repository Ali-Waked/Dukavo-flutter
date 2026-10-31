/// Stores (outlets), mirroring `StoreResource`.
class Store {
  const Store({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    required this.isDefault,
    required this.currency,
    required this.timezone,
    this.email,
    this.phone,
    this.productsCount,
  });

  final int id;
  final String name;
  final String slug;
  final String status;
  final bool isDefault;
  final String currency;
  final String timezone;
  final String? email;
  final String? phone;
  final int? productsCount;
}

abstract class StoreRepository {
  Future<List<Store>> list({bool activeOnly = false});
}
