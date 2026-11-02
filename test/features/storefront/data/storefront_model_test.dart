import 'package:dukavo_mobile/features/storefront/data/storefront_data.dart';
import 'package:dukavo_mobile/features/storefront/domain/storefront_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StorefrontSettingsModel.fromJson', () {
    test('parses the merchant storefront resource', () {
      final settings = StorefrontSettingsModel.fromJson(const {
        'store_id': 7,
        'name': 'Maadi shop',
        'slug': 'maadi-shop',
        'status': 'active',
        'description': 'Our neighbourhood shop.',
        'logo_url': 'https://cdn.example.com/logo.png',
        'storefront_enabled': true,
        'currency': 'EGP',
        'updated_at': '2024-02-01T09:00:00Z',
        'settings': {
          'tagline': 'Open every day',
          'about': 'Family run since 1990.',
          'hero_image_url': 'https://cdn.example.com/hero.jpg',
          'contact_email': 'shop@example.com',
          'contact_phone': '+201000000000',
          'whatsapp_number': '+201000000001',
          'address': '12 Road 9, Maadi',
          'social': {
            'facebook': 'https://facebook.com/shop',
            'instagram': 'https://instagram.com/shop',
            'tiktok': null,
          },
          'opening_hours': 'Daily 9am–9pm',
          'delivery_note': 'Delivery within 45 minutes.',
          'return_policy': 'Returns within 14 days.',
          'show_out_of_stock': false,
          'meta_title': 'Maadi shop',
          'meta_description': 'Everyday essentials in Maadi.',
        },
      }).toEntity();

      expect(settings.storeId, 7);
      expect(settings.name, 'Maadi shop');
      expect(settings.slug, 'maadi-shop');
      expect(settings.status, 'active');
      expect(settings.description, 'Our neighbourhood shop.');
      expect(settings.logoUrl, 'https://cdn.example.com/logo.png');
      expect(settings.storefrontEnabled, isTrue);
      expect(settings.currency, 'EGP');
      expect(settings.updatedAt, '2024-02-01T09:00:00Z');
      expect(settings.settings.tagline, 'Open every day');
      expect(settings.settings.contactEmail, 'shop@example.com');
      expect(settings.settings.whatsappNumber, '+201000000001');
      expect(settings.settings.facebook, 'https://facebook.com/shop');
      expect(settings.settings.instagram, 'https://instagram.com/shop');
      expect(settings.settings.tiktok, isNull);
      expect(settings.settings.showOutOfStock, isFalse);
      expect(settings.settings.metaTitle, 'Maadi shop');
    });

    test('applies safe defaults for a minimal payload', () {
      final settings = StorefrontSettingsModel.fromJson(const {}).toEntity();

      expect(settings.storeId, 0);
      expect(settings.name, '');
      expect(settings.slug, '');
      expect(settings.status, 'active');
      expect(settings.storefrontEnabled, isFalse);
      expect(settings.currency, 'USD');
      expect(settings.settings.showOutOfStock, isTrue);
      expect(settings.settings.facebook, isNull);
    });

    test('ignores malformed nested settings', () {
      final settings = StorefrontSettingsModel.fromJson(const {
        'settings': 'not-a-map',
      }).toEntity();

      expect(settings.settings.tagline, isNull);
      expect(settings.settings.facebook, isNull);
      expect(settings.settings.showOutOfStock, isTrue);
    });
  });

  group('StorefrontPresentationSettings.toJson', () {
    test('trims values and sends an explicit null for cleared fields', () {
      final json = const StorefrontPresentationSettings(
        tagline: '  Hello  ',
        contactEmail: '   ',
        showOutOfStock: false,
        facebook: ' https://facebook.com/shop ',
      ).toJson();

      expect(json['tagline'], 'Hello');
      expect(json['contact_email'], isNull);
      expect(json['show_out_of_stock'], isFalse);
      expect(json['social'], {
        'facebook': 'https://facebook.com/shop',
        'instagram': null,
        'tiktok': null,
      });
    });
  });
}
