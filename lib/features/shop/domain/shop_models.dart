/// Public storefront payloads.
///
/// A shopper never sees internal ids, costs or other stores' stock. The only id
/// in this model that is sent back to the server is the variant id at checkout;
/// every amount is resolved again by the API.
library;

class StorefrontInfo {
  const StorefrontInfo({
    required this.name,
    required this.slug,
    required this.tenantSlug,
    required this.description,
    required this.logoUrl,
    required this.email,
    required this.phone,
    required this.currency,
    required this.currencySymbol,
    required this.currencyDecimals,
    required this.timezone,
    required this.settings,
  });

  final String name;
  final String slug;
  final String tenantSlug;
  final String description;
  final String? logoUrl;
  final String? email;
  final String? phone;
  final String currency;
  final String? currencySymbol;
  final int currencyDecimals;
  final String timezone;
  final Map<String, dynamic> settings;

  String? get tagline => _string(settings['tagline']);
  String? get about => _string(settings['about']);
  String? get heroImageUrl => _string(settings['hero_image_url']);
  String? get deliveryNote => _string(settings['delivery_note']);
  String? get returnPolicy => _string(settings['return_policy']);
  String? get address => _string(settings['address']);
  String? get whatsappNumber => _string(settings['whatsapp_number']);
  String? get openingHours => _string(settings['opening_hours']);

  factory StorefrontInfo.fromJson(Map<String, dynamic> json) {
    final rawSettings = json['settings'];
    return StorefrontInfo(
      name: '${json['name'] ?? ''}',
      slug: '${json['slug'] ?? ''}',
      tenantSlug: '${json['tenant_slug'] ?? ''}',
      description: '${json['description'] ?? ''}',
      logoUrl: json['logo_url'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      currency: '${json['currency'] ?? 'USD'}',
      currencySymbol: json['currency_symbol'] as String?,
      currencyDecimals: _int(json['currency_decimals'], 2),
      timezone: '${json['timezone'] ?? 'UTC'}',
      settings: rawSettings is Map
          ? Map<String, dynamic>.from(rawSettings)
          : const <String, dynamic>{},
    );
  }
}

class ShopCategory {
  const ShopCategory({
    required this.slug,
    required this.name,
    required this.description,
    required this.productsCount,
  });

  final String slug;
  final String name;
  final String? description;
  final int productsCount;

  factory ShopCategory.fromJson(Map<String, dynamic> json) {
    return ShopCategory(
      slug: '${json['slug'] ?? ''}',
      name: '${json['name'] ?? ''}',
      description: json['description'] as String?,
      productsCount: _int(json['products_count'], 0),
    );
  }
}

class ShopImage {
  const ShopImage({
    required this.url,
    required this.altText,
    required this.isPrimary,
  });

  final String url;
  final String? altText;
  final bool isPrimary;

  factory ShopImage.fromJson(Map<String, dynamic> json) {
    return ShopImage(
      url: '${json['url'] ?? ''}',
      altText: json['alt_text'] as String?,
      isPrimary: json['is_primary'] == true,
    );
  }
}

class ShopVariant {
  const ShopVariant({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.isDefault,
    required this.available,
    required this.inStock,
  });

  final int id;
  final String name;
  final String? sku;
  final num price;
  final bool isDefault;
  final int available;
  final bool inStock;

  factory ShopVariant.fromJson(Map<String, dynamic> json) {
    return ShopVariant(
      id: _int(json['id'], 0),
      name: '${json['name'] ?? ''}',
      sku: json['sku'] as String?,
      price: _num(json['price']),
      isDefault: json['is_default'] == true,
      available: _int(json['available'], 0),
      inStock: json['in_stock'] == true,
    );
  }
}

class ShopProduct {
  const ShopProduct({
    required this.slug,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.inStock,
    required this.available,
    required this.categoryName,
    required this.categorySlug,
    required this.images,
    required this.variants,
  });

