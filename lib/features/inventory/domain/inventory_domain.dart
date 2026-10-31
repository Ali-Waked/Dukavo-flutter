import '../../../core/api/paginated.dart';

/// One stock row, mirroring `InventoryResource`.
class InventoryItem {
  const InventoryItem({
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

  String get displayName => productName ?? '—';
}

/// One line in the stock ledger, mirroring `InventoryMovementResource`.
class InventoryMovement {
  const InventoryMovement({
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

  bool get isInbound => direction == 'in';
}

/// A stock-take (`adjust`) or a supplier delivery (`receive`).
class StockMovementDraft {
  const StockMovementDraft({
    required this.storeId,
    required this.productVariantId,
    required this.quantity,
    this.inventoryId,
    this.note,
    this.lowStockThreshold,
  });

  final int? inventoryId;
  final int storeId;
  final int productVariantId;
  final int quantity;
  final String? note;
  final int? lowStockThreshold;
}

abstract class InventoryRepository {
  Future<Paginated<InventoryItem>> list({
    bool lowStock = false,
    int? storeId,
    int page = 1,
    int perPage = 20,
  });

  Future<List<InventoryItem>> lowStock({int? storeId, int limit = 10});

  Future<List<InventoryMovement>> movements(
    int inventoryId, {
    int page = 1,
    int perPage = 50,
  });

  Future<InventoryMovement> adjust(StockMovementDraft draft);

  Future<InventoryMovement> receive(StockMovementDraft draft);
}
