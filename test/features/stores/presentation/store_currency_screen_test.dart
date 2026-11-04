import 'package:dukavo_mobile/core/auth/permissions.dart';
import 'package:dukavo_mobile/features/auth/application/auth_controller.dart';
import 'package:dukavo_mobile/features/stores/application/store_controller.dart';
import 'package:dukavo_mobile/features/stores/data/store_currency_data.dart';
import 'package:dukavo_mobile/features/stores/domain/store_currency_domain.dart';
import 'package:dukavo_mobile/features/stores/presentation/store_currency_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_app.dart';

class _FakeCurrencyRepository implements StoreCurrencyRepository {
  int? convertedStoreId;
  String? convertedCurrency;

  @override
  Future<List<CurrencyOption>> options() async => const [
        CurrencyOption(
            code: 'EGP', name: 'Egyptian pound', symbol: 'E£', decimals: 2),
        CurrencyOption(
            code: 'USD', name: 'US dollar', symbol: r'$', decimals: 2),
      ];

  @override
  Future<StoreCurrencyState> show(int storeId) async =>
      const StoreCurrencyState(
        storeId: 4,
        storeName: 'Maadi shop',
        currency: 'EGP',
        history: [],
      );

  @override
  Future<CurrencyPreview> preview(int storeId, String currency) async =>
      CurrencyPreview(
        fromCurrency: 'EGP',
        toCurrency: currency,
        rate: 0.0205,
        rateSource: 'provider',
        products: 12,
        variants: 31,
        bundles: 2,
        sample: const [
          CurrencySample(
            name: 'Linen shirt',
            priceBefore: 1200,
            priceAfter: 24.6,
            costBefore: 600,
            costAfter: 12.3,
          ),
        ],
        noop: false,
      );

  @override
  Future<CurrencyConversion> convert(
    int storeId,
    String currency,
    String idempotencyKey,
  ) async {
    convertedStoreId = storeId;
    convertedCurrency = currency;
    return const CurrencyConversion(
      id: 9,
      fromCurrency: 'EGP',
      toCurrency: 'USD',
      exchangeRate: 0.0205,
      rateSource: 'provider',
      status: 'completed',
      productsConverted: 12,
      variantsConverted: 31,
      bundlesConverted: 2,
    );
  }
}

void main() {
  setUpAll(preloadLocalizations);

  testWidgets('previews a conversion and submits it after confirmation',
      (tester) async {
    final repository = _FakeCurrencyRepository();

    await pumpTestApp(
      tester,
      const StoreCurrencyScreen(storeId: 4),
      overrides: [
        storeCurrencyRepositoryProvider.overrideWithValue(repository),
        permissionsProvider.overrideWithValue(
          const Permissions(
              {PermissionSlugs.storesView, PermissionSlugs.storesManage}),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('EGP'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD · US dollar').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Preview conversion'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 EGP ='), findsOneWidget);
    expect(find.text('Linen shirt'), findsOneWidget);

    await tester.ensureVisible(find.text('Convert currency'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Convert currency'));
    await tester.pumpAndSettle();
    expect(find.text('Convert store currency?'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Convert currency'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.convertedStoreId, 4);
    expect(repository.convertedCurrency, 'USD');
    expect(find.text('Currency converted.'), findsOneWidget);
  });
}
