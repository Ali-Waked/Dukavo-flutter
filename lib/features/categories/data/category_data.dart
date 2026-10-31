import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/category_domain.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.isActive,
    required this.sortOrder,
    this.parentId,
    this.parentName,
    this.description,
    this.productsCount,
    this.children = const [],
  });

  final int id;
  final int? parentId;
  final String? parentName;
  final String name;
  final String slug;
  final String? description;
  final bool isActive;
  final int sortOrder;
  final int? productsCount;
  final List<CategoryModel> children;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawParent = json['parent'];
    final rawChildren = json['children'];
    return CategoryModel(
      id: _int(json['id']),
      parentId: _nullableInt(json['parent_id']),
      parentName: rawParent is Map ? '${rawParent['name'] ?? ''}' : null,
      name: '${json['name'] ?? ''}',
      slug: '${json['slug'] ?? ''}',
      description: json['description'] as String?,
      isActive: json['is_active'] != false,
      sortOrder: _int(json['sort_order']),
      productsCount: _nullableInt(json['products_count']),
      children: rawChildren is List
          ? rawChildren
              .whereType<Map>()
              .map((entry) => CategoryModel.fromJson(
                    Map<String, dynamic>.from(entry),
                  ))
              .toList()
          : const [],
    );
  }

  Category toEntity() => Category(
        id: id,
        parentId: parentId,
        parentName: parentName,
        name: name,
        slug: slug,
        description: description,
        isActive: isActive,
        sortOrder: sortOrder,
        productsCount: productsCount,
        children: children.map((child) => child.toEntity()).toList(),
      );

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static int? _nullableInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }
}

class CategoryRemoteDataSource {
  CategoryRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<Category>> fetchAll({bool includeInactive = false}) async {
    final data = await _api.get<List<dynamic>>(
      ApiPaths.categories,
      query: {if (includeInactive) 'include_inactive': 1},
      decode: (raw) => raw is List ? raw : const <dynamic>[],
    );
    return data
        .whereType<Map>()
        .map((entry) => CategoryModel.fromJson(Map<String, dynamic>.from(entry)).toEntity())
        .toList();
  }

  Future<List<Category>> tree({bool includeInactive = false}) async {
    final data = await _api.get<List<dynamic>>(
      ApiPaths.categoryTree,
      query: {if (includeInactive) 'include_inactive': 1},
      decode: (raw) => raw is List ? raw : const <dynamic>[],
    );
    return data
        .whereType<Map>()
        .map((entry) => CategoryModel.fromJson(Map<String, dynamic>.from(entry)).toEntity())
        .toList();
  }

  Future<Category> create(CategoryDraft draft) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.categories,
      body: _payload(draft),
      decode: _asMap,
    );
    return CategoryModel.fromJson(data).toEntity();
  }

  Future<Category> update(int id, CategoryDraft draft) async {
    final data = await _api.patch<Map<String, dynamic>>(
      '${ApiPaths.categories}/$id',
      body: _payload(draft),
      decode: _asMap,
    );
    return CategoryModel.fromJson(data).toEntity();
  }

  Future<void> delete(int id) {
    return _api.delete('${ApiPaths.categories}/$id');
  }

  Future<CategorySlugAvailability> checkSlug(String slug, {int? ignore}) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.categorySlugAvailability,
      query: {
        'slug': slug,
        if (ignore != null) 'ignore': ignore,
      },
      decode: _asMap,
    );
    return CategorySlugAvailability(
      slug: '${data['slug'] ?? slug}',
      available: data['available'] == true,
    );
  }

  Map<String, dynamic> _payload(CategoryDraft draft) {
    return {
      'name': draft.name,
      if (draft.slug != null && draft.slug!.trim().isNotEmpty)
        'slug': draft.slug!.trim(),
      'parent_id': draft.parentId,
      if (draft.description != null) 'description': draft.description,
      'is_active': draft.isActive,
      'sort_order': draft.sortOrder,
    };
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._remote);

  final CategoryRemoteDataSource _remote;

  @override
  Future<List<Category>> fetchAll({bool includeInactive = false}) =>
      _remote.fetchAll(includeInactive: includeInactive);

  @override
  Future<List<Category>> tree({bool includeInactive = false}) =>
      _remote.tree(includeInactive: includeInactive);

  @override
  Future<Category> create(CategoryDraft draft) => _remote.create(draft);

  @override
  Future<Category> update(int id, CategoryDraft draft) =>
      _remote.update(id, draft);

  @override
  Future<void> delete(int id) => _remote.delete(id);

  @override
  Future<CategorySlugAvailability> checkSlug(String slug, {int? ignore}) =>
      _remote.checkSlug(slug, ignore: ignore);
}
