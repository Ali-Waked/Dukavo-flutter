import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/shipping_domain.dart';

String? _stringOrNull(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

class ShippingZoneModel {
  const ShippingZoneModel({
    required this.id,
    required this.name,
    required this.fee,
    required this.isActive,
    required this.sortOrder,
    this.description,
    this.methodName,
    this.methodDescription,
    this.deliveryInstructions,
    this.terms,
    this.translations = const {},
    this.city,
    this.areas = const [],
    this.freeShippingThreshold,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String? description;
  final String? methodName;
  final String? methodDescription;
  final String? deliveryInstructions;
  final String? terms;
  final Map<String, ShippingZoneCopy> translations;
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
    final translations = <String, ShippingZoneCopy>{};

    final rawTranslations = json['translations'];
    if (rawTranslations is Map) {
      rawTranslations.forEach((locale, value) {
        if (value is Map) {
          translations['$locale'] = ShippingZoneCopy.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      });
    }

    // Older payloads and the `_ar` aliases still describe the Arabic copy.
    final arabic = ShippingZoneCopy(
      name: _stringOrNull(json['name_ar']),
      description: _stringOrNull(json['description_ar']),
      methodName: _stringOrNull(json['method_name_ar']),
      methodDescription: _stringOrNull(json['method_description_ar']),
      deliveryInstructions: _stringOrNull(json['delivery_instructions_ar']),
      terms: _stringOrNull(json['terms_ar']),
    );
    if (!arabic.isEmpty) {
      translations['ar'] = ShippingZoneCopy(
        name: translations['ar']?.name ?? arabic.name,
        description: translations['ar']?.description ?? arabic.description,
        methodName: translations['ar']?.methodName ?? arabic.methodName,
        methodDescription:
            translations['ar']?.methodDescription ?? arabic.methodDescription,
        deliveryInstructions: translations['ar']?.deliveryInstructions ??
            arabic.deliveryInstructions,
        terms: translations['ar']?.terms ?? arabic.terms,
      );
    }

    return ShippingZoneModel(
      id: _int(json['id']),
      name: '${json['name'] ?? ''}',
      description: _stringOrNull(json['description']),
      methodName: _stringOrNull(json['method_name']),
      methodDescription: _stringOrNull(json['method_description']),
      deliveryInstructions: _stringOrNull(json['delivery_instructions']),
      terms: _stringOrNull(json['terms']),
      translations: translations,
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
        description: description,
        methodName: methodName,
        methodDescription: methodDescription,
        deliveryInstructions: deliveryInstructions,
        terms: terms,
        translations: translations,
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
            ShippingZoneModel.fromJson(Map<String, dynamic>.from(entry))
                .toEntity())
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
      'description': _clean(draft.description),
      'method_name': _clean(draft.methodName),
      'method_description': _clean(draft.methodDescription),
      'delivery_instructions': _clean(draft.deliveryInstructions),
      'terms': _clean(draft.terms),
      'translations': {
        for (final entry in draft.translations.entries)
          entry.key: entry.value.toJson(),
      },
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
