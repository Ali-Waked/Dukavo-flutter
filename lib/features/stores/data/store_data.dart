import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/store_domain.dart';

class StoreModel {
  const StoreModel({
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

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: _int(json['id']),
      name: '${json['name'] ?? ''}',
      slug: '${json['slug'] ?? ''}',
      status: '${json['status'] ?? 'active'}',
      isDefault: json['is_default'] == true,
      currency: '${json['currency'] ?? 'USD'}',
      timezone: '${json['timezone'] ?? 'UTC'}',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      productsCount: _nullableInt(json['products_count']),
    );
  }

  Store toEntity() => Store(
        id: id,
        name: name,
        slug: slug,
        status: status,
        isDefault: isDefault,
        currency: currency,
        timezone: timezone,
        email: email,
        phone: phone,
        productsCount: productsCount,
      );

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static int? _nullableInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }
}

class StoreRemoteDataSource {
  StoreRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<Store>> list({bool activeOnly = false}) async {
    final data = await _api.get<List<dynamic>>(
      ApiPaths.stores,
      query: {if (activeOnly) 'active_only': 1},
      decode: (raw) => raw is List ? raw : const <dynamic>[],
    );

    return data
        .whereType<Map>()
        .map((entry) => StoreModel.fromJson(Map<String, dynamic>.from(entry)).toEntity())
        .toList();
  }
}

class StoreRepositoryImpl implements StoreRepository {
  StoreRepositoryImpl(this._remote);

  final StoreRemoteDataSource _remote;

  @override
  Future<List<Store>> list({bool activeOnly = false}) =>
      _remote.list(activeOnly: activeOnly);
}
