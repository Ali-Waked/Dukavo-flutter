/// Customer-facing copy for one delivery option.
///
/// A zone is still one price rule: translating it changes these strings only,
/// never the fee, coverage or order that decide which rule applies.
class ShippingZoneCopy {
  const ShippingZoneCopy({
    this.name,
    this.description,
    this.methodName,
    this.methodDescription,
    this.deliveryInstructions,
    this.terms,
  });

  final String? name;
  final String? description;
  final String? methodName;
  final String? methodDescription;
  final String? deliveryInstructions;
  final String? terms;

  bool get isEmpty =>
      _clean(name) == null &&
      _clean(description) == null &&
      _clean(methodName) == null &&
      _clean(methodDescription) == null &&
      _clean(deliveryInstructions) == null &&
      _clean(terms) == null;

  Map<String, dynamic> toJson() => {
        'name': _clean(name),
        'description': _clean(description),
        'method_name': _clean(methodName),
        'method_description': _clean(methodDescription),
        'delivery_instructions': _clean(deliveryInstructions),
        'terms': _clean(terms),
      };

  factory ShippingZoneCopy.fromJson(Map<String, dynamic> json) {
    return ShippingZoneCopy(
      name: _stringOrNull(json['name']),
      description: _stringOrNull(json['description']),
      methodName: _stringOrNull(json['method_name']),
      methodDescription: _stringOrNull(json['method_description']),
      deliveryInstructions: _stringOrNull(json['delivery_instructions']),
      terms: _stringOrNull(json['terms']),
    );
  }
}

String? _clean(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

String? _stringOrNull(Object? value) {
  if (value is! String) return null;
  return _clean(value);
}

/// Delivery zones for one store, mirroring `ShippingZoneResource`.
class ShippingZone {
  const ShippingZone({
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

  /// Per-language copy, keyed by locale. The canonical English columns remain
  /// the fallback when a language has no field of its own.
  final Map<String, ShippingZoneCopy> translations;
  final String? city;
  final List<String> areas;
  final num fee;
  final num? freeShippingThreshold;
  final bool isActive;
  final int sortOrder;
  final String? createdAt;
  final String? updatedAt;

  ShippingZoneCopy get arabicCopy =>
      translations['ar'] ?? const ShippingZoneCopy();

  String get coverage {
    final parts = [
      if (city != null && city!.trim().isNotEmpty) city!,
      ...areas,
    ];
    return parts.join(' · ');
  }
}

class ShippingZoneDraft {
  const ShippingZoneDraft({
    required this.name,
    required this.fee,
    this.description,
    this.methodName,
    this.methodDescription,
    this.deliveryInstructions,
    this.terms,
    this.translations = const {},
    this.city,
    this.areas = const [],
    this.freeShippingThreshold,
    this.isActive = true,
    this.sortOrder = 0,
  });

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
}

abstract class ShippingRepository {
  Future<List<ShippingZone>> list(int storeId);

  Future<ShippingZone> create(int storeId, ShippingZoneDraft draft);

  Future<ShippingZone> update(
    int storeId,
    int zoneId,
    ShippingZoneDraft draft,
  );

  Future<void> delete(int storeId, int zoneId);
}
