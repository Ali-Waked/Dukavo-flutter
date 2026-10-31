import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/category_data.dart';
import '../domain/category_domain.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(
    CategoryRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

/// The flat, ordered list used by pickers and the product form.
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).fetchAll();
});

/// The nested tree used by the category manager.
final categoryTreeProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).tree();
});

/// Mutations followed by a refresh of both shapes.
class CategoryActions {
  CategoryActions(this._ref);

  final Ref _ref;

  Future<Category> create(CategoryDraft draft) async {
    final created = await _ref.read(categoryRepositoryProvider).create(draft);
    _refresh();
    return created;
  }

  Future<Category> update(int id, CategoryDraft draft) async {
    final updated = await _ref.read(categoryRepositoryProvider).update(id, draft);
    _refresh();
    return updated;
  }

  Future<void> delete(int id) async {
    await _ref.read(categoryRepositoryProvider).delete(id);
    _refresh();
  }

  void _refresh() {
    _ref.invalidate(categoriesProvider);
    _ref.invalidate(categoryTreeProvider);
  }
}

final categoryActionsProvider = Provider<CategoryActions>(CategoryActions.new);
