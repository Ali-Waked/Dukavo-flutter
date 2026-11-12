import 'dart:async';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/api/paginated.dart';
import '../domain/help_models.dart';

/// Reads the signed-in Help Center.
///
/// HTTP status handling lives in [ApiClient]: any response at or above 400 is
/// converted to an [ApiException] before it reaches this class, and a 404 for a
/// restricted or unknown article arrives exactly like a missing one. The
/// repository adds the product-level request timeout and keeps failures in the
/// same vocabulary the UI already renders.
class HelpRepository {
  HelpRepository(this._api);

  final ApiClient _api;

  static const Duration requestTimeout = Duration(seconds: 15);

  JsonMap _asMap(Object? data) =>
      data is Map ? Map<String, dynamic>.from(data) : const <String, dynamic>{};

  /// The categories the reader may browse, each with their visible article
  /// count.
  Future<List<HelpCategory>> fetchCategories({String? locale}) async {
    try {
      final data = await _api
          .get<List<dynamic>>(
            ApiPaths.helpCategories,
            query: {
              if (locale != null && locale.isNotEmpty) 'locale': locale,
            },
            decode: (raw) => raw is List ? raw : const <dynamic>[],
          )
          .timeout(requestTimeout);

      return data
          .whereType<Map>()
          .map((entry) =>
              HelpCategory.fromJson(Map<String, dynamic>.from(entry)))
          .toList();
    } on TimeoutException {
      throw ApiException(
        'The request took too long. Check your connection and try again.',
        isNetworkError: true,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Something went wrong. Please try again.');
    }
  }

  /// Published articles the reader may open, with optional filters.
  Future<Paginated<HelpArticle>> fetchArticles({
    int page = 1,
    int perPage = 15,
    String? category,
    String? tag,
    bool featured = false,
    bool popular = false,
    String? locale,
  }) async {
    try {
      return await _api
          .list<HelpArticle>(
            ApiPaths.helpArticles,
            query: {
              'page': page,
              'per_page': perPage,
              if (category != null && category.isNotEmpty) 'category': category,
              if (tag != null && tag.isNotEmpty) 'tag': tag,
              if (featured) 'featured': 1,
              if (popular) 'popular': 1,
              if (locale != null && locale.isNotEmpty) 'locale': locale,
            },
            item: HelpArticle.fromJson,
          )
          .timeout(requestTimeout);
    } on TimeoutException {
      throw ApiException(
        'The request took too long. Check your connection and try again.',
        isNetworkError: true,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Something went wrong. Please try again.');
    }
  }

  /// One article by either of its slugs. A draft, an unknown slug or an
  /// article above the reader's tier is a 404, which the screen renders as a
  /// "not found" state rather than an error.
  Future<HelpArticle> fetchArticle(String slug, {String? locale}) async {
    try {
      final data = await _api
          .get<JsonMap>(
            ApiPaths.helpArticle(slug),
            query: {
              if (locale != null && locale.isNotEmpty) 'locale': locale,
            },
            decode: _asMap,
          )
          .timeout(requestTimeout);

      return HelpArticle.fromJson(data);
    } on TimeoutException {
      throw ApiException(
        'The request took too long. Check your connection and try again.',
        isNetworkError: true,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Something went wrong. Please try again.');
    }
  }

  /// Type-ahead search across titles, excerpts, bodies, tags and categories,
  /// in both published languages, restricted to the reader's tier.
  Future<HelpSearchResults> search(
    String term, {
    int perPage = 10,
    String? locale,
  }) async {
    try {
      final data = await _api
          .get<JsonMap>(
            ApiPaths.helpSearch,
            query: {
              'q': term,
              'per_page': perPage,
              if (locale != null && locale.isNotEmpty) 'locale': locale,
            },
            decode: _asMap,
          )
          .timeout(requestTimeout);

      return HelpSearchResults.fromJson(data);
    } on TimeoutException {
      throw ApiException(
        'The request took too long. Check your connection and try again.',
        isNetworkError: true,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Something went wrong. Please try again.');
    }
  }

  /// A "was this helpful?" answer. The server deduplicates by account and
  /// answers 2xx whether the vote was new or already recorded, so the caller
  /// only reports that the answer was received.
  Future<void> submitFeedback({
    required String slug,
    required bool helpful,
    String? comment,
  }) async {
    await _api.postVoid(
      ApiPaths.helpArticleFeedback(slug),
      body: {
        'helpful': helpful,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      },
      csrf: true,
    );
  }
}
