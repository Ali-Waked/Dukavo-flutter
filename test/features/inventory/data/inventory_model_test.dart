import 'package:dukavo_mobile/features/inventory/data/inventory_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InventoryModel.fromJson', () {
    test('parses stock with nested product, variant and store', () {
      final item = InventoryModel.fromJson(const {
        'id': 8,
        'store_id': 2,
        'product_id': 4,
        'product_variant_id': 12,
        'quantity': 30,
        'reserved_quantity': 6,
        'available': 24,
        'low_stock_threshold': 10,
        'is_low_stock': false,
        'product': {'name': 'Linen shirt', 'sku': 'LS'},
        'variant': {'name': 'Medium', 'sku': 'LS-M'},
        'store': {'name': 'Dubai Mall'},
        'updated_at': '2024-02-01T09:00:00Z',
      }).toEntity();

      expect(item.id, 8);
      expect(item.storeId, 2);
      expect(item.productVariantId, 12);
      expect(item.quantity, 30);
      expect(item.reserved, 6);
      expect(item.available, 24);
      expect(item.lowStockThreshold, 10);
      expect(item.isLowStock, isFalse);
      expect(item.displayName, 'Linen shirt');
      expect(item.variantName, 'Medium');
      expect(item.variantSku, 'LS-M');
      expect(item.storeName, 'Dubai Mall');
      expect(item.updatedAt, '2024-02-01T09:00:00Z');
    });

    test('tolerates a row without eager-loaded relations', () {
      final item = InventoryModel.fromJson(const {
        'id': 8,
        'store_id': 2,
        'product_id': 4,
        'product_variant_id': 12,
        'quantity': 0,
        'reserved_quantity': 0,
        'available': 0,
        'is_low_stock': true,
      }).toEntity();

      expect(item.productName, isNull);
      expect(item.variantName, isNull);
      expect(item.storeName, isNull);
      expect(item.lowStockThreshold, isNull);
      expect(item.isLowStock, isTrue);
      expect(item.displayName, '—');
    });
  });

  group('InventoryMovementModel.fromJson', () {
    test('parses a movement with its balance and actor', () {
      final movement = InventoryMovementModel.fromJson(const {
        'id': 90,
        'inventory_id': 8,
        'type': 'receive',
        'type_label': 'Received',
        'quantity': 25,
        'direction': 'in',
        'balance_after': 30,
        'source': 'purchase_order',
        'note': 'Restock',
        'user': {'name': 'Sara Hassan'},
        'created_at': '2024-02-01T09:00:00Z',
      }).toEntity();

      expect(movement.id, 90);
      expect(movement.inventoryId, 8);
      expect(movement.type, 'receive');
      expect(movement.typeLabel, 'Received');
      expect(movement.quantity, 25);
      expect(movement.direction, 'in');
      expect(movement.balanceAfter, 30);
      expect(movement.source, 'purchase_order');
      expect(movement.userName, 'Sara Hassan');
    });

    test('defaults direction and type for a sparse payload', () {
      final movement = InventoryMovementModel.fromJson(const {}).toEntity();

      expect(movement.type, 'adjustment');
      expect(movement.typeLabel, 'adjustment');
      expect(movement.direction, 'in');
      expect(movement.balanceAfter, 0);
      expect(movement.userName, isNull);
    });
  });
}
