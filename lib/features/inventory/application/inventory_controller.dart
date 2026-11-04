import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/paginated.dart';
import '../../../core/pagination/paginated_notifier.dart';
import '../../../core/providers.dart';
import '../data/inventory_data.dart';
import '../domain/inventory_domain.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl(
    InventoryRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

class InventoryListNotifier extends PaginatedNotifier<InventoryItem> {
  InventoryListNotifier(this._repository);

  final InventoryRepository _repository;

  bool lowStockOnly = false;

  @override
  Future<Paginated<InventoryItem>> fetchPage(int page) {
    return _repository.list(lowStock: lowStockOnly, page: page);
  }

  Future<void> setLowStockOnly(bool value) async {
    if (value == lowStockOnly) return;
    lowStockOnly = value;
    await reload();
  }
}

final inventoryListProvider =
    StateNotifierProvider<InventoryListNotifier, PaginatedState<InventoryItem>>(
        (ref) {
  return InventoryListNotifier(ref.watch(inventoryRepositoryProvider));
});

final inventoryMovementsProvider =
    FutureProvider.family<List<InventoryMovement>, int>((ref, inventoryId) {
  return ref.watch(inventoryRepositoryProvider).movements(inventoryId);
});

class InventoryActions {
  InventoryActions(this._ref);

  final Ref _ref;

  Future<InventoryMovement> adjust(StockMovementDraft draft) async {
    final movement = await _ref.read(inventoryRepositoryProvider).adjust(draft);
    _refresh(draft.inventoryId);
    return movement;
  }

  Future<InventoryMovement> receive(StockMovementDraft draft) async {
    final movement =
        await _ref.read(inventoryRepositoryProvider).receive(draft);
    _refresh(draft.inventoryId);
    return movement;
  }

  void _refresh(int? inventoryId) {
    _ref.invalidate(inventoryListProvider);
    if (inventoryId != null) {
      _ref.invalidate(inventoryMovementsProvider(inventoryId));
    }
  }
}

final inventoryActionsProvider =
    Provider<InventoryActions>(InventoryActions.new);
