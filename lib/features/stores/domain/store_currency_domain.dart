/// Store base-currency conversion, mirroring `StoreCurrencyController`.
///
/// A conversion rewrites current catalogue prices and costs on the server. The
/// client only previews the rate and confirms; it never computes a converted
/// amount itself.
library;

export '../../../core/currency/currency_catalogue.dart' show CurrencyOption;

class CurrencySample {
  const CurrencySample({
    required this.name,
    required this.priceBefore,
    required this.priceAfter,
    required this.costBefore,
    required this.costAfter,
  });

  final String name;
  final double priceBefore;
  final double priceAfter;
  final double costBefore;
  final double costAfter;

  static CurrencySample fromJson(Map<String, dynamic> json) {
    return CurrencySample(
      name: '${json['name'] ?? '—'}',
      priceBefore: _double(json['price_before']),
      priceAfter: _double(json['price_after']),
      costBefore: _double(json['cost_before']),
      costAfter: _double(json['cost_after']),
    );
  }
}

class CurrencyPreview {
  const CurrencyPreview({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.rateSource,
    required this.products,
    required this.variants,
    required this.bundles,
    required this.sample,
    required this.noop,
    this.shippingZones = 0,
    this.rateFetchedAt,
  });

  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final String rateSource;
  final int products;
  final int variants;
  final int bundles;
  final int shippingZones;
  final List<CurrencySample> sample;
  final bool noop;
  final DateTime? rateFetchedAt;

  static CurrencyPreview fromJson(Map<String, dynamic> json) {
    final rawSample = json['sample'];
    return CurrencyPreview(
      fromCurrency: '${json['from_currency'] ?? ''}',
      toCurrency: '${json['to_currency'] ?? ''}',
      rate: _double(json['rate']),
      rateSource: '${json['rate_source'] ?? ''}',
      products: _int(json['products']),
      variants: _int(json['variants']),
      bundles: _int(json['bundles']),
      shippingZones: _int(json['shipping_zones']),
      sample: rawSample is List
          ? rawSample
              .whereType<Map>()
              .map((entry) =>
                  CurrencySample.fromJson(Map<String, dynamic>.from(entry)))
              .toList()
          : const [],
      noop: json['noop'] == true,
      rateFetchedAt: _date(json['rate_fetched_at']),
    );
  }
}

class CurrencyConversion {
  const CurrencyConversion({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.exchangeRate,
    required this.rateSource,
    required this.status,
    required this.productsConverted,
    required this.variantsConverted,
    required this.bundlesConverted,
    this.shippingZonesConverted = 0,
    this.failureReason,
    this.completedAt,
    this.createdAt,
  });

  final int id;
  final String fromCurrency;
  final String toCurrency;
  final double exchangeRate;
  final String rateSource;
  final String status;
  final int productsConverted;
  final int variantsConverted;
  final int bundlesConverted;
  final int shippingZonesConverted;
  final String? failureReason;
  final DateTime? completedAt;
  final DateTime? createdAt;

  static CurrencyConversion fromJson(Map<String, dynamic> json) {
    return CurrencyConversion(
      id: _int(json['id']),
      fromCurrency: '${json['from_currency'] ?? ''}',
      toCurrency: '${json['to_currency'] ?? ''}',
      exchangeRate: _double(json['exchange_rate']),
      rateSource: '${json['rate_source'] ?? ''}',
      status: '${json['status'] ?? ''}',
      productsConverted: _int(json['products_converted']),
      variantsConverted: _int(json['variants_converted']),
      bundlesConverted: _int(json['bundles_converted']),
      shippingZonesConverted: _int(json['shipping_zones_converted']),
      failureReason: json['failure_reason']?.toString(),
      completedAt: _date(json['completed_at']),
      createdAt: _date(json['created_at']),
    );
  }
}

class StoreCurrencyState {
  const StoreCurrencyState({
    required this.storeId,
    required this.storeName,
    required this.currency,
    required this.history,
  });

  final int storeId;
  final String storeName;
  final String currency;
  final List<CurrencyConversion> history;

  static StoreCurrencyState fromJson(Map<String, dynamic> json) {
    final rawStore = json['store'];
    final store =
        rawStore is Map ? Map<String, dynamic>.from(rawStore) : const {};
    final rawHistory = json['history'];
    return StoreCurrencyState(
      storeId: _int(store['id']),
      storeName: '${store['name'] ?? '—'}',
      currency: '${store['currency'] ?? ''}',
      history: rawHistory is List
          ? rawHistory
              .whereType<Map>()
              .map((entry) =>
                  CurrencyConversion.fromJson(Map<String, dynamic>.from(entry)))
              .toList()
          : const [],
    );
  }
}

int _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

double _double(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse('$value');
}
