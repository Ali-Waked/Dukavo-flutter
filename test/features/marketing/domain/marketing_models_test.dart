import 'package:dukavo_mobile/features/marketing/domain/marketing_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarketingFeature.fromJson', () {
    test('marks available and coming-soon capabilities honestly', () {
      final available = MarketingFeature.fromJson(const {
        'slug': 'orders',
        'name': 'Orders',
        'description': 'Track every order.',
        'status': 'available',
      });
      final comingSoon = MarketingFeature.fromJson(const {
        'slug': 'ai',
        'name': 'AI',
        'status': 'coming_soon',
      });

      expect(available.isAvailable, isTrue);
      expect(comingSoon.isAvailable, isFalse);
      expect(comingSoon.description, '');
    });
  });

  group('PricingPlan.fromJson', () {
    test('keeps a missing price as null instead of inventing zero', () {
      final plan = PricingPlan.fromJson(const {
        'id': 4,
        'name': 'Growth',
        'slug': 'growth',
        'billing_interval': 'monthly',
        'billing_interval_label': 'Monthly',
        'purchase_available': false,
        'highlighted': true,
        'features': [
          'Unlimited orders',
          {'label': 'Multi-store'}
        ],
        'limits': ['2 users'],
      });

      expect(plan.price, isNull);
      expect(plan.highlighted, isTrue);
      expect(plan.purchaseAvailable, isFalse);
      expect(plan.features, ['Unlimited orders', 'Multi-store']);
      expect(plan.limits, ['2 users']);
    });

    test('reads a numeric price and defaults the currency', () {
      final plan = PricingPlan.fromJson(const {
        'id': '5',
        'name': 'Starter',
        'price': 99.5,
      });

      expect(plan.id, 5);
      expect(plan.price, 99.5);
      expect(plan.currency, 'USD');
    });
  });

  group('FaqEntry.fromJson', () {
    test('parses a question and optional category', () {
      final entry = FaqEntry.fromJson(const {
        'id': 1,
        'question': 'How do I start?',
        'answer': 'Create a workspace.',
        'category': 'Getting started',
      });

      expect(entry.question, 'How do I start?');
      expect(entry.category, 'Getting started');
    });
  });

  group('NewsletterArticle.fromJson', () {
    test('parses list metadata without a body', () {
      final article = NewsletterArticle.fromJson(const {
        'id': 9,
        'slug': 'launch',
        'title': 'Launch',
        'excerpt': 'We launched.',
        'cover_image_url': 'https://cdn.example.com/cover.png',
        'reading_minutes': 4,
        'published_at': '2026-01-01T00:00:00Z',
      });

      expect(article.slug, 'launch');
      expect(article.readingMinutes, 4);
      expect(article.body, isNull);
      expect(article.coverImageUrl, 'https://cdn.example.com/cover.png');
    });
  });

  group('ContentPage.fromJson', () {
    test('parses intro, sections and metadata', () {
      final page = ContentPage.fromJson(const {
        'key': 'privacy',
        'title': 'Privacy policy',
        'intro': 'How we handle data.',
        'meta_title': 'Privacy',
        'meta_description': 'Our privacy policy.',
        'published_at': '2026-01-01',
        'sections': [
          {
            'id': 'data',
            'title': 'Data',
            'body': '<p>We store little.</p>',
            'layout': 'text',
          },
          {
            'id': 'rights',
            'title': 'Rights',
            'body': '<p>You have rights.</p>',
          },
        ],
      });

      expect(page.key, 'privacy');
      expect(page.sections, hasLength(2));
      expect(page.sections.first.layout, 'text');
      expect(page.sections.last.layout, 'text');
      expect(page.metaTitle, 'Privacy');
    });
  });
}
