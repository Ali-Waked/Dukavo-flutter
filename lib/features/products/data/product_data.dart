import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/api/paginated.dart';
import '../domain/product_domain.dart';

class ProductModel {
  const ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'];
    final rawVariants = json['variants'];
    final rawImages = json['images'];
    final rawStock = json['stock'];
    final rawHighlights = json['highlights'];
    final rawFeatures = json['features'];
    final rawSpecifications = json['specifications'];
    final rawTags = json['tags'];
    final rawSlugs = json['localized_slugs'];

    return ProductModel(
      id: _int(json['id']),
      storeId: _nullableInt(json['store_id']),
      categoryId: _nullableInt(json['category_id']),
      categoryName: rawCategory is Map ? '${rawCategory['name'] ?? ''}' : null,
      name: '${json['name'] ?? ''}',
      slug: '${json['slug'] ?? ''}',
      sku: json['sku'] as String?,
      description: json['description'] as String?,
      shortDescription: json['short_description'] as String?,
      highlights: _stringList(rawHighlights),
      features: _stringList(rawFeatures),
      specifications: rawSpecifications is List
          ? rawSpecifications
              .whereType<Map>()
              .map((entry) => ProductSpecification(
                    label: '${entry['label'] ?? ''}',
                    value: '${entry['value'] ?? ''}',
                  ))
              .toList(growable: false)
          : const [],
      tags: _stringList(rawTags),
      seoTitle: json['seo_title'] as String?,
      seoDescription: json['seo_description'] as String?,
      seoKeywords: json['seo_keywords'] as String?,
      localizedSlugs: rawSlugs is Map
          ? rawSlugs.map((key, value) => MapEntry('$key', '$value'))
          : const {},
      status: '${json['status'] ?? 'active'}',
      statusLabel: json['status_label'] as String?,
      price: _num(json['price']),
      cost: _num(json['cost']),
      currency: '${json['currency'] ?? 'USD'}',
      isTaxable: json['is_taxable'] != false,
      variants: rawVariants is List
          ? rawVariants
              .whereType<Map>()
              .map((entry) => _variant(Map<String, dynamic>.from(entry)))
              .toList()
          : const [],
      images: rawImages is List
          ? rawImages
              .whereType<Map>()
              .map((entry) => _image(Map<String, dynamic>.from(entry)))
              .toList()
          : const [],
      stock: rawStock is Map
          ? _stock(Map<String, dynamic>.from(rawStock))
          : ProductStock.empty,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Product toEntity() => Product(
        id: id,
        storeId: storeId,
        categoryId: categoryId,
        categoryName: categoryName,
        name: name,
        slug: slug,
        sku: sku,
        description: description,
        shortDescription: shortDescription,
        highlights: highlights,
        features: features,
        specifications: specifications,
        tags: tags,
        seoTitle: seoTitle,
        seoDescription: seoDescription,
        seoKeywords: seoKeywords,
        localizedSlugs: localizedSlugs,
        status: status,
        statusLabel: statusLabel,
        price: price,
        cost: cost,
        currency: currency,
        isTaxable: isTaxable,
        variants: variants,
        images: images,
        stock: stock,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static ProductVariant _variant(Map<String, dynamic> json) {
    final rawStock = json['stock'];
    return ProductVariant(
      id: _int(json['id']),
      name: '${json['name'] ?? ''}',
      description: json['description'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      price: _num(json['price']),
      cost: _num(json['cost']),
      isDefault: json['is_default'] == true,
      stock: rawStock is Map
          ? _stock(Map<String, dynamic>.from(rawStock))
          : ProductStock.empty,
    );
  }

  static ProductImage _image(Map<String, dynamic> json) {
    return ProductImage(
      id: _int(json['id']),
      url: '${json['url'] ?? ''}',
      altText: json['alt_text'] as String?,
      caption: json['caption'] as String?,
      isPrimary: json['is_primary'] == true,
    );
  }

  static ProductStock _stock(Map<String, dynamic> json) {
    return ProductStock(
      quantity: _int(json['quantity']),
      reserved: _int(json['reserved']),
      available: _int(json['available']),
    );
  }

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

  static num _num(Object? value) {
    if (value is num) return value;
    return num.tryParse('$value') ?? 0;
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value
        .map((entry) => '$entry'.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
  }
}

class ProductRemoteDataSource {
  ProductRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Paginated<Product>> list({
    String? search,
    String? status,
    int? categoryId,
    bool lowStock = false,
    int page = 1,
    int perPage = 20,
  }) {
    return _api.list<Product>(
      ApiPaths.products,
      query: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.isNotEmpty) 'status': status,
        if (categoryId != null) 'category_id': categoryId,
        if (lowStock) 'low_stock': 1,
      },
      item: (json) => ProductModel.fromJson(json).toEntity(),
    );
  }

  Future<Product> get(String slug) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.product(slug),
      decode: _asMap,
    );
    return ProductModel.fromJson(data).toEntity();
  }

