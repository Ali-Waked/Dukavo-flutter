/// Categories, mirroring `CategoryResource`.
class Category {
  const Category({
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
  final List<Category> children;

  /// Flattens the tree for pickers, keeping parents before children.
  static List<Category> flatten(List<Category> roots) {
    final result = <Category>[];
    void walk(Category node) {
      result.add(node);
      for (final child in node.children) {
        walk(child);
      }
    }

    for (final root in roots) {
      walk(root);
    }
    return result;
  }
}

class CategoryDraft {
  const CategoryDraft({
    required this.name,
    this.slug,
    this.parentId,
    this.description,
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String name;
  final String? slug;
  final int? parentId;
  final String? description;
  final bool isActive;
  final int sortOrder;
}

class CategorySlugAvailability {
  const CategorySlugAvailability({
    required this.slug,
    required this.available,
  });

  final String slug;
  final bool available;
}

abstract class CategoryRepository {
  Future<List<Category>> fetchAll({bool includeInactive = false});

  Future<List<Category>> tree({bool includeInactive = false});

  Future<Category> create(CategoryDraft draft);

  Future<Category> update(int id, CategoryDraft draft);

  Future<void> delete(int id);

  Future<CategorySlugAvailability> checkSlug(String slug, {int? ignore});
}
