import 'package:dukavo_mobile/features/stores/domain/store_currency_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a conversion preview with sample prices', () {
    final preview = CurrencyPreview.fromJson(const {
      'from_currency': 'EGP',
      'to_currency': 'USD',
      'rate': 0.0205,
      'rate_source': 'provider',
      'rate_fetched_at': '2026-11-04T09:00:00+00:00',
      'products': 12,
      'variants': 31,
      'bundles': 2,
      'shipping_zones': 4,
      'noop': false,
      'sample': [
        {
          'id': 1,
          'name': 'Linen shirt',
          'price_before': 1200.0,
          'price_after': 24.6,
          'cost_before': 600.0,
          'cost_after': 12.3,
        },
      ],
    });

    expect(preview.fromCurrency, 'EGP');
    expect(preview.toCurrency, 'USD');
    expect(preview.rate, 0.0205);
    expect(preview.products, 12);
    expect(preview.variants, 31);
    expect(preview.bundles, 2);
    expect(preview.shippingZones, 4);
    expect(preview.noop, isFalse);
    expect(preview.sample.single.name, 'Linen shirt');
    expect(preview.sample.single.priceAfter, 24.6);
    expect(preview.rateFetchedAt, isNotNull);
  });

  test('parses the store currency state and its history', () {
    final state = StoreCurrencyState.fromJson(const {
      'store': {'id': 7, 'name': 'Maadi shop', 'currency': 'EGP'},
      'history': [
        {
          'id': 4,
          'from_currency': 'USD',
          'to_currency': 'EGP',
          'exchange_rate': 48.5,
          'rate_source': 'provider',
          'status': 'completed',
          'products_converted': 9,
          'variants_converted': 20,
          'bundles_converted': 1,
          'shipping_zones_converted': 3,
          'completed_at': '2026-10-01T10:00:00+00:00',
        },
      ],
    });

    expect(state.storeId, 7);
    expect(state.storeName, 'Maadi shop');
    expect(state.currency, 'EGP');
    expect(state.history.single.fromCurrency, 'USD');
    expect(state.history.single.productsConverted, 9);
    expect(state.history.single.shippingZonesConverted, 3);
    expect(state.history.single.status, 'completed');
  });

  test('treats an empty payload as an empty state', () {
    final state = StoreCurrencyState.fromJson(const {});

    expect(state.storeId, 0);
    expect(state.currency, '');
    expect(state.history, isEmpty);
  });
}
