import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../api/paginated.dart';
import '../pagination/paginated_notifier.dart';
import 'json_resource.dart';
import 'resource_spec.dart';

/// Pagination, search and pull-to-refresh for a [ResourceSpec].
///
/// Kept as a [ChangeNotifier] rather than a family provider so each screen owns
/// exactly one pager and disposes it with the screen.
class ResourcePager extends ChangeNotifier {
  ResourcePager(this._api, this.spec);

  final ApiClient _api;
  final ResourceSpec spec;

  PaginatedState<JsonResource> state = const PaginatedState<JsonResource>();
  String search = '';
  final Map<String, String> filterValues = <String, String>{};
  bool _disposed = false;

  Future<void> loadInitial() async {
    if (state.isLoading) return;
    _emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final page = await _fetch(1);
      _emit(PaginatedState<JsonResource>(
        items: page.items,
        currentPage: page.meta.currentPage,
        lastPage: page.meta.lastPage,
        total: page.meta.total,
      ));
    } catch (error) {
      _emit(state.copyWith(isLoading: false, error: _message(error)));
    }
  }

  Future<void> reload() async {
    _emit(const PaginatedState<JsonResource>());
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore ||
        state.items.isEmpty) {
      return;
    }
    _emit(state.copyWith(isLoadingMore: true, clearError: true));
    try {
      final page = await _fetch(state.currentPage + 1);
      _emit(state.copyWith(
        items: <JsonResource>[...state.items, ...page.items],
        isLoadingMore: false,
        currentPage: page.meta.currentPage,
        lastPage: page.meta.lastPage,
        total: page.meta.total,
      ));
    } catch (error) {
      _emit(state.copyWith(isLoadingMore: false, error: _message(error)));
    }
  }

  void setSearch(String value) {
    final next = value.trim();
    if (next == search) return;
    search = next;
    reload();
  }

  void setFilter(String param, String? value) {
    final next = value?.trim() ?? '';
    if ((filterValues[param] ?? '') == next) return;
    if (next.isEmpty) {
      filterValues.remove(param);
    } else {
      filterValues[param] = next;
    }
    reload();
  }

  Future<void> refresh() => reload();

  Future<Paginated<JsonResource>> _fetch(int page) {
    return _api.list<JsonResource>(
      spec.path,
      query: <String, dynamic>{
        ...spec.extraQuery,
        ...filterValues,
        if (spec.searchable && search.isNotEmpty) spec.searchParam: search,
        'page': page,
        'per_page': 20,
      },
      item: JsonResource.fromJson,
    );
  }

  String _message(Object error) {
    if (error is ApiException) return error.message;
    return 'Something went wrong. Please try again.';
  }

  void _emit(PaginatedState<JsonResource> next) {
    if (_disposed) return;
    state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
