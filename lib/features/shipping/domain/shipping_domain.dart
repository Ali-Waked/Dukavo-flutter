/// Delivery zones for one store, mirroring `ShippingZoneResource`.
class ShippingZone {
  const ShippingZone({
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
    this.city,
    this.areas = const [],
    this.freeShippingThreshold,
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String name;
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
