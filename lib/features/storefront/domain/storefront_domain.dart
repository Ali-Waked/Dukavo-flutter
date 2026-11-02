/// Public shop configuration, mirroring `StorefrontSettingsResource`.
///
/// Nothing here affects money or stock. It describes what the customer sees
/// when the store is published, which is why every presentation field is
/// nullable rather than filled with a fabricated default.
class StorefrontPresentationSettings {
  const StorefrontPresentationSettings({
    this.tagline,
    this.about,
    this.heroImageUrl,
    this.contactEmail,
    this.contactPhone,
    this.whatsappNumber,
    this.address,
    this.facebook,
    this.instagram,
    this.tiktok,
    this.openingHours,
    this.deliveryNote,
    this.returnPolicy,
    this.showOutOfStock = true,
    this.metaTitle,
    this.metaDescription,
  });

  final String? tagline;
  final String? about;
  final String? heroImageUrl;
  final String? contactEmail;
  final String? contactPhone;
  final String? whatsappNumber;
  final String? address;
  final String? facebook;
  final String? instagram;
  final String? tiktok;
  final String? openingHours;
  final String? deliveryNote;
  final String? returnPolicy;
  final bool showOutOfStock;
  final String? metaTitle;
  final String? metaDescription;

  /// Only the values a merchant actually typed. An empty field is sent as
  /// null so clearing a field in the app clears it on the server too.
  Map<String, dynamic> toJson() => {
        'tagline': _clean(tagline),
        'about': _clean(about),
        'hero_image_url': _clean(heroImageUrl),
        'contact_email': _clean(contactEmail),
        'contact_phone': _clean(contactPhone),
        'whatsapp_number': _clean(whatsappNumber),
        'address': _clean(address),
        'social': {
          'facebook': _clean(facebook),
          'instagram': _clean(instagram),
          'tiktok': _clean(tiktok),
        },
        'opening_hours': _clean(openingHours),
        'delivery_note': _clean(deliveryNote),
        'return_policy': _clean(returnPolicy),
        'show_out_of_stock': showOutOfStock,
        'meta_title': _clean(metaTitle),
        'meta_description': _clean(metaDescription),
      };

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

class StorefrontSettings {
  const StorefrontSettings({
    required this.storeId,
    required this.name,
    required this.slug,
    required this.status,
    required this.storefrontEnabled,
    required this.currency,
    required this.settings,
    this.description,
    this.logoUrl,
    this.updatedAt,
  });

  final int storeId;
  final String name;
  final String slug;
  final String status;
  final String? description;
  final String? logoUrl;
  final bool storefrontEnabled;
  final String currency;
  final StorefrontPresentationSettings settings;
  final String? updatedAt;
}

class StorefrontDraft {
  const StorefrontDraft({
    required this.storefrontEnabled,
    required this.settings,
    this.description,
    this.logoUrl,
  });

  final bool storefrontEnabled;
  final String? description;
  final String? logoUrl;
  final StorefrontPresentationSettings settings;
}

abstract class StorefrontRepository {
  Future<StorefrontSettings> get(int storeId);

  Future<StorefrontSettings> update(int storeId, StorefrontDraft draft);
}
