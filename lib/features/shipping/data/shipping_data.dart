import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/shipping_domain.dart';

class ShippingZoneModel {
  const ShippingZoneModel({
    required this.id,
    required this.name,
    required this.fee,
    required this.isActive,
    required this.sortOrder,
    this.city,
    this.areas = const [],
    this.freeShippingThreshold,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String? city;
  final List<String> areas;
  final num fee;
  final num? freeShippingThreshold;
  final bool isActive;
  final int sortOrder;
  final String? createdAt;
  final String? updatedAt;

  factory ShippingZoneModel.fromJson(Map<String, dynamic> json) {
    final rawAreas = json['areas'];
    return ShippingZoneModel(
      id: _int(json['id']),
      name: '${json['name'] ?? ''}',
      city: json['city'] as String?,
      areas: rawAreas is List
          ? rawAreas.map((entry) => '$entry').toList()
          : const [],
      fee: _num(json['fee']),
      freeShippingThreshold: _nullableNum(json['free_shipping_threshold']),
      isActive: json['is_active'] != false,
      sortOrder: _int(json['sort_order']),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  ShippingZone toEntity() => ShippingZone(
        id: id,
        name: name,
        city: city,
        areas: areas,
        fee: fee,
        freeShippingThreshold: freeShippingThreshold,
        isActive: isActive,
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static num _num(Object? value) {
    if (value is num) return value;
    return num.tryParse('$value') ?? 0;
  }

  static num? _nullableNum(Object? value) {
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse('$value');
  }
}

class ShippingRemoteDataSource {
  ShippingRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<ShippingZone>> list(int storeId) async {
    final data = await _api.get<List<dynamic>>(
      ApiPaths.storeShippingZones(storeId),
      decode: (raw) => raw is List ? raw : const <dynamic>[],
    );
    return data
        .whereType<Map>()
        .map((entry) =>
            ShippingZoneModel.fromJson(Map<String, dynamic>.from(entry)).toEntity())
        .toList();
  }

  Future<ShippingZone> create(int storeId, ShippingZoneDraft draft) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.storeShippingZones(storeId),
      body: _payload(draft),
      decode: _asMap,
    );
    return ShippingZoneModel.fromJson(data).toEntity();
  }

  Future<ShippingZone> update(
    int storeId,
    int zoneId,
    ShippingZoneDraft draft,
  ) async {
    final data = await _api.patch<Map<String, dynamic>>(
      ApiPaths.storeShippingZone(storeId, zoneId),
      body: _payload(draft),
      decode: _asMap,
    );
    return ShippingZoneModel.fromJson(data).toEntity();
  }

  Future<void> delete(int storeId, int zoneId) {
    return _api.delete(ApiPaths.storeShippingZone(storeId, zoneId));
  }

  Map<String, dynamic> _payload(ShippingZoneDraft draft) {
    return {
      'name': draft.name.trim(),
      'city': _clean(draft.city),
      'areas': draft.areas
          .map((area) => area.trim())
          .where((area) => area.isNotEmpty)
          .toList(),
      'fee': draft.fee,
      'free_shipping_threshold': draft.freeShippingThreshold,
      'is_active': draft.isActive,
      'sort_order': draft.sortOrder,
    };
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}

class ShippingRepositoryImpl implements ShippingRepository {
  ShippingRepositoryImpl(this._remote);

  final ShippingRemoteDataSource _remote;

  @override
  Future<List<ShippingZone>> list(int storeId) => _remote.list(storeId);

  @override
  Future<ShippingZone> create(int storeId, ShippingZoneDraft draft) =>
      _remote.create(storeId, draft);

  @override
  Future<ShippingZone> update(
    int storeId,
    int zoneId,
    ShippingZoneDraft draft,
  ) =>
      _remote.update(storeId, zoneId, draft);

  @override
  Future<void> delete(int storeId, int zoneId) =>
      _remote.delete(storeId, zoneId);
}
