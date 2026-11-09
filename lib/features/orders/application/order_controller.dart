import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/paginated.dart';
import '../../../core/pagination/paginated_notifier.dart';
import '../../../core/providers.dart';
import '../data/order_data.dart';
import '../domain/order_domain.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
    OrderRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

class OrderListNotifier extends PaginatedNotifier<Order> {
  OrderListNotifier(this._repository, this._ref);

  final OrderRepository _repository;
  final Ref _ref;

  String? search;
  String? status;

  @override
  Future<Paginated<Order>> fetchPage(int page) {
    return _repository.list(
      search: search,
      status: status,
      page: page,
    );
  }

  Future<void> setSearch(String value) async {
    final next = value.trim().isEmpty ? null : value.trim();
    if (next == search) return;
    search = next;
    await reload();
  }

  Future<void> setStatus(String? value) async {
    if (value == status) return;
    status = value;
    await reload();
  }

  Future<void> applyUpdated(Order order) async {
    state = state.copyWith(
      items: state.items
          .map((item) => item.id == order.id ? order : item)
          .toList(),
    );
    _ref.invalidate(orderDetailProvider(order.orderNumber));
  }
}

final orderListProvider =
    StateNotifierProvider<OrderListNotifier, PaginatedState<Order>>((ref) {
  final notifier = OrderListNotifier(ref.watch(orderRepositoryProvider), ref);
  refreshOnReconnect(ref, notifier.reload);
  return notifier;
});

final orderDetailProvider =
    FutureProvider.family<Order, String>((ref, orderNumber) {
  return ref.watch(orderRepositoryProvider).get(orderNumber);
});

final orderTransitionsProvider =
    FutureProvider.family<OrderTransitions, int>((ref, id) {
  return ref.watch(orderRepositoryProvider).transitions(id);
});

class OrderActions {
  OrderActions(this._ref);

  final Ref _ref;

  Future<Order> create(OrderDraft draft) async {
    final order = await _ref.read(orderRepositoryProvider).create(draft);
    _ref.invalidate(orderListProvider);
    return order;
  }

  Future<Order> transition(
    Order order, {
    required String status,
    String? note,
    String? paymentStatus,
  }) async {
    final updated = await _ref.read(orderRepositoryProvider).transition(
          order.id,
          status: status,
          note: note,
          paymentStatus: paymentStatus,
        );
    _ref.invalidate(orderListProvider);
    _ref.invalidate(orderDetailProvider(order.orderNumber));
    _ref.invalidate(orderTransitionsProvider(order.id));
    return updated;
  }

  Future<void> delete(Order order) async {
    await _ref.read(orderRepositoryProvider).delete(order.id);
    _ref.invalidate(orderListProvider);
  }
}

final orderActionsProvider = Provider<OrderActions>(OrderActions.new);
