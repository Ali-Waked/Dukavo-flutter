import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/api/paginated.dart';
import '../domain/inventory_domain.dart';

class InventoryModel {
  const InventoryModel({
    required this.id,
    required this.storeId,
    required this.productId,
    required this.productVariantId,
    required this.quantity,
    required this.reserved,
    required this.available,
    required this.lowStockThreshold,
    required this.isLowStock,
    this.productName,
    this.productSku,
    this.variantName,
    this.variantSku,
    this.storeName,
    this.updatedAt,
  });

  final int id;
  final int storeId;
  final int productId;
  final int productVariantId;
  final int quantity;
  final int reserved;
  final int available;
  final int? lowStockThreshold;
  final bool isLowStock;
  final String? productName;
  final String? productSku;
  final String? variantName;
  final String? variantSku;
  final String? storeName;
  final String? updatedAt;

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    final variant = json['variant'];
    final store = json['store'];
    return InventoryModel(
      id: _int(json['id']),
      storeId: _int(json['store_id']),
      productId: _int(json['product_id']),
      productVariantId: _int(json['product_variant_id']),
      quantity: _int(json['quantity']),
      reserved: _int(json['reserved_quantity']),
      available: _int(json['available']),
      lowStockThreshold: _nullableInt(json['low_stock_threshold']),
      isLowStock: json['is_low_stock'] == true,
      productName: product is Map ? '${product['name'] ?? ''}' : null,
      productSku: product is Map ? product['sku'] as String? : null,
      variantName: variant is Map ? '${variant['name'] ?? ''}' : null,
      variantSku: variant is Map ? variant['sku'] as String? : null,
      storeName: store is Map ? '${store['name'] ?? ''}' : null,
      updatedAt: json['updated_at'] as String?,
    );
  }

  InventoryItem toEntity() => InventoryItem(
        id: id,
        storeId: storeId,
        productId: productId,
        productVariantId: productVariantId,
        quantity: quantity,
        reserved: reserved,
        available: available,
        lowStockThreshold: lowStockThreshold,
        isLowStock: isLowStock,
        productName: productName,
        productSku: productSku,
        variantName: variantName,
        variantSku: variantSku,
        storeName: storeName,
        updatedAt: updatedAt,
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

class InventoryMovementModel {
  const InventoryMovementModel({
    required this.id,
    required this.inventoryId,
    required this.type,
    required this.typeLabel,
    required this.quantity,
    required this.direction,
    required this.balanceAfter,
    this.source,
    this.note,
    this.userName,
    this.createdAt,
  });

  final int id;
  final int inventoryId;
  final String type;
  final String typeLabel;
  final int quantity;
  final String direction;
  final int balanceAfter;
  final String? source;
  final String? note;
  final String? userName;
  final String? createdAt;

  factory InventoryMovementModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return InventoryMovementModel(
      id: InventoryModel._int(json['id']),
      inventoryId: InventoryModel._int(json['inventory_id']),
      type: '${json['type'] ?? 'adjustment'}',
      typeLabel: '${json['type_label'] ?? json['type'] ?? 'adjustment'}',
      quantity: InventoryModel._int(json['quantity']),
      direction: '${json['direction'] ?? 'in'}',
      balanceAfter: InventoryModel._int(json['balance_after']),
      source: json['source'] as String?,
      note: json['note'] as String?,
      userName: user is Map ? '${user['name'] ?? ''}' : null,
      createdAt: json['created_at'] as String?,
    );
  }

  InventoryMovement toEntity() => InventoryMovement(
        id: id,
        inventoryId: inventoryId,
        type: type,
        typeLabel: typeLabel,
        quantity: quantity,
        direction: direction,
        balanceAfter: balanceAfter,
        source: source,
        note: note,
        userName: userName,
        createdAt: createdAt,
      );
}

class InventoryRemoteDataSource {
  InventoryRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Paginated<InventoryItem>> list({
    bool lowStock = false,
    int? storeId,
    int page = 1,
    int perPage = 20,
  }) {
    return _api.list<InventoryItem>(
      ApiPaths.inventory,
      query: {
        'page': page,
        'per_page': perPage,
        if (lowStock) 'low_stock': 1,
        if (storeId != null) 'store_id': storeId,
      },
      item: (json) => InventoryModel.fromJson(json).toEntity(),
    );
  }

  Future<List<InventoryItem>> lowStock({int? storeId, int limit = 10}) async {
    final data = await _api.get<List<dynamic>>(
      ApiPaths.inventoryLowStock,
      query: {
        'limit': limit,
        if (storeId != null) 'store_id': storeId,
      },
      decode: (raw) => raw is List ? raw : const <dynamic>[],
    );

    return data
        .whereType<Map>()
        .map((entry) =>
            InventoryModel.fromJson(Map<String, dynamic>.from(entry))
                .toEntity())
        .toList();
  }

  Future<List<InventoryMovement>> movements(
    int inventoryId, {
    int page = 1,
    int perPage = 50,
  }) async {
    final pageData = await _api.list<InventoryMovement>(
      ApiPaths.inventoryMovements(inventoryId),
      query: {'page': page, 'per_page': perPage},
      item: (json) => InventoryMovementModel.fromJson(json).toEntity(),
    );
    return pageData.items;
  }

  Future<InventoryMovement> adjust(StockMovementDraft draft) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.inventoryAdjust,
      body: _payload(draft),
      decode: _asMap,
    );
    return InventoryMovementModel.fromJson(data).toEntity();
  }

  Future<InventoryMovement> receive(StockMovementDraft draft) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.inventoryReceive,
      body: _payload(draft),
      decode: _asMap,
    );
    return InventoryMovementModel.fromJson(data).toEntity();
  }

  Map<String, dynamic> _payload(StockMovementDraft draft) {
    return {
      'store_id': draft.storeId,
      'product_variant_id': draft.productVariantId,
      'quantity': draft.quantity,
      if (draft.lowStockThreshold != null)
        'low_stock_threshold': draft.lowStockThreshold,
      if (draft.note != null && draft.note!.trim().isNotEmpty)
        'note': draft.note!.trim(),
    };
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl(this._remote);

  final InventoryRemoteDataSource _remote;

  @override
  Future<Paginated<InventoryItem>> list({
    bool lowStock = false,
    int? storeId,
    int page = 1,
    int perPage = 20,
  }) {
    return _remote.list(
      lowStock: lowStock,
      storeId: storeId,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<List<InventoryItem>> lowStock({int? storeId, int limit = 10}) =>
      _remote.lowStock(storeId: storeId, limit: limit);

  @override
  Future<List<InventoryMovement>> movements(
    int inventoryId, {
    int page = 1,
    int perPage = 50,
  }) {
    return _remote.movements(inventoryId, page: page, perPage: perPage);
  }

  @override
  Future<InventoryMovement> adjust(StockMovementDraft draft) =>
      _remote.adjust(draft);

  @override
  Future<InventoryMovement> receive(StockMovementDraft draft) =>
      _remote.receive(draft);
}
