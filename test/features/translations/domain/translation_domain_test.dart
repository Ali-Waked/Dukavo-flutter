import 'package:dukavo_mobile/features/translations/domain/translation_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TranslationRow', () {
    test('parses a generated proposal awaiting review', () {
      final row = TranslationRow.fromJson(const {
        'id': 41,
        'locale': 'fr',
        'field': 'name',
        'status': 'needs_review',
        'status_label': 'Needs review',
        'translated_text': 'Café de la ville',
        'published_text': null,
        'manually_edited': false,
        'origin': 'ai',
        'source_locale': 'en',
        'provider': 'grok',
        'model': 'grok-3',
        'generated_at': '2024-02-01T09:00:00Z',
        'reviewed_at': null,
        'reviewed_by': null,
        'rejection_reason': null,
        'updated_at': '2024-02-01T09:00:00Z',
      });

      expect(row.id, 41);
      expect(row.locale, 'fr');
      expect(row.field, 'name');
      expect(row.status, 'needs_review');
      expect(row.translatedText, 'Café de la ville');
      expect(row.publishedText, isNull);
      expect(row.origin, 'ai');
      expect(row.sourceLocale, 'en');
      expect(row.provider, 'grok');
      expect(row.hasCopy, isTrue);
      expect(row.canBeSelected, isTrue);
    });

    test('keeps the approved copy visible while a stale draft waits', () {
      final row = TranslationRow.fromJson(const {
        'id': 7,
        'locale': 'ar',
        'field': 'description',
        'status': 'stale',
        'translated_text': 'مسودة محدثة',
        'published_text': 'النص المعتمد السابق',
        'manually_edited': true,
        'origin': 'manual',
      });

      expect(row.isStale, isTrue);
      expect(row.manuallyEdited, isTrue);
      expect(row.translatedText, 'مسودة محدثة');
      expect(row.publishedText, 'النص المعتمد السابق');
      expect(row.canBeSelected, isTrue);
    });

    test('an approved row is not offered for selection again', () {
      final row = TranslationRow.fromJson(const {
        'id': 8,
        'locale': 'ar',
        'field': 'title',
        'status': 'approved',
      });

      expect(row.isApproved, isTrue);
      expect(row.canBeSelected, isFalse);
    });

    test('an unsaved not-translated row cannot be selected', () {
      final row = TranslationRow.fromJson(const {
        'locale': 'ar',
        'field': 'title',
        'status': 'not_translated',
      });

      expect(row.id, isNull);
      expect(row.hasCopy, isFalse);
      expect(row.canBeSelected, isFalse);
    });

    test('a generating row is locked while the provider is working', () {
      final row = TranslationRow.fromJson(const {
        'id': 9,
        'locale': 'ar',
        'field': 'title',
        'status': 'generating',
      });

      expect(row.isGenerating, isTrue);
      expect(row.canBeSelected, isFalse);
    });
  });

  group('TranslationOverview', () {
    test('parses source detection, nested field keys and per-locale rows', () {
      final overview = TranslationOverview.fromJson(const {
        'entity': {
          'key': 'store',
          'label': 'Store',
          'id': 12,
          'name': 'City Centre',
          'tenant_scoped': true,
        },
        'source_locale': 'en',
        'source_detection': {
          'locale': 'en',
          'confidence': 0.97,
          'method': 'unicode',
        },
        'source_required': false,
        'enabled_locales': ['en', 'ar', 'fr'],
        'target_locales': ['ar', 'fr'],
        'fields': [
          {'key': 'name', 'label': 'Store name', 'format': 'text'},
          {'key': 'settings.tagline', 'label': 'Tagline', 'format': 'text'},
          {'key': 'settings.about', 'label': 'About', 'format': 'html'},
        ],
        'sources': {
          'name': 'City Centre',
          'settings.tagline': 'Fresh every day',
          'settings.about': '<p>Family run.</p>',
        },
        'translations': {
          'ar': {
            'name': {
              'id': 1,
              'locale': 'ar',
              'field': 'name',
              'status': 'approved',
              'translated_text': 'وسط المدينة',
            },
            'settings.tagline': {
              'id': 2,
              'locale': 'ar',
              'field': 'settings.tagline',
              'status': 'needs_review',
              'translated_text': 'طازج كل يوم',
            },
          },
          'fr': <String, dynamic>{},
        },
        'summary': {'approved': 1, 'needs_review': 1},
      });

      expect(overview.entity.key, 'store');
      expect(overview.entity.name, 'City Centre');
      expect(overview.entity.tenantScoped, isTrue);
      expect(overview.sourceLocale, 'en');
      expect(overview.sourceRequired, isFalse);
      expect(overview.sourceDetection.locale, 'en');
      expect(overview.sourceDetection.confidence, closeTo(0.97, 0.0001));
      expect(overview.enabledLocales, ['en', 'ar', 'fr']);
      expect(overview.targetLocales, ['ar', 'fr']);
      expect(overview.fields.map((field) => field.key), [
        'name',
        'settings.tagline',
        'settings.about',
      ]);
      expect(overview.field('settings.about')?.isHtml, isTrue);
      expect(overview.sources['settings.tagline'], 'Fresh every day');
      expect(overview.translations['ar']?['name']?.isApproved, isTrue);
      expect(
        overview.translations['ar']?['settings.tagline']?.translatedText,
        'طازج كل يوم',
      );
      expect(overview.translations['fr'], isEmpty);
      expect(overview.summary['approved'], 1);
      expect(overview.isEmpty, isFalse);
    });

    test('reports a required source language when detection is not confident', () {
      final overview = TranslationOverview.fromJson(const {
        'entity': {
          'key': 'product',
          'label': 'Product',
          'id': 3,
          'name': 'Mug',
          'tenant_scoped': true,
        },
        'source_locale': null,
        'source_detection': {
          'locale': null,
          'confidence': 0,
          'method': 'none',
        },
        'source_required': true,
        'enabled_locales': ['en', 'ar'],
        'target_locales': ['en', 'ar'],
        'fields': <dynamic>[],
        'sources': <String, dynamic>{},
        'translations': <String, dynamic>{},
        'summary': <String, dynamic>{},
      });

      expect(overview.sourceLocale, isNull);
      expect(overview.sourceRequired, isTrue);
      expect(overview.sourceDetection.locale, isNull);
      expect(overview.sourceDetection.method, 'none');
      expect(overview.isEmpty, isTrue);
    });
  });

  group('TranslationUsage', () {
    test('parses the daily usage summary', () {
      final usage = TranslationUsage.fromJson(const {
        'requests': 4,
        'input_tokens': 1200,
        'output_tokens': 800,
        'total_tokens': 2000,
        'estimated_cost': 0.0123,
      });

      expect(usage.requests, 4);
      expect(usage.totalTokens, 2000);
      expect(usage.estimatedCost, closeTo(0.0123, 0.000001));
      expect(TranslationUsage.empty.requests, 0);
    });

    test('degrades malformed counters to zero', () {
      final usage = TranslationUsage.fromJson(const {
        'requests': 'not-a-number',
        'total_tokens': null,
      });

      expect(usage.requests, 0);
      expect(usage.totalTokens, 0);
      expect(usage.estimatedCost, 0);
    });
  });

  group('GenerateTranslationsResult', () {
    test('parses the generated row map with source detection', () {
      final result = GenerateTranslationsResult.fromJson(const {
        'source_locale': 'en',
        'source_detection': {
          'locale': 'en',
          'confidence': 0.91,
          'method': 'unicode',
        },
        'results': [
          {'locale': 'ar', 'status': 'generated', 'fields': ['name']},
        ],
        'translations': {
          'ar': {
            'name': {
              'id': 55,
              'locale': 'ar',
              'field': 'name',
              'status': 'generated',
              'translated_text': 'كوب',
            },
          },
        },
      });

      expect(result.sourceLocale, 'en');
      expect(result.sourceDetection.locale, 'en');
      expect(result.translations['ar']?['name']?.translatedText, 'كوب');
      expect(result.translations['ar']?['name']?.isApproved, isFalse);
    });
  });

  group('translationLanguageLabel', () {
    test('labels a supported language and preserves an unknown code', () {
      expect(translationLanguageLabel('fr'), 'Français');
      expect(translationLanguageLabel('ar'), 'العربية');
      expect(translationLanguageLabel('xx'), 'XX');
    });
  });
}
