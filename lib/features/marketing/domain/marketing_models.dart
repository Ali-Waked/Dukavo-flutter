/// Public marketing payloads.
///
/// These mirror the public API exactly. Nothing here computes a price or a
/// claim: an unpublished plan keeps `price == null` and a feature marked
/// `coming_soon` is displayed as such rather than as an available capability.
library;

class MarketingFeature {
  const MarketingFeature({
    required this.slug,
    required this.name,
    required this.description,
    required this.status,
  });

  final String slug;
  final String name;
  final String description;
  final String status;

  bool get isAvailable => status == 'available';

  factory MarketingFeature.fromJson(Map<String, dynamic> json) {
    return MarketingFeature(
      slug: '${json['slug'] ?? ''}',
      name: '${json['name'] ?? ''}',
      description: '${json['description'] ?? ''}',
      status: '${json['status'] ?? 'available'}',
    );
  }
}

class PricingPlan {
  const PricingPlan({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.currency,
    required this.billingInterval,
    required this.billingIntervalLabel,
    required this.purchaseAvailable,
    required this.highlighted,
    required this.features,
    required this.limits,
  });

  final int id;
  final String name;
  final String slug;
  final String description;
  final num? price;
  final String currency;
  final String billingInterval;
  final String billingIntervalLabel;
  final bool purchaseAvailable;
  final bool highlighted;
  final List<String> features;
  final List<String> limits;

  factory PricingPlan.fromJson(Map<String, dynamic> json) {
    return PricingPlan(
      id: _int(json['id']),
      name: '${json['name'] ?? ''}',
      slug: '${json['slug'] ?? ''}',
      description: '${json['description'] ?? ''}',
      price: json['price'] is num ? json['price'] as num : null,
      currency: '${json['currency'] ?? 'USD'}',
      billingInterval: '${json['billing_interval'] ?? ''}',
      billingIntervalLabel: '${json['billing_interval_label'] ?? ''}',
      purchaseAvailable: json['purchase_available'] == true,
      highlighted: json['highlighted'] == true,
      features: _stringList(json['features']),
      limits: _stringList(json['limits']),
    );
  }
}

class FaqEntry {
  const FaqEntry({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
  });

  final int id;
  final String question;
  final String answer;
  final String? category;

  factory FaqEntry.fromJson(Map<String, dynamic> json) {
    return FaqEntry(
      id: _int(json['id']),
      question: '${json['question'] ?? ''}',
      answer: '${json['answer'] ?? ''}',
      category: json['category'] as String?,
    );
  }
}

class NewsletterArticle {
  const NewsletterArticle({
    required this.id,
    required this.slug,
    required this.title,
    required this.excerpt,
    required this.coverImageUrl,
    required this.readingMinutes,
    required this.publishedAt,
    this.body,
    this.metaTitle,
    this.metaDescription,
  });

  final int id;
  final String slug;
  final String title;
  final String excerpt;
  final String? coverImageUrl;
  final int readingMinutes;
  final String? publishedAt;
  final String? body;
  final String? metaTitle;
  final String? metaDescription;

  factory NewsletterArticle.fromJson(Map<String, dynamic> json) {
    return NewsletterArticle(
      id: _int(json['id']),
      slug: '${json['slug'] ?? ''}',
      title: '${json['title'] ?? ''}',
      excerpt: '${json['excerpt'] ?? ''}',
      coverImageUrl: json['cover_image_url'] as String?,
      readingMinutes: _int(json['reading_minutes']),
      publishedAt: json['published_at'] as String?,
      body: json['body'] as String?,
      metaTitle: json['meta_title'] as String?,
      metaDescription: json['meta_description'] as String?,
    );
  }
}

class ContentSection {
  const ContentSection({
    required this.id,
    required this.title,
    required this.body,
    required this.layout,
  });

  final String id;
  final String title;
  final String body;
  final String layout;

  factory ContentSection.fromJson(Map<String, dynamic> json) {
    return ContentSection(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      body: '${json['body'] ?? ''}',
      layout: '${json['layout'] ?? 'text'}',
    );
  }
}

class ContentPage {
  const ContentPage({
    required this.key,
    required this.title,
    required this.intro,
    required this.sections,
    required this.metaTitle,
    required this.metaDescription,
    required this.publishedAt,
  });

  final String key;
  final String title;
  final String intro;
  final List<ContentSection> sections;
  final String? metaTitle;
  final String? metaDescription;
  final String? publishedAt;

  factory ContentPage.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'];
    return ContentPage(
      key: '${json['key'] ?? ''}',
      title: '${json['title'] ?? ''}',
      intro: '${json['intro'] ?? ''}',
      sections: rawSections is List
          ? rawSections
              .whereType<Map>()
              .map((entry) => ContentSection.fromJson(
                    Map<String, dynamic>.from(entry),
                  ))
              .toList()
          : const <ContentSection>[],
      metaTitle: json['meta_title'] as String?,
      metaDescription: json['meta_description'] as String?,
      publishedAt: json['published_at'] as String?,
    );
  }
}

int _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

List<String> _stringList(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .map((entry) {
        if (entry is Map) {
          return '${entry['label'] ?? entry['name'] ?? entry['value'] ?? ''}';
        }
        return '$entry';
      })
      .where((value) => value.isNotEmpty)
      .toList();
}
