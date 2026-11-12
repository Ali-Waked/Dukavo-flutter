import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../marketing/presentation/public_content.dart' show SanitizedHtml;
import '../../marketing/presentation/public_widgets.dart'
    show publicErrorMessage;
import '../application/help_providers.dart';
import '../domain/help_models.dart';

/// Icon for a Help Center category. The icon name is platform-managed free
/// text; the map covers the seeded set and an unknown name falls back to the
/// question mark rather than hiding the category over a typo.
IconData helpCategoryIcon(String name) {
  switch (name.trim().toLowerCase()) {
    case 'rocket':
      return Icons.rocket_launch_outlined;
    case 'box':
      return Icons.inventory_2_outlined;
    case 'layers':
      return Icons.layers_outlined;
    case 'cart':
      return Icons.shopping_cart_outlined;
    case 'store':
      return Icons.store_outlined;
    case 'credit-card':
      return Icons.credit_card_outlined;
    case 'workflow':
      return Icons.account_tree_outlined;
    case 'message-circle':
      return Icons.forum_outlined;
    case 'languages':
      return Icons.translate_outlined;
    case 'shield':
      return Icons.shield_outlined;
    default:
      return Icons.help_outline_rounded;
  }
}

/// The Help Center home: search, the topic catalogue and the featured and most
/// read guides. Everything the reader sees is already filtered to their tier
/// on the server.
class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key, this.initialQuery});

  /// A topic the reader arrived with, pre-filled into the search. Screens
  /// never link to a platform-managed slug, so this stays a search term.
  final String? initialQuery;

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  late final TextEditingController _search;
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuery?.trim() ?? '';
    _query = initial;
    _search = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      // Clearing the search returns to the home view immediately.
      setState(() => _query = value);
      return;
    }
    // The field itself owns the visible text; only the provider query waits
    // out the debounce, so a fast typist does not fire a search per keystroke.
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _query = value);
    });
  }

  void _submitSearch(String value) {
    _debounce?.cancel();
    setState(() => _query = value);
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('helpCenter')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () {
              ref.invalidate(helpCategoriesProvider);
              ref.invalidate(helpFeaturedProvider);
              ref.invalidate(helpPopularProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.md,
              AppSpacing.xxs,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: SearchField(
              controller: _search,
              hint: context.tr('supportSearchHint'),
              onChanged: _onSearch,
              onSubmitted: _submitSearch,
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? const _SupportHome()
                : _SupportSearchResults(query: query),
          ),
        ],
      ),
    );
  }
}

class _SupportHome extends ConsumerWidget {
  const _SupportHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(helpCategoriesProvider);
    final featured = ref.watch(helpFeaturedProvider);
    final popular = ref.watch(helpPopularProvider);
    final featuredItems = featured.valueOrNull ?? const <HelpArticle>[];
    final popularItems = popular.valueOrNull ?? const <HelpArticle>[];

