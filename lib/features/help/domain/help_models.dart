/// Help Center payloads, mirroring the authenticated reader API.
///
/// The server resolves every field to the reader's language (canonical
/// English, the legacy `_ar` columns, then approved ledger translations), so
/// these models carry single-language strings and never repeat the fallback
/// rule. `localized_slug` is the slug the reader's language should link to;
/// the canonical `slug` remains what identifies the record.
library;

class HelpCategory {
  const HelpCategory({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.icon,
    required this.isFeatured,
    required this.articleCount,
  });

  final int id;
  final String slug;
  final String name;
  final String description;
  final String icon;
  final bool isFeatured;

  /// How many articles the current reader may open inside this category. The
  /// count is visibility-aware on the server, so it can differ per account.
  final int articleCount;

  factory HelpCategory.fromJson(Map<String, dynamic> json) {
    return HelpCategory(
      id: _int(json['id']),
      slug: '${json['slug'] ?? ''}',
      name: '${json['name'] ?? ''}',
      description: '${json['description'] ?? ''}',
      icon: '${json['icon'] ?? ''}',
      isFeatured: json['is_featured'] == true,
      articleCount: _int(json['article_count']),
    );
  }
}

/// A category nested inside an article payload.
class HelpCategoryRef {
  const HelpCategoryRef({
    required this.slug,
    required this.name,
    required this.icon,
  });

  final String slug;
  final String name;
  final String icon;

  factory HelpCategoryRef.fromJson(Map<String, dynamic> json) {
    return HelpCategoryRef(
      slug: '${json['slug'] ?? ''}',
      name: '${json['name'] ?? ''}',
      icon: '${json['icon'] ?? ''}',
    );
  }
}

class HelpTagRef {
  const HelpTagRef({required this.slug, required this.name});

  final String slug;
  final String name;

  factory HelpTagRef.fromJson(Map<String, dynamic> json) {
    return HelpTagRef(
      slug: '${json['slug'] ?? ''}',
      name: '${json['name'] ?? ''}',
    );
  }
}

/// An article as the list and search surfaces return it. The detail-only
/// fields ([body], [author], neighbours) stay null on summaries.
class HelpArticle {
  const HelpArticle({
    required this.id,
    required this.slug,
    required this.localizedSlug,
    required this.title,
    required this.excerpt,
    required this.isFeatured,
    required this.readingMinutes,
    required this.viewCount,
    required this.locale,
    this.coverImageUrl,
    this.category,
    this.tags = const <HelpTagRef>[],
    this.helpfulness,
    this.publishedAt,
    this.updatedAt,
    this.body,
    this.videoUrl,
    this.authorName,
    this.helpfulCount,
    this.unhelpfulCount,
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords = const <String>[],
    this.relatedArticles = const <HelpArticleLink>[],
    this.previous,
    this.next,
  });

  final int id;

  /// The canonical slug, stable across languages.
  final String slug;

  /// The slug the reader's language links to; equals [slug] when unchanged.
  final String localizedSlug;

  final String title;
  final String excerpt;
  final String? coverImageUrl;
  final HelpCategoryRef? category;
  final List<HelpTagRef> tags;
  final bool isFeatured;
  final int readingMinutes;
  final int viewCount;

  /// Helpful-vote percentage, or null when nobody has voted yet.
  final int? helpfulness;
  final String? publishedAt;
  final String? updatedAt;

  /// The language the copy was resolved to, for text direction.
  final String locale;

  // Detail-only fields.
  final String? body;
  final String? videoUrl;
  final String? authorName;
  final int? helpfulCount;
  final int? unhelpfulCount;
  final String? metaTitle;
  final String? metaDescription;
  final List<String> metaKeywords;
  final List<HelpArticleLink> relatedArticles;
  final HelpArticleLink? previous;
  final HelpArticleLink? next;

  bool get isArabic => locale.toLowerCase().startsWith('ar');

  factory HelpArticle.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'];
    final rawTags = json['tags'];
    final rawRelated = json['related_articles'];
    final rawKeywords = json['meta_keywords'];

    return HelpArticle(
      id: _int(json['id']),
      slug: '${json['slug'] ?? ''}',
      localizedSlug: '${json['localized_slug'] ?? json['slug'] ?? ''}',
      title: '${json['title'] ?? ''}',
      excerpt: '${json['excerpt'] ?? ''}',
      coverImageUrl: json['cover_image_url'] as String?,
      category: rawCategory is Map
          ? HelpCategoryRef.fromJson(Map<String, dynamic>.from(rawCategory))
          : null,
      tags: rawTags is List
          ? rawTags
              .whereType<Map>()
              .map((entry) =>
                  HelpTagRef.fromJson(Map<String, dynamic>.from(entry)))
              .toList()
          : const <HelpTagRef>[],
      isFeatured: json['is_featured'] == true,
      readingMinutes: _int(json['reading_minutes']),
      viewCount: _int(json['view_count']),
      helpfulness: _nullableInt(json['helpfulness']),
      publishedAt: json['published_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      locale: '${json['locale'] ?? 'en'}',
      body: json['body'] as String?,
      videoUrl: json['video_url'] as String?,
      authorName:
          json['author'] is Map ? '${json['author']['name'] ?? ''}' : null,
      helpfulCount: _nullableInt(json['helpful_count']),
      unhelpfulCount: _nullableInt(json['unhelpful_count']),
      metaTitle: json['meta_title'] as String?,
      metaDescription: json['meta_description'] as String?,
      metaKeywords: rawKeywords is List
          ? rawKeywords.whereType<String>().toList()
          : const <String>[],
      relatedArticles: rawRelated is List
          ? rawRelated
              .whereType<Map>()
              .map((entry) =>
                  HelpArticleLink.fromJson(Map<String, dynamic>.from(entry)))
              .toList()
          : const <HelpArticleLink>[],
      previous: json['previous'] is Map
          ? HelpArticleLink.fromJson(
              Map<String, dynamic>.from(json['previous'] as Map))
          : null,
      next: json['next'] is Map
          ? HelpArticleLink.fromJson(
              Map<String, dynamic>.from(json['next'] as Map))
          : null,
    );
  }
}

/// A related, previous or next article: enough to link to, nothing more.
class HelpArticleLink {
  const HelpArticleLink({
    required this.slug,
    required this.title,
    this.excerpt,
  });

  final String slug;
  final String title;
  final String? excerpt;

  factory HelpArticleLink.fromJson(Map<String, dynamic> json) {
    return HelpArticleLink(
      slug: '${json['slug'] ?? ''}',
      title: '${json['title'] ?? ''}',
      excerpt: json['excerpt'] as String?,
    );
  }
}

class HelpSearchResults {
  const HelpSearchResults({
    required this.query,
    required this.articles,
    required this.categories,
  });

  final String query;
  final List<HelpArticle> articles;
  final List<HelpCategory> categories;

  factory HelpSearchResults.fromJson(Map<String, dynamic> json) {
    final rawArticles = json['articles'];
    final rawCategories = json['categories'];

    return HelpSearchResults(
      query: '${json['query'] ?? ''}',
      articles: rawArticles is List
          ? rawArticles
              .whereType<Map>()
              .map((entry) =>
                  HelpArticle.fromJson(Map<String, dynamic>.from(entry)))
              .toList()
          : const <HelpArticle>[],
      categories: rawCategories is List
          ? rawCategories
              .whereType<Map>()
              .map((entry) =>
                  HelpCategory.fromJson(Map<String, dynamic>.from(entry)))
              .toList()
          : const <HelpCategory>[],
    );
  }
}

int _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

int? _nullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}
