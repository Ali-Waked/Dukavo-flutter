import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/customer_crm_domain.dart';
import 'customer_data.dart';

class CustomerCrmRemoteDataSource {
  CustomerCrmRemoteDataSource(this._api);

  final ApiClient _api;

  Future<CustomerCrmOverview> overview(int customerId) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.customerCrmOverview(customerId),
      decode: _asMap,
    );
    final rawCustomer = data['customer'];
    final customer = CustomerModel.fromJson(
      rawCustomer is Map
          ? Map<String, dynamic>.from(rawCustomer)
          : const <String, dynamic>{},
    ).toEntity();
    return CustomerCrmOverview.fromJson(data, customer);
  }

  Future<List<CustomerTimelineEntry>> timeline(int customerId) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.customerCrmTimeline(customerId),
      decode: _asMap,
    );
    final raw = data['items'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((entry) =>
            CustomerTimelineEntry.fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }

  Future<CustomerSummary> summary(int customerId) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.customerCrmSummary(customerId),
      decode: _asMap,
    );
    return CustomerSummary.fromJson(data);
  }

  Future<CustomerSummary> refreshSummary(int customerId) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.customerCrmSummaryRefresh(customerId),
      decode: _asMap,
    );
    return CustomerSummary.fromJson(data);
  }

  Future<CustomerSummary> updateSummary(
    int customerId,
    String summary,
  ) async {
    final data = await _api.patch<Map<String, dynamic>>(
      ApiPaths.customerCrmSummary(customerId),
      body: {'summary': summary},
      decode: _asMap,
    );
    return CustomerSummary.fromJson(data);
  }

  Future<List<CustomerMemory>> memories(int customerId) async {
    final data = await _api.get<List<CustomerMemory>>(
      ApiPaths.customerMemories(customerId),
      decode: (raw) {
        if (raw is! List) return const <CustomerMemory>[];
        return raw
            .whereType<Map>()
            .map((entry) =>
                CustomerMemory.fromJson(Map<String, dynamic>.from(entry)))
            .toList();
      },
    );
    return data;
  }

  Future<CustomerMemory> createMemory(
    int customerId,
    CustomerMemoryDraft draft,
  ) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.customerMemories(customerId),
      body: _memoryPayload(draft),
      decode: _asMap,
    );
    return CustomerMemory.fromJson(data);
  }

  Future<CustomerMemory> updateMemory(
    int customerId,
    int memoryId,
    CustomerMemoryDraft draft,
  ) async {
    final data = await _api.patch<Map<String, dynamic>>(
      ApiPaths.customerMemory(customerId, memoryId),
      body: _memoryPayload(draft),
      decode: _asMap,
    );
    return CustomerMemory.fromJson(data);
  }

  Future<void> deleteMemory(int customerId, int memoryId) =>
      _api.delete(ApiPaths.customerMemory(customerId, memoryId));

  static Map<String, dynamic> _memoryPayload(CustomerMemoryDraft draft) {
    return {
      'key': draft.key,
      'value': draft.value,
      'category': draft.category,
      'source': draft.source,
      if (draft.confidence != null) 'confidence': draft.confidence,
    };
  }

  static Map<String, dynamic> _asMap(Object? value) {
    return value is Map ? Map<String, dynamic>.from(value) : const {};
  }
}

abstract class CustomerCrmRepository {
  Future<CustomerCrmOverview> overview(int customerId);

  Future<List<CustomerTimelineEntry>> timeline(int customerId);

  Future<CustomerSummary> summary(int customerId);

  Future<CustomerSummary> refreshSummary(int customerId);

  Future<CustomerSummary> updateSummary(int customerId, String summary);

  Future<List<CustomerMemory>> memories(int customerId);

  Future<CustomerMemory> createMemory(
    int customerId,
    CustomerMemoryDraft draft,
  );

  Future<CustomerMemory> updateMemory(
    int customerId,
    int memoryId,
    CustomerMemoryDraft draft,
  );

  Future<void> deleteMemory(int customerId, int memoryId);
}

class CustomerCrmRepositoryImpl implements CustomerCrmRepository {
  CustomerCrmRepositoryImpl(this._remote);

  final CustomerCrmRemoteDataSource _remote;

  @override
  Future<CustomerCrmOverview> overview(int customerId) =>
      _remote.overview(customerId);

  @override
  Future<List<CustomerTimelineEntry>> timeline(int customerId) =>
      _remote.timeline(customerId);

  @override
  Future<CustomerSummary> summary(int customerId) =>
      _remote.summary(customerId);

  @override
  Future<CustomerSummary> refreshSummary(int customerId) =>
      _remote.refreshSummary(customerId);

  @override
  Future<CustomerSummary> updateSummary(int customerId, String summary) =>
      _remote.updateSummary(customerId, summary);

  @override
  Future<List<CustomerMemory>> memories(int customerId) =>
      _remote.memories(customerId);

  @override
  Future<CustomerMemory> createMemory(
    int customerId,
    CustomerMemoryDraft draft,
  ) =>
      _remote.createMemory(customerId, draft);

  @override
  Future<CustomerMemory> updateMemory(
    int customerId,
    int memoryId,
    CustomerMemoryDraft draft,
  ) =>
      _remote.updateMemory(customerId, memoryId, draft);

  @override
  Future<void> deleteMemory(int customerId, int memoryId) =>
      _remote.deleteMemory(customerId, memoryId);
}
