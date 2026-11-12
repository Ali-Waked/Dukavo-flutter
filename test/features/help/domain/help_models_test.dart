import 'package:dukavo_mobile/features/help/domain/help_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HelpCategory.fromJson', () {
    test('decodes a category with its visibility-aware article count', () {
      final category = HelpCategory.fromJson(const {
        'id': 3,
        'slug': 'orders-and-customers',
        'name': 'Orders and customers',
        'description': 'Taking and fulfilling orders.',
        'icon': 'cart',
        'is_featured': false,
        'article_count': 12,
      });

      expect(category.id, 3);
      expect(category.slug, 'orders-and-customers');
      expect(category.icon, 'cart');
      expect(category.isFeatured, isFalse);
      expect(category.articleCount, 12);
    });

    test('keeps a missing article count as zero instead of crashing', () {
      final category = HelpCategory.fromJson(const {
        'id': 1,
        'slug': 'getting-started',
        'name': 'Getting started',
        'description': '',
        'icon': 'rocket',
      });

      expect(category.articleCount, 0);
      expect(category.isFeatured, isFalse);
    });
  });

  group('HelpArticle.fromJson', () {
    test('prefers the localized slug but links by it', () {
      final article = HelpArticle.fromJson(const {
        'id': 7,
        'slug': 'first-order',
        'localized_slug': 'أول-طلب',
        'title': 'Take your first order',
        'excerpt': 'From installation to the first sale.',
        'reading_minutes': 4,
        'view_count': 9,
        'locale': 'en',
      });

      expect(article.slug, 'first-order');
      expect(article.localizedSlug, 'أول-طلب');
      // The reader's language links through the localized slug.
      expect(article.localizedSlug, isNot(article.slug));
    });

    test('falls back to the canonical slug when localized slug is absent', () {
      final article = HelpArticle.fromJson(const {
        'id': 7,
        'slug': 'first-order',
        'title': 'Take your first order',
        'excerpt': '',
        'reading_minutes': 4,
        'view_count': 9,
        'locale': 'en',
      });

      expect(article.localizedSlug, 'first-order');
    });

    test('decodes the category and tags nested on the payload', () {
      final article = HelpArticle.fromJson(const {
        'id': 7,
        'slug': 'first-order',
        'localized_slug': 'first-order',
        'title': 'Take your first order',
        'excerpt': '',
        'reading_minutes': 4,
        'view_count': 9,
        'locale': 'en',
        'category': {
          'slug': 'getting-started',
          'name': 'Getting started',
          'icon': 'rocket',
        },
        'tags': [
          {'slug': 'orders', 'name': 'Orders'},
          {'slug': 'setup', 'name': 'Setup'},
        ],
      });

      expect(article.category?.slug, 'getting-started');
      expect(article.category?.icon, 'rocket');
      expect(article.tags, hasLength(2));
      expect(article.tags.last.name, 'Setup');
    });

    test('keeps helpfulness nullable when nobody has voted', () {
      final unvoted = HelpArticle.fromJson(const {
        'id': 7,
        'slug': 'first-order',
        'title': 'Take your first order',
        'excerpt': '',
        'reading_minutes': 4,
        'view_count': 9,
        'locale': 'en',
      });
      final voted = HelpArticle.fromJson(const {
        'id': 8,
        'slug': 'refunds',
        'title': 'Refund an order',
        'excerpt': '',
        'reading_minutes': 3,
        'view_count': 0,
        'locale': 'en',
        'helpfulness': 86,
        'helpful_count': 6,
        'unhelpful_count': 1,
      });

      expect(unvoted.helpfulness, isNull);
      expect(unvoted.helpfulCount, isNull);
      expect(voted.helpfulness, 86);
      expect(voted.helpfulCount, 6);
      expect(voted.unhelpfulCount, 1);
    });

    test('reads the author name out of the nested author object', () {
      final article = HelpArticle.fromJson(const {
        'id': 7,
        'slug': 'first-order',
        'title': 'Take your first order',
        'excerpt': '',
        'reading_minutes': 4,
        'view_count': 9,
        'locale': 'en',
        'author': {
          'id': 2,
          'name': 'Platform Editor',
        },
      });

      expect(article.authorName, 'Platform Editor');
    });

    test('marks Arabic copy so the reader can flow right-to-left', () {
      final english = HelpArticle.fromJson(const {
        'id': 7,
        'slug': 'first-order',
        'title': 'Take your first order',
        'excerpt': '',
        'reading_minutes': 4,
        'view_count': 9,
        'locale': 'en',
      });
      final arabic = HelpArticle.fromJson(const {
        'id': 7,
        'slug': 'first-order',
        'title': 'أول طلب لك',
        'excerpt': '',
        'reading_minutes': 4,
        'view_count': 9,
        'locale': 'ar',
      });

      expect(english.isArabic, isFalse);
      expect(arabic.isArabic, isTrue);
    });

    test('decodes related, previous and next article links', () {
      final article = HelpArticle.fromJson(const {
        'id': 7,
        'slug': 'first-order',
        'title': 'Take your first order',
        'excerpt': '',
        'reading_minutes': 4,
        'view_count': 9,
        'locale': 'en',
        'related_articles': [
          {'slug': 'refunds', 'title': 'Refund an order'},
        ],
        'previous': {'slug': 'install', 'title': 'Install Dukavo'},
        'next': {'slug': 'shipping', 'title': 'Set up shipping'},
      });

      expect(article.relatedArticles, hasLength(1));
      expect(article.relatedArticles.first.slug, 'refunds');
      expect(article.previous?.slug, 'install');
      expect(article.next?.title, 'Set up shipping');
    });
  });

  group('HelpSearchResults.fromJson', () {
    test('decodes articles and categories found by a search', () {
      final results = HelpSearchResults.fromJson(const {
        'query': 'refund',
        'articles': [
          {
            'id': 8,
            'slug': 'refunds',
            'localized_slug': 'refunds',
            'title': 'Refund an order',
            'excerpt': 'How to return money.',
            'reading_minutes': 3,
            'view_count': 5,
            'locale': 'en',
          },
        ],
        'categories': [
          {
            'id': 1,
            'slug': 'payments',
            'name': 'Payments',
            'description': '',
            'icon': 'credit-card',
            'is_featured': true,
            'article_count': 6,
          },
        ],
      });

      expect(results.query, 'refund');
      expect(results.articles, hasLength(1));
      expect(results.articles.first.title, 'Refund an order');
      expect(results.categories, hasLength(1));
      expect(results.categories.first.icon, 'credit-card');
      expect(results.categories.first.articleCount, 6);
    });

    test('tolerates an empty result set without inventing entries', () {
      final results = HelpSearchResults.fromJson(const {
        'query': 'zzz-nothing',
        'articles': [],
        'categories': [],
      });

      expect(results.query, 'zzz-nothing');
      expect(results.articles, isEmpty);
      expect(results.categories, isEmpty);
    });
  });
}
