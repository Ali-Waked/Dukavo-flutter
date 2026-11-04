import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/customer_crm_data.dart';
import '../domain/customer_crm_domain.dart';

final customerCrmRepositoryProvider = Provider<CustomerCrmRepository>((ref) {
  return CustomerCrmRepositoryImpl(
    CustomerCrmRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final customerCrmOverviewProvider =
    FutureProvider.autoDispose.family<CustomerCrmOverview, int>((ref, id) {
  return ref.watch(customerCrmRepositoryProvider).overview(id);
});

final customerTimelineProvider = FutureProvider.autoDispose
    .family<List<CustomerTimelineEntry>, int>((ref, id) {
  return ref.watch(customerCrmRepositoryProvider).timeline(id);
});

final customerMemoriesProvider =
    FutureProvider.autoDispose.family<List<CustomerMemory>, int>((ref, id) {
  return ref.watch(customerCrmRepositoryProvider).memories(id);
});

class CustomerCrmActions {
  CustomerCrmActions(this._ref);

  final Ref _ref;

  Future<CustomerSummary> refreshSummary(int customerId) async {
    final summary = await _ref
        .read(customerCrmRepositoryProvider)
        .refreshSummary(customerId);
    _invalidateOverview(customerId);
    return summary;
  }

  Future<CustomerSummary> updateSummary(int customerId, String summary) async {
    final updated = await _ref
        .read(customerCrmRepositoryProvider)
        .updateSummary(customerId, summary);
    _invalidateOverview(customerId);
    return updated;
  }

  Future<CustomerMemory> createMemory(
    int customerId,
    CustomerMemoryDraft draft,
  ) async {
    final memory = await _ref
        .read(customerCrmRepositoryProvider)
        .createMemory(customerId, draft);
    _ref.invalidate(customerMemoriesProvider(customerId));
    _invalidateOverview(customerId);
    return memory;
  }

  Future<CustomerMemory> updateMemory(
    int customerId,
    int memoryId,
    CustomerMemoryDraft draft,
  ) async {
    final memory = await _ref
        .read(customerCrmRepositoryProvider)
        .updateMemory(customerId, memoryId, draft);
    _ref.invalidate(customerMemoriesProvider(customerId));
    return memory;
  }

  Future<void> deleteMemory(int customerId, int memoryId) async {
    await _ref
        .read(customerCrmRepositoryProvider)
        .deleteMemory(customerId, memoryId);
    _ref.invalidate(customerMemoriesProvider(customerId));
    _invalidateOverview(customerId);
  }

  void _invalidateOverview(int customerId) {
    _ref.invalidate(customerCrmOverviewProvider(customerId));
  }
}

final customerCrmActionsProvider =
    Provider<CustomerCrmActions>(CustomerCrmActions.new);
