import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/providers.dart';
import '../domain/marketing_models.dart';

JsonMap _asMap(Object? data) =>
    data is Map ? Map<String, dynamic>.from(data) : const <String, dynamic>{};

final marketingFeaturesProvider =
    FutureProvider.autoDispose<List<MarketingFeature>>((ref) async {
  final data = await ref.read(apiClientProvider).get<JsonMap>(
        ApiPaths.publicFeatures,
        decode: _asMap,
      );
  final raw = data['features'];
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((entry) => MarketingFeature.fromJson(
            Map<String, dynamic>.from(entry),
          ))
      .toList();
});

final marketingPricingProvider =
    FutureProvider.autoDispose<List<PricingPlan>>((ref) async {
  final data = await ref.read(apiClientProvider).get<List<dynamic>>(
        ApiPaths.publicPricing,
        decode: (value) => value is List ? value : const <dynamic>[],
      );
  return data
      .whereType<Map>()
      .map((entry) => PricingPlan.fromJson(Map<String, dynamic>.from(entry)))
      .toList();
});

final marketingFaqProvider =
    FutureProvider.autoDispose<List<FaqEntry>>((ref) async {
  final data = await ref.read(apiClientProvider).get<List<dynamic>>(
        ApiPaths.publicFaq,
        decode: (value) => value is List ? value : const <dynamic>[],
      );
  return data
      .whereType<Map>()
      .map((entry) => FaqEntry.fromJson(Map<String, dynamic>.from(entry)))
      .toList();
});

final marketingNewslettersProvider =
    FutureProvider.autoDispose<List<NewsletterArticle>>((ref) async {
  final data = await ref.read(apiClientProvider).get<List<dynamic>>(
        ApiPaths.publicNewsletters,
        decode: (value) => value is List ? value : const <dynamic>[],
      );
  return data
      .whereType<Map>()
      .map((entry) => NewsletterArticle.fromJson(
            Map<String, dynamic>.from(entry),
          ))
      .toList();
});

final marketingNewsletterProvider =
    FutureProvider.autoDispose.family<NewsletterArticle, String>(
  (ref, slug) async {
    final data = await ref.read(apiClientProvider).get<JsonMap>(
          ApiPaths.publicNewsletter(slug),
          decode: _asMap,
        );
    return NewsletterArticle.fromJson(data);
  },
);

final contentPageProvider =
    FutureProvider.autoDispose.family<ContentPage, String>((ref, key) async {
  final data = await ref.read(apiClientProvider).get<JsonMap>(
        ApiPaths.publicPage(key),
        decode: _asMap,
      );
  return ContentPage.fromJson(data);
});

/// The three public write endpoints. Kept together so every form posts to the
/// endpoint its backend throttles, and none of them invents a success message.
class MarketingActions {
  MarketingActions(this._api);

  final ApiClient _api;

  Future<void> joinWaitlist({
    required String email,
    String? name,
    String? businessType,
    String? source,
  }) async {
    await _api.post<dynamic>(
      ApiPaths.publicWaitlist,
      body: {
        'email': email,
        if (name != null && name.isNotEmpty) 'name': name,
        if (businessType != null && businessType.isNotEmpty)
          'business_type': businessType,
        if (source != null && source.isNotEmpty) 'source': source,
      },
    );
  }

  Future<void> contact({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    await _api.post<dynamic>(
      ApiPaths.publicContact,
      body: {
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
      },
    );
  }

  Future<void> subscribe(String email, {String? source}) async {
    await _api.post<dynamic>(
      ApiPaths.publicNewsletterSubscribe,
      body: {
        'email': email,
        if (source != null && source.isNotEmpty) 'source': source,
      },
    );
  }
}

final marketingActionsProvider = Provider<MarketingActions>((ref) {
  return MarketingActions(ref.watch(apiClientProvider));
});
