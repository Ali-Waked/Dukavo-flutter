import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/paginated.dart';
import '../../../core/pagination/paginated_notifier.dart';
import '../../../core/providers.dart';
import '../data/customer_data.dart';
import '../domain/customer_domain.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(
    CustomerRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

class CustomerListNotifier extends PaginatedNotifier<Customer> {
  CustomerListNotifier(this._repository);

  final CustomerRepository _repository;

  String? search;
  String? status;

  @override
  Future<Paginated<Customer>> fetchPage(int page) {
    return _repository.list(search: search, status: status, page: page);
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
}

final customerListProvider =
    StateNotifierProvider<CustomerListNotifier, PaginatedState<Customer>>((ref) {
  return CustomerListNotifier(ref.watch(customerRepositoryProvider));
});

final customerDetailProvider =
    FutureProvider.family<Customer, int>((ref, id) {
  return ref.watch(customerRepositoryProvider).get(id);
});

/// Every customer, for pickers in the order builder. Separate from the paged
/// list because a picker needs the whole set, not a page of it.
final customerOptionsProvider = FutureProvider<List<Customer>>((ref) async {
  final page = await ref.watch(customerRepositoryProvider).list(perPage: 100);
  return page.items;
});

class CustomerActions {
  CustomerActions(this._ref);

  final Ref _ref;

  Future<Customer> create(CustomerDraft draft) async {
    final customer = await _ref.read(customerRepositoryProvider).create(draft);
    _invalidate();
    return customer;
  }

  Future<Customer> update(int id, CustomerDraft draft) async {
    final customer =
        await _ref.read(customerRepositoryProvider).update(id, draft);
    _invalidate();
    _ref.invalidate(customerDetailProvider(id));
    return customer;
  }

  Future<void> delete(int id) async {
    await _ref.read(customerRepositoryProvider).delete(id);
    _invalidate();
  }

  void _invalidate() {
    _ref.invalidate(customerListProvider);
    _ref.invalidate(customerOptionsProvider);
  }
}

final customerActionsProvider = Provider<CustomerActions>(CustomerActions.new);