  Future<Product> create(ProductDraft draft) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.products,
      body: _payload(draft),
      decode: _asMap,
    );
    return ProductModel.fromJson(data).toEntity();
  }

  Future<Product> update(String slug, ProductDraft draft) async {
    final data = await _api.patch<Map<String, dynamic>>(
      ApiPaths.product(slug),
      body: _payload(draft),
      decode: _asMap,
    );
    return ProductModel.fromJson(data).toEntity();
  }

  Future<void> delete(String slug, {bool force = false}) {
    return _api.delete(
      ApiPaths.product(slug),
      query: force ? {'force': 1} : null,
    );
  }

  Future<SlugAvailability> checkSlug(String slug, {int? ignore}) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.productSlugAvailability,
      query: {
        'slug': slug,
        if (ignore != null) 'ignore': ignore,
      },
      decode: _asMap,
    );
    return SlugAvailability(
      slug: '${data['slug'] ?? slug}',
      available: data['available'] == true,
    );
  }

  Map<String, dynamic> _payload(ProductDraft draft) {
    return {
      'name': draft.name,
      if (draft.slug != null && draft.slug!.trim().isNotEmpty)
        'slug': draft.slug!.trim(),
      if (draft.sku != null) 'sku': draft.sku,
      if (draft.description != null) 'description': draft.description,
      if (draft.shortDescription != null)
        'short_description': draft.shortDescription,
      'highlights': draft.highlights,
      'features': draft.features,
      'specifications':
          draft.specifications.map((entry) => entry.toJson()).toList(),
      'tags': draft.tags,
      if (draft.seoTitle != null) 'seo_title': draft.seoTitle,
      if (draft.seoDescription != null) 'seo_description': draft.seoDescription,
      if (draft.seoKeywords != null) 'seo_keywords': draft.seoKeywords,
      'status': draft.status,
      'price': draft.price,
      'cost': draft.cost,
      if (draft.currency != null) 'currency': draft.currency,
      'is_taxable': draft.isTaxable,
      'category_id': draft.categoryId,
      'store_id': draft.storeId,
      if (draft.variants.isNotEmpty)
        'variants': draft.variants
            .map((variant) => {
                  if (variant.id != null) 'id': variant.id,
                  'name': variant.name,
                  if (variant.description != null)
                    'description': variant.description,
                  'sku': variant.sku,
                  'barcode': variant.barcode,
                  'price': variant.price,
                  'cost': variant.cost,
                  'is_default': variant.isDefault,
                  if (variant.initialQuantity != null)
                    'initial_quantity': variant.initialQuantity,
                })
            .toList(),
    };
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  Future<Paginated<Product>> list({
    String? search,
    String? status,
    int? categoryId,
    bool lowStock = false,
    int page = 1,
    int perPage = 20,
  }) {
    return _remote.list(
      search: search,
      status: status,
      categoryId: categoryId,
      lowStock: lowStock,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<Product> get(String slug) => _remote.get(slug);

  @override
  Future<Product> create(ProductDraft draft) => _remote.create(draft);

  @override
  Future<Product> update(String slug, ProductDraft draft) =>
      _remote.update(slug, draft);

  @override
  Future<void> delete(String slug, {bool force = false}) =>
      _remote.delete(slug, force: force);

  @override
  Future<SlugAvailability> checkSlug(String slug, {int? ignore}) =>
      _remote.checkSlug(slug, ignore: ignore);
}
