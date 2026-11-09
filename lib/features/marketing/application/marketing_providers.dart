import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/api/paginated.dart';
import '../../../core/pagination/paginated_notifier.dart';
import '../../../core/providers.dart';
import '../../../app/theme/theme_controller.dart';
import '../data/newsletter_repository.dart';
import '../domain/marketing_models.dart';

JsonMap _asMap(Object? data) =>
    data is Map ? Map<String, dynamic>.from(data) : const <String, dynamic>{};

/// The public API localises its prose from `?locale=`, so every read is keyed
/// by the language currently on screen. Watching [effectiveLocaleProvider]
/// also invalidates these providers when the visitor switches language.
String _localeCode(Ref ref) => ref.watch(effectiveLocaleProvider).languageCode;

final marketingFeaturesProvider =
    FutureProvider.autoDispose<List<MarketingFeature>>((ref) async {
  final data = await ref.read(apiClientProvider).get<JsonMap>(
        ApiPaths.publicFeatures,
        query: {'locale': _localeCode(ref)},
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
        query: {'locale': _localeCode(ref)},
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
        query: {'locale': _localeCode(ref)},
        decode: (value) => value is List ? value : const <dynamic>[],
      );
  return data
      .whereType<Map>()
      .map((entry) => FaqEntry.fromJson(Map<String, dynamic>.from(entry)))
      .toList();
});

final newsletterRepositoryProvider = Provider<NewsletterRepository>((ref) {
  return NewsletterRepository(ref.watch(apiClientProvider));
});

/// Home-page preview: the first page of the public newsletter feed.
final marketingNewslettersProvider =
    FutureProvider.autoDispose<List<Newsletter>>((ref) async {
  final page = await ref
      .watch(newsletterRepositoryProvider)
      .fetchNewsletters(page: 1, perPage: 9, locale: _localeCode(ref));
  return page.items;
});

/// The blog screen's own pager. Kept separate from the home preview so loading
/// more articles never mutates the home page's short list.
class NewsletterFeedNotifier extends PaginatedNotifier<Newsletter> {
  NewsletterFeedNotifier(this._repository, this._locale);

  final NewsletterRepository _repository;
  final String _locale;

  static const int perPage = 9;

  @override
  Future<Paginated<Newsletter>> fetchPage(int page) {
    return _repository.fetchNewsletters(
      page: page,
      perPage: perPage,
      locale: _locale,
    );
  }
}

final newsletterFeedProvider =
    StateNotifierProvider<NewsletterFeedNotifier, PaginatedState<Newsletter>>(
        (ref) {
  final locale = _localeCode(ref);
  final notifier = NewsletterFeedNotifier(
    ref.watch(newsletterRepositoryProvider),
    locale,
  );
  refreshOnReconnect(ref, notifier.reload);
  return notifier;
});

final marketingNewsletterProvider =
    FutureProvider.autoDispose.family<Newsletter, String>(
  (ref, slug) async {
    final data = await ref.read(apiClientProvider).get<JsonMap>(
          ApiPaths.publicNewsletter(slug),
          query: {'locale': _localeCode(ref)},
          decode: _asMap,
        );
    return Newsletter.fromJson(data);
  },
);

final contentPageProvider =
    FutureProvider.autoDispose.family<ContentPage, String>((ref, key) async {
  final data = await ref.read(apiClientProvider).get<JsonMap>(
        ApiPaths.publicPage(key),
        query: {'locale': _localeCode(ref)},
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
    String? website,
  }) async {
    await _api.post<dynamic>(
      ApiPaths.publicWaitlist,
      body: {
        'email': email,
        if (name != null && name.isNotEmpty) 'name': name,
        if (businessType != null && businessType.isNotEmpty)
          'business_type': businessType,
        if (source != null && source.isNotEmpty) 'source': source,
        // Honeypot field: real visitors never fill it. The backend accepts the
        // request either way, so sending the empty value is safe and keeps the
        // wire shape identical to the web form.
        if (website != null) 'website': website,
      },
    );
  }

  Future<void> contact({
    required String name,
    required String email,
    required String subject,
    required String message,
    String? website,
  }) async {
    await _api.post<dynamic>(
      ApiPaths.publicContact,
      body: {
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        if (website != null) 'website': website,
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
