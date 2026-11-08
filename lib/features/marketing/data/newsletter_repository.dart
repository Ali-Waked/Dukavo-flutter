import 'dart:async';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/api/paginated.dart';
import '../domain/marketing_models.dart';

/// Reads the public newsletter feed.
///
/// HTTP status handling lives in [ApiClient]: any response at or above 400 is
/// converted to an [ApiException] before it reaches this class. The repository
/// adds the product-level request timeout and keeps failures in the same
/// vocabulary the UI already renders.
class NewsletterRepository {
  NewsletterRepository(this._api);

  final ApiClient _api;

  static const Duration requestTimeout = Duration(seconds: 15);

  Future<Paginated<Newsletter>> fetchNewsletters({
    int page = 1,
    int perPage = 9,
    String? locale,
  }) async {
    try {
      return await _api
          .list<Newsletter>(
            ApiPaths.publicNewsletters,
            query: {
              'page': page,
              'per_page': perPage,
              if (locale != null && locale.isNotEmpty) 'locale': locale,
            },
            item: Newsletter.fromJson,
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
}
