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
    this.locale,
    this.direction,
    this.defaultLocale,
    this.enabledLocales = const [],
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

  /// The language the response was resolved into, and its writing direction.
  final String? locale;
  final String? direction;
  final String? defaultLocale;
  final List<String> enabledLocales;

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
    final rawLocales = json['enabled_locales'];
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
      locale: _stringOrNull(json['locale']),
      direction: _stringOrNull(json['direction']),
      defaultLocale: _stringOrNull(json['default_locale']),
      enabledLocales: rawLocales is List
          ? rawLocales.map((entry) => '$entry').toList(growable: false)
          : const [],
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
    this.caption,
  });

  final String url;
  final String? altText;
  final String? caption;
  final bool isPrimary;

  factory ShopImage.fromJson(Map<String, dynamic> json) {
    return ShopImage(
      url: '${json['url'] ?? ''}',
      altText: json['alt_text'] as String?,
      caption: _stringOrNull(json['caption']),
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
    this.description,
  });

  final int id;
  final String name;
  final String? description;
  final String? sku;
  final num price;
  final bool isDefault;
  final int available;
  final bool inStock;

  factory ShopVariant.fromJson(Map<String, dynamic> json) {
    return ShopVariant(
      id: _int(json['id'], 0),
      name: '${json['name'] ?? ''}',
      description: _stringOrNull(json['description']),
      sku: json['sku'] as String?,
      price: _num(json['price']),
      isDefault: json['is_default'] == true,
      available: _int(json['available'], 0),
      inStock: json['in_stock'] == true,
    );
  }
}

class ShopSpecification {
  const ShopSpecification({required this.label, required this.value});

  final String label;
  final String value;

  factory ShopSpecification.fromJson(Map<String, dynamic> json) {
    return ShopSpecification(
      label: '${json['label'] ?? ''}',
      value: '${json['value'] ?? ''}',
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
    this.canonicalSlug,
    this.localizedSlugs = const {},
    this.shortDescription,
    this.highlights = const [],
    this.features = const [],
    this.specifications = const [],
    this.tags = const [],
    this.seoTitle,
    this.seoDescription,
    this.seoKeywords,
    this.locale,
    this.direction,
    this.defaultLocale,
    this.availableLocales = const [],
  });

  final String slug;
  final String? canonicalSlug;
  final Map<String, String> localizedSlugs;
  final String name;
  final String? shortDescription;
  final String? description;
  final List<String> highlights;
  final List<String> features;
  final List<ShopSpecification> specifications;
  final List<String> tags;
  final String? seoTitle;
  final String? seoDescription;
  final String? seoKeywords;
  final num price;
  final String currency;
  final bool inStock;
  final int available;
  final String? categoryName;
  final String? categorySlug;
  final List<ShopImage> images;
  final List<ShopVariant> variants;
  final String? locale;
  final String? direction;
  final String? defaultLocale;
  final List<String> availableLocales;

  String? get primaryImageUrl {
    for (final image in images) {
      if (image.isPrimary) return image.url;
    }
    return images.isEmpty ? null : images.first.url;
  }

  String? get summary => shortDescription ?? description;

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
    final rawHighlights = json['highlights'];
    final rawFeatures = json['features'];
    final rawSpecifications = json['specifications'];
    final rawTags = json['tags'];
    final rawSeo = json['seo'];
    final rawSlugs = json['localized_slugs'];
    final rawLocales = json['available_locales'];

    return ShopProduct(
      slug: '${json['slug'] ?? ''}',
      canonicalSlug: _stringOrNull(json['canonical_slug']),
      localizedSlugs: rawSlugs is Map
          ? rawSlugs.map((key, value) => MapEntry('$key', '$value'))
          : const {},
      name: '${json['name'] ?? ''}',
      shortDescription: _stringOrNull(json['short_description']),
      description: _stringOrNull(json['description']),
      highlights: _stringList(rawHighlights),
      features: _stringList(rawFeatures),
      specifications: rawSpecifications is List
          ? rawSpecifications
              .whereType<Map>()
              .map((entry) => ShopSpecification.fromJson(
                    Map<String, dynamic>.from(entry),
                  ))
              .toList(growable: false)
          : const [],
      tags: _stringList(rawTags),
      seoTitle: rawSeo is Map ? _stringOrNull(rawSeo['title']) : null,
      seoDescription:
          rawSeo is Map ? _stringOrNull(rawSeo['description']) : null,
      seoKeywords: rawSeo is Map ? _stringOrNull(rawSeo['keywords']) : null,
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
      locale: _stringOrNull(json['locale']),
      direction: _stringOrNull(json['direction']),
      defaultLocale: _stringOrNull(json['default_locale']),
      availableLocales: _stringList(rawLocales),
    );
  }
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value
      .map((entry) => '$entry'.trim())
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
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

/// One online rail behind the high-level `online` method.
///
/// The browser/app sends the code back as a *preference*. The server resolves
/// the provider, connection and source id again, so a tampered client can never
/// choose a provider account or price.
class ShopPaymentRail {
  const ShopPaymentRail({
    required this.code,
    required this.label,
    required this.description,
    required this.kind,
    required this.provider,
    required this.providerName,
    required this.environment,
  });

