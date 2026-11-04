import 'package:dukavo_mobile/features/payments/data/payment_data.dart';
import 'package:dukavo_mobile/features/payments/domain/payment_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaymentSettingsModel.fromJson', () {
    test('parses cash on delivery and the honest online state', () {
      final settings = PaymentSettingsModel.fromJson(const {
        'settings': {
          'cod_enabled': false,
          'cod_instructions': 'Pay the courier on arrival.',
        },
        'methods': [
          {
            'code': 'cod',
            'label': 'Cash on delivery',
            'description': 'Pay when your order arrives.',
            'available': false,
            'unavailable_reason':
                'This store does not accept cash on delivery.',
          },
          {
            'code': 'online',
            'label': 'Online payment',
            'description': 'Pay by card.',
            'available': false,
            'unavailable_reason':
                'No online payment provider is configured for this store yet.',
          },
        ],
      }).toEntity();

      expect(settings.codEnabled, isFalse);
      expect(settings.codInstructions, 'Pay the courier on arrival.');
      expect(settings.methods, hasLength(2));

      final cod = settings.methods.first;
      expect(cod.code, 'cod');
      expect(cod.available, isFalse);
      expect(cod.unavailableReason,
          'This store does not accept cash on delivery.');

      final online = settings.methods.last;
      expect(online.code, 'online');
      expect(online.available, isFalse);
      expect(online.unavailableReason, contains('No online payment provider'));
    });

    test('applies safe defaults for a minimal payload', () {
      final settings = PaymentSettingsModel.fromJson(const {}).toEntity();

      expect(settings.codEnabled, isTrue);
      expect(settings.codInstructions, isNull);
      expect(settings.methods, isEmpty);
    });

    test('ignores malformed methods', () {
      final settings = PaymentSettingsModel.fromJson(const {
        'methods': 'not-a-list',
      }).toEntity();

      expect(settings.methods, isEmpty);
    });

    test('copyWith keeps the methods when toggling COD', () {
      const settings = PaymentSettings(
        codEnabled: true,
        methods: [],
      );

      final updated = settings.copyWith(
        codEnabled: false,
        codInstructions: 'Pay on arrival.',
      );

      expect(updated.codEnabled, isFalse);
      expect(updated.codInstructions, 'Pay on arrival.');
      expect(updated.methods, isEmpty);
    });
  });
}
