import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/storefront_domain.dart';

class StorefrontSettingsModel {
  const StorefrontSettingsModel({
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

  factory StorefrontSettingsModel.fromJson(Map<String, dynamic> json) {
    final raw = json['settings'];
    final settings = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
    final rawSocial = settings['social'];
    final social = rawSocial is Map
        ? Map<String, dynamic>.from(rawSocial)
        : const <String, dynamic>{};

    return StorefrontSettingsModel(
      storeId: _int(json['store_id']),
      name: '${json['name'] ?? ''}',
      slug: '${json['slug'] ?? ''}',
      status: '${json['status'] ?? 'active'}',
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      storefrontEnabled: json['storefront_enabled'] == true,
      currency: '${json['currency'] ?? 'USD'}',
      updatedAt: json['updated_at'] as String?,
      settings: StorefrontPresentationSettings(
        tagline: settings['tagline'] as String?,
        about: settings['about'] as String?,
        heroImageUrl: settings['hero_image_url'] as String?,
        contactEmail: settings['contact_email'] as String?,
        contactPhone: settings['contact_phone'] as String?,
        whatsappNumber: settings['whatsapp_number'] as String?,
        address: settings['address'] as String?,
        facebook: social['facebook'] as String?,
        instagram: social['instagram'] as String?,
        tiktok: social['tiktok'] as String?,
        openingHours: settings['opening_hours'] as String?,
        deliveryNote: settings['delivery_note'] as String?,
        returnPolicy: settings['return_policy'] as String?,
        showOutOfStock: settings['show_out_of_stock'] != false,
        metaTitle: settings['meta_title'] as String?,
        metaDescription: settings['meta_description'] as String?,
      ),
    );
  }

  StorefrontSettings toEntity() => StorefrontSettings(
        storeId: storeId,
        name: name,
        slug: slug,
        status: status,
        description: description,
        logoUrl: logoUrl,
        storefrontEnabled: storefrontEnabled,
        currency: currency,
        settings: settings,
        updatedAt: updatedAt,
      );

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}

class StorefrontRemoteDataSource {
  StorefrontRemoteDataSource(this._api);

  final ApiClient _api;

  Future<StorefrontSettings> get(int storeId) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.storeStorefront(storeId),
      decode: _asMap,
    );
    return StorefrontSettingsModel.fromJson(data).toEntity();
  }

  Future<StorefrontSettings> update(
    int storeId,
    StorefrontDraft draft,
  ) async {
    final data = await _api.patch<Map<String, dynamic>>(
      ApiPaths.storeStorefront(storeId),
      body: {
        'storefront_enabled': draft.storefrontEnabled,
        'description': _clean(draft.description),
        'logo_url': _clean(draft.logoUrl),
        'settings': draft.settings.toJson(),
      },
      decode: _asMap,
    );
    return StorefrontSettingsModel.fromJson(data).toEntity();
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}

class StorefrontRepositoryImpl implements StorefrontRepository {
  StorefrontRepositoryImpl(this._remote);

  final StorefrontRemoteDataSource _remote;

  @override
  Future<StorefrontSettings> get(int storeId) => _remote.get(storeId);

  @override
  Future<StorefrontSettings> update(int storeId, StorefrontDraft draft) =>
      _remote.update(storeId, draft);
}