  final String code;
  final String label;
  final String description;
  final String kind;
  final String provider;
  final String providerName;
  final String environment;

  factory ShopPaymentRail.fromJson(Map<String, dynamic> json) {
    return ShopPaymentRail(
      code: '${json['code'] ?? ''}',
      label: '${json['label'] ?? ''}',
      description: '${json['description'] ?? ''}',
      kind: '${json['kind'] ?? ''}',
      provider: '${json['provider'] ?? ''}',
      providerName: '${json['provider_name'] ?? ''}',
      environment: '${json['environment'] ?? ''}',
    );
  }
}

class ShopPaymentMethod {
  const ShopPaymentMethod({
    required this.code,
    required this.label,
    required this.description,
    required this.available,
    required this.unavailableReason,
    required this.instructions,
    required this.methods,
  });

  final String code;
  final String label;
  final String description;
  final bool available;
  final String? unavailableReason;

  /// Merchant copy shown after the method is chosen, such as bank details.
  final String? instructions;

  /// Sellable online rails. Empty for cash on delivery and bank transfer.
  final List<ShopPaymentRail> methods;

  factory ShopPaymentMethod.fromJson(Map<String, dynamic> json) {
    final rawMethods = json['methods'];
    return ShopPaymentMethod(
      code: '${json['code'] ?? ''}',
      label: '${json['label'] ?? ''}',
      description: '${json['description'] ?? ''}',
      available: json['available'] == true,
      unavailableReason: json['unavailable_reason'] as String?,
      instructions: _stringOrNull(json['instructions']),
      methods: rawMethods is List
          ? rawMethods
              .whereType<Map>()
              .map((entry) => ShopPaymentRail.fromJson(
                    Map<String, dynamic>.from(entry),
                  ))
              .toList(growable: false)
          : const [],
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

/// Customer-safe state of the latest online payment attempt.
///
/// A redirect to the provider page proves nothing. `status` only moves to a
/// final value after the server verifies a signed webhook or provider lookup,
/// so this object never treats "customer came back" as payment.
class ShopOrderPayment {
  const ShopOrderPayment({
    required this.status,
    required this.statusLabel,
    required this.methodCode,
    required this.attemptNumber,
    required this.amount,
    required this.currency,
    required this.providerName,
    required this.checkoutUrl,
    required this.failureReason,
    required this.reference,
    required this.retryAllowed,
    required this.expiresAt,
    required this.paidAt,
  });

  final String status;
  final String statusLabel;
  final String? methodCode;
  final int attemptNumber;
  final num amount;
  final String currency;
  final String? providerName;
  final String? checkoutUrl;
  final String? failureReason;
  final String? reference;
  final bool retryAllowed;
  final String? expiresAt;
  final String? paidAt;

  bool get isPending =>
      status == 'pending' ||
      status == 'requires_action' ||
      status == 'processing';

  bool get isPaid => status == 'succeeded';

  factory ShopOrderPayment.fromJson(Map<String, dynamic> json) {
    return ShopOrderPayment(
      status: '${json['status'] ?? ''}',
      statusLabel: '${json['status_label'] ?? ''}',
      methodCode: _stringOrNull(json['method_code']),
      attemptNumber: _int(json['attempt_number'], 1),
      amount: _num(json['amount']),
      currency: '${json['currency'] ?? ''}',
      providerName: _stringOrNull(json['provider_name']),
      checkoutUrl: _stringOrNull(json['checkout_url']),
      failureReason: _stringOrNull(json['failure_reason']),
      reference: _stringOrNull(json['reference']),
      retryAllowed: json['retry_allowed'] == true,
      expiresAt: _stringOrNull(json['expires_at']),
      paidAt: _stringOrNull(json['paid_at']),
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
    required this.paymentMethod,
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
    this.payment,
  });

  final String orderNumber;
  final String status;
  final String statusLabel;
  final String paymentStatus;
  final String paymentStatusLabel;

  /// High-level method: `cod`, `bank_transfer` or `online`.
  final String? paymentMethod;
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

  /// Latest online attempt, absent for cash on delivery and bank transfer.
  final ShopOrderPayment? payment;

  factory ShopOrder.fromJson(Map<String, dynamic> json) {
    final rawAddress = json['shipping_address'];
    final rawItems = json['items'];
    final rawPayment = json['payment'];
    return ShopOrder(
      orderNumber: '${json['order_number'] ?? ''}',
      status: '${json['status'] ?? ''}',
      statusLabel: '${json['status_label'] ?? ''}',
      paymentStatus: '${json['payment_status'] ?? ''}',
      paymentStatusLabel: '${json['payment_status_label'] ?? ''}',
      paymentMethod: json['payment_method'] as String?,
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
      payment: rawPayment is Map
          ? ShopOrderPayment.fromJson(Map<String, dynamic>.from(rawPayment))
          : null,
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