  final String slug;
  final String name;
  final String? description;
  final num price;
  final String currency;
  final bool inStock;
  final int available;
  final String? categoryName;
  final String? categorySlug;
  final List<ShopImage> images;
  final List<ShopVariant> variants;

  String? get primaryImageUrl {
    for (final image in images) {
      if (image.isPrimary) return image.url;
    }
    return images.isEmpty ? null : images.first.url;
  }

  ShopVariant? get defaultVariant {
    if (variants.isEmpty) return null;
    for (final variant in variants) {
      if (variant.isDefault) return variant;
    }
    return variants.first;
  }

  factory ShopProduct.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'];
    final rawImages = json['images'];
    final rawVariants = json['variants'];
    return ShopProduct(
      slug: '${json['slug'] ?? ''}',
      name: '${json['name'] ?? ''}',
      description: json['description'] as String?,
      price: _num(json['price']),
      currency: '${json['currency'] ?? 'USD'}',
      inStock: json['in_stock'] == true,
      available: _int(json['available'], 0),
      categoryName: rawCategory is Map ? _string(rawCategory['name']) : null,
      categorySlug: rawCategory is Map ? _string(rawCategory['slug']) : null,
      images: rawImages is List
          ? rawImages
              .whereType<Map>()
              .map((entry) => ShopImage.fromJson(
                    Map<String, dynamic>.from(entry),
                  ))
              .toList()
          : const [],
      variants: rawVariants is List
          ? rawVariants
              .whereType<Map>()
              .map((entry) => ShopVariant.fromJson(
                    Map<String, dynamic>.from(entry),
                  ))
              .toList()
          : const [],
    );
  }
}

class ShopShippingZone {
  const ShopShippingZone({
    required this.id,
    required this.name,
    required this.city,
    required this.areas,
    required this.fee,
    required this.freeShippingThreshold,
    this.description,
    this.methodName,
    this.methodDescription,
    this.deliveryInstructions,
    this.terms,
    this.locale,
  });

  final int id;
  final String name;
  final String? description;
  final String? methodName;
  final String? methodDescription;
  final String? deliveryInstructions;
  final String? terms;
  final String? locale;
  final String? city;
  final List<String> areas;
  final num fee;
  final num? freeShippingThreshold;

  factory ShopShippingZone.fromJson(Map<String, dynamic> json) {
    final rawAreas = json['areas'];
    return ShopShippingZone(
      id: _int(json['id'], 0),
      name: '${json['name'] ?? ''}',
      description: _stringOrNull(json['description']),
      methodName: _stringOrNull(json['method_name']),
      methodDescription: _stringOrNull(json['method_description']),
      deliveryInstructions: _stringOrNull(json['delivery_instructions']),
      terms: _stringOrNull(json['terms']),
      locale: _stringOrNull(json['locale']),
      city: json['city'] as String?,
      areas: rawAreas is List
          ? rawAreas.map((area) => '$area').toList()
          : const [],
      fee: _num(json['fee']),
      freeShippingThreshold: _numOrNull(json['free_shipping_threshold']),
    );
  }
}