    // Featured and most-read are secondary lists: a failure there must not
    // blank the page, so it only hides the section. The catalogue above
    // keeps the error state and the retry affordance for the whole home.
    return ListView(
      padding: AppSpacing.page,
      children: [
        SectionHeader(title: context.tr('supportBrowseTopics')),
        categories.when(
          loading: () => const ListSkeleton(),
          error: (error, _) => ErrorView(
            message: publicErrorMessage(context, error),
            onRetry: () => ref.invalidate(helpCategoriesProvider),
          ),
          data: (items) => items.isEmpty
              ? EmptyState(
                  title: context.tr('supportEmptyCategoryTitle'),
                  icon: Icons.help_outline_rounded,
                )
              : _HelpCategoryGrid(categories: items),
        ),
        if (featured.isLoading) ...[
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: context.tr('supportFeatured')),
          const ListSkeleton(),
        ] else if (featuredItems.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: context.tr('supportFeatured')),
          for (final article in featuredItems)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
              child: _HelpArticleCard(article: article),
            ),
        ],
        if (popular.isLoading) ...[
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: context.tr('supportPopular')),
          const ListSkeleton(),
        ] else if (popularItems.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: context.tr('supportPopular')),
          for (final article in popularItems)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
              child: _HelpArticleCard(article: article),
            ),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _HelpCategoryGrid extends StatelessWidget {
  const _HelpCategoryGrid({required this.categories});

  final List<HelpCategory> categories;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 3 : 2,
        mainAxisSpacing: AppSpacing.xs,
        crossAxisSpacing: AppSpacing.xs,
        childAspectRatio: 1.35,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return AppCard(
          tone: AppCardTone.low,
          onTap: () => context.push(RoutePaths.supportCategory(category.slug)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                helpCategoryIcon(category.icon),
                size: 26,
                color: context.scheme.primary,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                category.name,
                style: context.texts.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                context.tr(
                  'supportArticlesCount',
                  args: {'count': category.articleCount},
                ),
                style: context.texts.bodySmall?.copyWith(
                  color: context.dukavo.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SupportSearchResults extends ConsumerWidget {
  const _SupportSearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(helpSearchProvider(query));

    return results.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        message: publicErrorMessage(context, error),
        onRetry: () => ref.invalidate(helpSearchProvider(query)),
      ),
      data: (data) {
        if (data.articles.isEmpty && data.categories.isEmpty) {
          return EmptyState(
            title: context.tr('supportSearchEmptyTitle'),
            message: context.tr('supportSearchEmptyBody'),
            icon: Icons.search_off_rounded,
          );
        }

        return ListView(
          padding: AppSpacing.page,
          children: [
            if (data.categories.isNotEmpty) ...[
              SectionHeader(title: context.tr('supportBrowseTopics')),
              for (final category in data.categories)
                Padding(
                  padding:
                      const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
                  child: _HelpCategoryRow(category: category),
                ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (data.articles.isNotEmpty) ...[
              SectionHeader(title: context.tr('helpCenter')),
              for (final article in data.articles)
                Padding(
                  padding:
                      const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
                  child: _HelpArticleCard(article: article),
                ),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        );
      },
    );
  }
}

class _HelpCategoryRow extends StatelessWidget {
  const _HelpCategoryRow({required this.category});

  final HelpCategory category;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(RoutePaths.supportCategory(category.slug)),
      child: Row(
        children: [
          Icon(
            helpCategoryIcon(category.icon),
            size: 22,
            color: context.scheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              category.name,
              style: context.texts.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            context.tr(
              'supportArticlesCount',
              args: {'count': category.articleCount},
            ),
            style: context.texts.bodySmall?.copyWith(
              color: context.dukavo.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpArticleCard extends StatelessWidget {
  const _HelpArticleCard({required this.article});

  final HelpArticle article;

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (article.category != null) article.category!.name,
      context.tr('readingMinutes', args: {'count': article.readingMinutes}),
    ].join(' · ');

    return AppCard(
      onTap: () =>
          context.push(RoutePaths.supportArticle(article.localizedSlug)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: context.texts.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (article.excerpt.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    article.excerpt,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.dukavo.textSecondary,
                      height: 1.45,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  meta,
                  style: context.texts.labelSmall?.copyWith(
                    color: context.dukavo.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (article.coverImageUrl != null) ...[
            const SizedBox(width: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: CachedNetworkImage(
                imageUrl: article.coverImageUrl!,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  width: 64,
                  height: 64,
                  color: context.scheme.primaryContainer,
                  child: Icon(
                    Icons.menu_book_outlined,
                    color: context.scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A related guide: a link with a title and an excerpt, nothing more.
class _RelatedArticleCard extends StatelessWidget {
  const _RelatedArticleCard({required this.link});

  final HelpArticleLink link;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(RoutePaths.supportArticle(link.slug)),
      child: Row(
        children: [
          Icon(
            Icons.article_outlined,
            size: 20,
            color: context.scheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              link.title,
              style: context.texts.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// One topic: the articles inside a category, page by page.
class SupportCategoryScreen extends ConsumerStatefulWidget {
  const SupportCategoryScreen({super.key, required this.slug, this.category});

  final String slug;

  /// The already-loaded category, when navigation hands it over, so the
  /// screen paints its title immediately instead of showing a raw slug.
  final HelpCategory? category;

  @override
  ConsumerState<SupportCategoryScreen> createState() =>
      _SupportCategoryScreenState();
}

class _SupportCategoryScreenState extends ConsumerState<SupportCategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(helpCategoryFeedProvider(widget.slug).notifier).loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(helpCategoryFeedProvider(widget.slug));
    final notifier = ref.read(helpCategoryFeedProvider(widget.slug).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category?.name ?? context.tr('helpCenter')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: notifier.reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: PagedListView<HelpArticle>(
        state: state,
        onRefresh: notifier.reload,
        onLoadMore: notifier.loadMore,
        padding: AppSpacing.page,
        empty: EmptyState(
          title: context.tr('supportEmptyCategoryTitle'),
          message: context.tr('supportEmptyCategoryBody'),
          icon: Icons.help_outline_rounded,
        ),
        itemBuilder: (context, article, index) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
            child: _HelpArticleCard(article: article),
          );
        },
      ),
    );
  }
}

/// One guide, in the reader's language. The body is the server-sanitised HTML,
/// rendered by the same dependency-free [SanitizedHtml] the newsletter reader
/// uses; copy answered in Arabic flows right-to-left.
class SupportArticleScreen extends ConsumerWidget {
  const SupportArticleScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final article = ref.watch(helpArticleProvider(slug));

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('helpCenter'))),
      body: article.when(
        loading: () => const LoadingView(),
        error: (error, _) {
          // A restricted or unknown guide is a 404: the honest answer to a
          // guessed link, never a "forbidden" hint that it exists.
          final missing = error is ApiException && error.statusCode == 404;

          if (missing) {
            return EmptyState(
              title: context.tr('supportNotFoundTitle'),
              message: context.tr('supportNotFoundBody'),
              icon: Icons.help_outline_rounded,
            );
          }

          return ErrorView(
            message: publicErrorMessage(context, error),
            onRetry: () => ref.invalidate(helpArticleProvider(slug)),
          );
        },
        data: (item) => _SupportArticleBody(article: item),
      ),
    );
  }
}

class _SupportArticleBody extends ConsumerWidget {
  const _SupportArticleBody({required this.article});

  final HelpArticle article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final direction =
        article.isArabic ? TextDirection.rtl : Directionality.of(context);
    final meta = [
      if (article.publishedAt != null) Formatters.date(article.publishedAt),
      context.tr('readingMinutes', args: {'count': article.readingMinutes}),
      if (article.authorName != null && article.authorName!.isNotEmpty)
        article.authorName!,
    ].join(' · ');

    return Directionality(
      textDirection: direction,
      child: SingleChildScrollView(
        padding: AppSpacing.page,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.coverImageUrl != null) ...[
              ClipRRect(
                borderRadius: AppRadius.card,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: article.coverImageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.primaryContainer,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.menu_book_outlined,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (article.category != null)
              Padding(
                padding:
                    const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
                child: ActionChip(
                  avatar: Icon(
                    helpCategoryIcon(article.category!.icon),
                    size: 16,
                    color: context.scheme.primary,
                  ),
                  label: Text(article.category!.name),
                  onPressed: () => context
                      .push(RoutePaths.supportCategory(article.category!.slug)),
                ),
              ),
            Text(
              article.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              meta,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (article.body != null && article.body!.trim().isNotEmpty)
              SanitizedHtml(html: article.body!)
            else
              Text(
                article.excerpt,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.7,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            if (article.tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final tag in article.tags)
                    Chip(
                      label: Text(tag.name),
                      labelStyle: theme.textTheme.labelSmall,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            HelpFeedbackWidget(
              slug: article.slug,
              helpfulness: article.helpfulness,
            ),
            if (article.relatedArticles.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: context.tr('supportRelated')),
              for (final related in article.relatedArticles)
                Padding(
                  padding:
                      const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
                  child: _RelatedArticleCard(link: related),
                ),
            ],
            if (article.previous != null || article.next != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: article.previous == null
                        ? const SizedBox.shrink()
                        : AppButton(
                            label: article.previous!.title,
                            icon: Icons.arrow_back_rounded,
                            variant: AppButtonVariant.outlined,
                            expand: true,
                            onPressed: () => context.push(
                              RoutePaths.supportArticle(
                                article.previous!.slug,
                              ),
                            ),
                          ),
                  ),
                  if (article.previous != null && article.next != null)
                    const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: article.next == null
                        ? const SizedBox.shrink()
                        : AppButton(
                            label: article.next!.title,
                            icon: Icons.arrow_forward_rounded,
                            variant: AppButtonVariant.outlined,
                            expand: true,
                            onPressed: () => context.push(
                              RoutePaths.supportArticle(article.next!.slug),
                            ),
                          ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: context.tr('supportAllTopics'),
              icon: Icons.help_outline_rounded,
              variant: AppButtonVariant.tonal,
              expand: true,
              onPressed: () => context.go(RoutePaths.support),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

/// "Was this helpful?" on one guide. The server deduplicates by account, and a
/// remembered answer keeps the question from being asked again on the next
/// visit, the same way the web reader remembers it.
class HelpFeedbackWidget extends ConsumerStatefulWidget {
  const HelpFeedbackWidget({super.key, required this.slug, this.helpfulness});

  final String slug;

  /// The article's helpful-vote percentage, shown next to the question when
  /// anyone has voted yet.
  final int? helpfulness;

  @override
  ConsumerState<HelpFeedbackWidget> createState() => _HelpFeedbackWidgetState();
}

class _HelpFeedbackWidgetState extends ConsumerState<HelpFeedbackWidget> {
  final _comment = TextEditingController();
  bool? _choice;
  bool _sending = false;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _answered =
        ref.read(appPreferencesProvider).hasAnsweredHelpFeedback(widget.slug);
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_choice == null || _sending) return;

    setState(() => _sending = true);
    try {
      await ref.read(helpRepositoryProvider).submitFeedback(
            slug: widget.slug,
            helpful: _choice!,
            comment: _comment.text,
          );
      await ref
          .read(appPreferencesProvider)
          .markHelpFeedbackAnswered(widget.slug);
      if (mounted) setState(() => _answered = true);
    } catch (_) {
      // A failed send leaves the question answerable; the reader can retry.
      if (mounted) {
        setState(() => _sending = false);
        AppSnack.show(
          context,
          context.tr('supportFeedbackFailed'),
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    if (_answered) {
      return AppCard(
        tone: AppCardTone.low,
        child: Row(
          children: [
            Icon(
              _choice == false
                  ? Icons.thumb_down_alt_outlined
                  : Icons.thumb_up_alt_outlined,
              size: 20,
              color: scheme.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                context.tr('supportFeedbackThanks'),
                style: context.texts.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      tone: AppCardTone.low,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('supportFeedbackTitle'),
                  style: context.texts.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (widget.helpfulness != null)
                Text(
                  '${widget.helpfulness}%',
                  style: context.texts.labelSmall?.copyWith(
                    color: context.dukavo.textMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: context.tr('supportFeedbackYes'),
                  icon: Icons.thumb_up_alt_outlined,
                  variant: _choice == true
                      ? AppButtonVariant.filled
                      : AppButtonVariant.outlined,
                  expand: true,
                  onPressed:
                      _sending ? null : () => setState(() => _choice = true),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: AppButton(
                  label: context.tr('supportFeedbackNo'),
                  icon: Icons.thumb_down_alt_outlined,
                  variant: _choice == false
                      ? AppButtonVariant.filled
                      : AppButtonVariant.outlined,
                  expand: true,
                  onPressed:
                      _sending ? null : () => setState(() => _choice = false),
                ),
              ),
            ],
          ),
          if (_choice != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              context.tr('supportFeedbackCommentLabel'),
              style: context.texts.bodySmall?.copyWith(
                color: context.dukavo.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            TextField(
              controller: _comment,
              minLines: 2,
              maxLines: 4,
              maxLength: 1000,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: context.tr('supportFeedbackCommentHint'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: context.tr('supportFeedbackSend'),
              icon: Icons.send_rounded,
              expand: true,
              loading: _sending,
              onPressed: _sending ? null : _send,
            ),
          ],
        ],
      ),
    );
  }
}
