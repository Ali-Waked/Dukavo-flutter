import 'package:dukavo_mobile/core/auth/permissions.dart';
import 'package:dukavo_mobile/features/auth/application/auth_controller.dart';
import 'package:dukavo_mobile/features/payments/application/payment_controller.dart';
import 'package:dukavo_mobile/features/payments/domain/payment_domain.dart';
import 'package:dukavo_mobile/features/payments/presentation/payment_settings_screen.dart';
import 'package:dukavo_mobile/features/stores/application/store_controller.dart';
import 'package:dukavo_mobile/features/stores/domain/store_domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_app.dart';

class _FakePaymentRepository implements PaymentRepository {
  @override
  Future<PaymentSettings> get(int storeId) async => _settings;

  @override
  Future<PaymentSettings> update(int storeId, PaymentSettingsDraft draft) async {
    return PaymentSettings(
      codEnabled: draft.codEnabled,
      codInstructions: draft.codInstructions,
      methods: _settings.methods,
    );
  }

  static const _settings = PaymentSettings(
    codEnabled: true,
    codInstructions: 'Pay the courier on arrival.',
    methods: [
      PaymentMethodOption(
        code: 'cod',
        label: 'Cash on delivery',
        description: 'Pay when your order arrives.',
        available: true,
      ),
      PaymentMethodOption(
        code: 'online',
        label: 'Online payment',
        description: 'Pay by card.',
        available: false,
        unavailableReason: 'No online payment provider is configured yet.',
      ),
    ],
  );
}

const _store = Store(
  id: 4,
  name: 'Maadi shop',
  slug: 'maadi-shop',
  status: 'active',
  isDefault: true,
  currency: 'EGP',
  timezone: 'Africa/Cairo',
);

void main() {
  setUpAll(preloadLocalizations);

  testWidgets('renders COD settings and the honest online state', (tester) async {
    await pumpTestApp(
      tester,
      const PaymentSettingsScreen(),
      overrides: [
        storeOptionsProvider.overrideWith((ref) async => [_store]),
        paymentRepositoryProvider.overrideWithValue(_FakePaymentRepository()),
        permissionsProvider.overrideWithValue(
          const Permissions({PermissionSlugs.paymentsView}),
        ),
      ],
    );

    expect(find.text('Payment methods'), findsOneWidget);
    expect(find.text('Cash on delivery'), findsWidgets);
    expect(find.text('Online payment'), findsOneWidget);
    expect(find.text('Unavailable'), findsOneWidget);
    expect(
      find.text('No online payment provider is configured yet.'),
      findsOneWidget,
    );
    // A view-only role must not get a save button.
    expect(find.text('Save changes'), findsNothing);
  });
}