String? _stringOrNull(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

class ShopPaymentMethod {
  const ShopPaymentMethod({
    required this.code,
    required this.label,
    required this.description,
    required this.available,
    required this.unavailableReason,
  });

  final String code;
  final String label;
  final String description;
  final bool available;
  final String? unavailableReason;

  factory ShopPaymentMethod.fromJson(Map<String, dynamic> json) {
    return ShopPaymentMethod(
      code: '${json['code'] ?? ''}',
      label: '${json['label'] ?? ''}',
      description: '${json['description'] ?? ''}',
      available: json['available'] == true,
      unavailableReason: json['unavailable_reason'] as String?,
    );
  }
}

class ShopCartLine {
  const ShopCartLine({
    required this.productSlug,
    required this.productName,
    required this.variantId,
    required this.variantName,
    required this.unitPrice,
    required this.currency,
    required this.quantity,
    required this.imageUrl,
    required this.maxQuantity,
  });

  final String productSlug;
  final String productName;
  final int variantId;
  final String variantName;
  final num unitPrice;
  final String currency;
  final int quantity;
  final String? imageUrl;
  final int maxQuantity;

  num get lineTotal => unitPrice * quantity;

  ShopCartLine copyWith({int? quantity}) {
    return ShopCartLine(
      productSlug: productSlug,
      productName: productName,
      variantId: variantId,
      variantName: variantName,
      unitPrice: unitPrice,
      currency: currency,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
      maxQuantity: maxQuantity,
    );
  }
}

class ShopOrder {
  const ShopOrder({
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    required this.paymentStatus,
    required this.paymentStatusLabel,
    required this.paymentMethodLabel,
    required this.subtotal,
    required this.discountTotal,
    required this.taxTotal,
    required this.shippingTotal,
    required this.grandTotal,
    required this.currency,
    required this.customerName,
    required this.customerPhone,
    required this.shippingAddress,
    required this.items,
    required this.placedAt,
    this.trackingToken,
  });

  final String orderNumber;
  final String status;
  final String statusLabel;
  final String paymentStatus;
  final String paymentStatusLabel;
  final String? paymentMethodLabel;
  final num subtotal;
  final num discountTotal;
  final num taxTotal;
  final num shippingTotal;
  final num grandTotal;
  final String currency;
  final String customerName;
  final String customerPhone;
  final Map<String, dynamic> shippingAddress;
  final List<ShopOrderItem> items;
  final String? placedAt;
  final String? trackingToken;

  factory ShopOrder.fromJson(Map<String, dynamic> json) {
    final rawAddress = json['shipping_address'];
    final rawItems = json['items'];
    return ShopOrder(
      orderNumber: '${json['order_number'] ?? ''}',
      status: '${json['status'] ?? ''}',
      statusLabel: '${json['status_label'] ?? ''}',
      paymentStatus: '${json['payment_status'] ?? ''}',
      paymentStatusLabel: '${json['payment_status_label'] ?? ''}',
      paymentMethodLabel: json['payment_method_label'] as String?,
      subtotal: _num(json['subtotal']),
      discountTotal: _num(json['discount_total']),
      taxTotal: _num(json['tax_total']),
      shippingTotal: _num(json['shipping_total']),
      grandTotal: _num(json['grand_total']),
      currency: '${json['currency'] ?? 'USD'}',
      customerName: '${json['customer_name'] ?? ''}',
      customerPhone: '${json['customer_phone'] ?? ''}',
      shippingAddress: rawAddress is Map
          ? Map<String, dynamic>.from(rawAddress)
          : const <String, dynamic>{},
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((entry) => ShopOrderItem.fromJson(
                    Map<String, dynamic>.from(entry),
                  ))
              .toList()
          : const [],
      placedAt: json['placed_at'] as String?,
      trackingToken: json['tracking_token'] as String?,
    );
  }
}

class ShopOrderItem {
  const ShopOrderItem({
    required this.name,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final String name;
  final String? sku;
  final int quantity;
  final num unitPrice;
  final num lineTotal;

  factory ShopOrderItem.fromJson(Map<String, dynamic> json) {
    return ShopOrderItem(
      name: '${json['name'] ?? ''}',
      sku: json['sku'] as String?,
      quantity: _int(json['quantity'], 1),
      unitPrice: _num(json['unit_price']),
      lineTotal: _num(json['line_total']),
    );
  }
}

String? _string(Object? value) {
  if (value == null) return null;
  final text = '$value';
  return text.isEmpty ? null : text;
}

int _int(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

num _num(Object? value) {
  if (value is num) return value;
  return num.tryParse('$value') ?? 0;
}

num? _numOrNull(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}
