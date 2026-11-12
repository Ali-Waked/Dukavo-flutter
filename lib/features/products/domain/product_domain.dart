import '../../../core/api/paginated.dart';

/// The catalogue's domain models, mirroring `ProductResource`.
class ProductStock {
  const ProductStock({
    required this.quantity,
    required this.reserved,
    required this.available,
  });

  final int quantity;
  final int reserved;
  final int available;

  static const empty = ProductStock(quantity: 0, reserved: 0, available: 0);
}

class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.name,
    required this.price,
    required this.cost,
    required this.isDefault,
    this.description,
    this.sku,
    this.barcode,
    this.stock = ProductStock.empty,
  });

  final int id;
  final String name;
  final String? description;
  final String? sku;
  final String? barcode;
  final num price;
  final num cost;
  final bool isDefault;
  final ProductStock stock;
}

class ProductImage {
  const ProductImage({
    required this.id,
    required this.url,
    required this.isPrimary,
    this.altText,
    this.caption,
  });

  final int id;
  final String url;
  final String? altText;
  final String? caption;
  final bool isPrimary;
}

class ProductSpecification {
  const ProductSpecification({required this.label, required this.value});

  final String label;
  final String value;

  Map<String, dynamic> toJson() => {'label': label, 'value': value};
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    required this.price,
    required this.cost,
    required this.currency,
    this.storeId,
    this.categoryId,
    this.categoryName,
    this.sku,
    this.description,
    this.shortDescription,
    this.highlights = const [],
    this.features = const [],
    this.specifications = const [],
    this.tags = const [],
    this.seoTitle,
    this.seoDescription,
    this.seoKeywords,
    this.localizedSlugs = const {},
    this.statusLabel,
    this.isTaxable = true,
    this.variants = const [],
    this.images = const [],
    this.stock = ProductStock.empty,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int? storeId;
  final int? categoryId;
  final String? categoryName;
  final String name;
  final String slug;
  final String? sku;
  final String? description;
  final String? shortDescription;
  final List<String> highlights;
  final List<String> features;
  final List<ProductSpecification> specifications;
  final List<String> tags;
  final String? seoTitle;
  final String? seoDescription;
  final String? seoKeywords;
  final Map<String, String> localizedSlugs;
  final String status;
  final String? statusLabel;
  final num price;
  final num cost;
  final String currency;
  final bool isTaxable;
  final List<ProductVariant> variants;
  final List<ProductImage> images;
  final ProductStock stock;
  final String? createdAt;
  final String? updatedAt;

  String? get primaryImageUrl {
    for (final image in images) {
      if (image.isPrimary) return image.url;
    }
    return images.isEmpty ? null : images.first.url;
  }
}

/// One variant line in the product form. `id` is present when editing so the
/// server updates it in place instead of replacing its inventory record.
class ProductVariantDraft {
  const ProductVariantDraft({
    required this.name,
    required this.price,
    this.id,
    this.description,
    this.sku,
    this.barcode,
    this.cost,
    this.isDefault = false,
    this.initialQuantity,
  });

  final int? id;
  final String name;
  final String? description;
  final String? sku;
  final String? barcode;
  final num price;
  final num? cost;
  final bool isDefault;
  final int? initialQuantity;
}

class ProductDraft {
  const ProductDraft({
    required this.name,
    this.slug,
    this.sku,
    this.description,
    this.shortDescription,
    this.highlights = const [],
    this.features = const [],
    this.specifications = const [],
    this.tags = const [],
    this.seoTitle,
    this.seoDescription,
    this.seoKeywords,
    this.status = 'active',
    this.price = 0,
    this.cost = 0,
    this.currency,
    this.isTaxable = true,
    this.categoryId,
    this.storeId,
    this.variants = const [],
  });

  final String name;
  final String? slug;
  final String? sku;
  final String? description;
  final String? shortDescription;
  final List<String> highlights;
  final List<String> features;
  final List<ProductSpecification> specifications;
  final List<String> tags;
  final String? seoTitle;
  final String? seoDescription;
  final String? seoKeywords;
  final String status;
  final num price;
  final num cost;
  final String? currency;
  final bool isTaxable;
  final int? categoryId;
  final int? storeId;
  final List<ProductVariantDraft> variants;
}

class SlugAvailability {
  const SlugAvailability({required this.slug, required this.available});

  final String slug;
  final bool available;
}

abstract class ProductRepository {
  Future<Paginated<Product>> list({
    String? search,
    String? status,
    int? categoryId,
    bool lowStock = false,
    int page = 1,
    int perPage = 20,
  });

  Future<Product> get(String slug);

  Future<Product> create(ProductDraft draft);

  Future<Product> update(String slug, ProductDraft draft);

  Future<void> delete(String slug, {bool force = false});

  Future<SlugAvailability> checkSlug(String slug, {int? ignore});
}
