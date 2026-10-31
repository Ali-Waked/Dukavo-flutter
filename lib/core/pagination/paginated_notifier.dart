import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_exception.dart';
import '../api/paginated.dart';

/// The state shared by every paginated list screen.
class PaginatedState<T> {
  const PaginatedState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  final List<T> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;
  bool get isEmpty => items.isEmpty;

  PaginatedState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    int? currentPage,
    int? lastPage,
    int? total,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
    );
  }
}

/// A `StateNotifier` that owns the "page 1, then page 2, …" dance.
///
/// Subclasses only implement [fetchPage]; filters and search text live in the
/// subclass and call [reload] when they change.
abstract class PaginatedNotifier<T> extends StateNotifier<PaginatedState<T>> {
  PaginatedNotifier() : super(const PaginatedState<T>());

  Future<Paginated<T>> fetchPage(int page);

  Future<void> loadInitial() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await fetchPage(1);
      state = PaginatedState<T>(
        items: page.items,
        currentPage: page.meta.currentPage,
        lastPage: page.meta.lastPage,
        total: page.meta.total,
      );
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, error: error.message);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> reload() async {
    state = state.copyWith(
      isLoading: false,
      isLoadingMore: false,
      clearError: true,
      currentPage: 1,
      lastPage: 1,
      items: const [],
    );
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final page = await fetchPage(state.currentPage + 1);
      state = state.copyWith(
        items: <T>[...state.items, ...page.items],
        isLoadingMore: false,
        currentPage: page.meta.currentPage,
        lastPage: page.meta.lastPage,
        total: page.meta.total,
      );
    } on ApiException catch (error) {
      state = state.copyWith(isLoadingMore: false, error: error.message);
    } catch (_) {
      state = state.copyWith(
        isLoadingMore: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }
}
