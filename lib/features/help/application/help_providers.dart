import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_controller.dart';
import '../../../core/api/paginated.dart';
import '../../../core/pagination/paginated_notifier.dart';
import '../../../core/providers.dart';
import '../data/help_repository.dart';
import '../domain/help_models.dart';

/// The reader API resolves its copy from `?locale=`, so every read is keyed by
/// the language currently on screen. Watching [effectiveLocaleProvider] also
/// invalidates these providers when the reader switches language.
String _localeCode(Ref ref) => ref.watch(effectiveLocaleProvider).languageCode;

final helpRepositoryProvider = Provider<HelpRepository>((ref) {
  return HelpRepository(ref.watch(apiClientProvider));
});

/// The categories the signed-in reader may browse.
final helpCategoriesProvider =
    FutureProvider.autoDispose<List<HelpCategory>>((ref) async {
  return ref
      .watch(helpRepositoryProvider)
      .fetchCategories(locale: _localeCode(ref));
});

/// One article by either of its slugs. Unknown or restricted slugs surface as
/// a 404 error the screen renders as a "not found" state.
final helpArticleProvider =
    FutureProvider.autoDispose.family<HelpArticle, String>((ref, slug) async {
  return ref
      .watch(helpRepositoryProvider)
      .fetchArticle(slug, locale: _localeCode(ref));
});

/// Featured guides for the Help Center home.
final helpFeaturedProvider =
    FutureProvider.autoDispose<List<HelpArticle>>((ref) async {
  final page = await ref.watch(helpRepositoryProvider).fetchArticles(
        page: 1,
        perPage: 5,
        featured: true,
        locale: _localeCode(ref),
      );
  return page.items;
});

/// Most-read guides for the Help Center home.
final helpPopularProvider =
    FutureProvider.autoDispose<List<HelpArticle>>((ref) async {
  final page = await ref.watch(helpRepositoryProvider).fetchArticles(
        page: 1,
        perPage: 5,
        popular: true,
        locale: _localeCode(ref),
      );
  return page.items;
});

/// Type-ahead search. An empty term short-circuits to an empty result rather
/// than asking the server, so the dropdown never flashes a loading state while
/// the reader is still typing.
final helpSearchProvider = FutureProvider.autoDispose
    .family<HelpSearchResults, String>((ref, term) async {
  final query = term.trim();

  if (query.isEmpty) {
    return const HelpSearchResults(
      query: '',
      articles: <HelpArticle>[],
      categories: <HelpCategory>[],
    );
  }

  return ref
      .watch(helpRepositoryProvider)
      .search(query, locale: _localeCode(ref));
});

/// The article feed inside one category, page by page.
class HelpCategoryFeedNotifier extends PaginatedNotifier<HelpArticle> {
  HelpCategoryFeedNotifier(this._repository, this._categorySlug, this._locale);

  final HelpRepository _repository;
  final String _categorySlug;
  final String _locale;

  static const int perPage = 15;

  @override
  Future<Paginated<HelpArticle>> fetchPage(int page) {
    return _repository.fetchArticles(
      page: page,
      perPage: perPage,
      category: _categorySlug,
      locale: _locale,
    );
  }
}

final helpCategoryFeedProvider = StateNotifierProvider.autoDispose
    .family<HelpCategoryFeedNotifier, PaginatedState<HelpArticle>, String>(
        (ref, categorySlug) {
  final locale = _localeCode(ref);
  final notifier = HelpCategoryFeedNotifier(
    ref.watch(helpRepositoryProvider),
    categorySlug,
    locale,
  );
  refreshOnReconnect(ref, notifier.reload);
  return notifier;
});
