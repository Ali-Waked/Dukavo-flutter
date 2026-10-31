/// Executive analytics, mirroring the server aggregate.
///
/// Every figure is nullable where the stored data may not support it: the UI
/// must say "not measurable" rather than show a zero that looks measured.
class AnalyticsKpi {
  const AnalyticsKpi({
    required this.key,
    required this.label,
    required this.value,
    required this.unit,
    this.previousValue,
    this.changePercent,
    this.direction = 'flat',
    this.definition = '',
  });

  final String key;
  final String label;
  final num value;
  final String unit;
  final num? previousValue;
  final num? changePercent;
  final String direction;
  final String definition;

  bool get isCurrency => unit == 'currency';
}

class SalesTrendPoint {
  const SalesTrendPoint({
    required this.date,
    required this.revenue,
    required this.orders,
  });

  final String date;
  final num revenue;
  final int orders;
}

class ProductPerformance {
  const ProductPerformance({
    required this.name,
    required this.orders,
    required this.unitsSold,
    required this.revenue,
    this.productId,
    this.sku,
    this.grossProfit,
    this.grossMarginPercent,
  });

  final int? productId;
  final String name;
  final String? sku;
  final int orders;
  final int unitsSold;
  final num revenue;
  final num? grossProfit;
  final num? grossMarginPercent;
}

class StockHealthItem {
  const StockHealthItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.available,
    required this.status,
    this.sku,
    this.store,
    this.lowStockThreshold,
  });

  final int id;
  final String? store;
  final String productName;
  final String? sku;
  final int quantity;
  final int available;
  final int? lowStockThreshold;
  final String status;
}

class StockHealth {
  const StockHealth({
    required this.totalItems,
    required this.outOfStock,
    required this.lowStock,
    required this.healthy,
    this.items = const [],
  });

  final int totalItems;
  final int outOfStock;
  final int lowStock;
  final int healthy;
  final List<StockHealthItem> items;
}

class AnalyticsLimitation {
  const AnalyticsLimitation({
    required this.code,
    this.severity = 'info',
    this.affects = const [],
  });

  final String code;
  final String severity;
  final List<String> affects;
}

class AnalyticsOverview {
  const AnalyticsOverview({
    required this.currency,
    required this.kpis,
    required this.salesTrends,
    required this.productPerformance,
    required this.stockHealth,
    required this.limitations,
    this.from,
    this.until,
    this.tenant,
    this.timezone,
    this.storeName,
  });

  final String currency;
  final String? from;
  final String? until;
  final String? tenant;
  final String? timezone;
  final String? storeName;
  final List<AnalyticsKpi> kpis;
  final List<SalesTrendPoint> salesTrends;
  final List<ProductPerformance> productPerformance;
  final StockHealth stockHealth;
  final List<AnalyticsLimitation> limitations;
}

class AnalyticsQuery {
  const AnalyticsQuery({
    this.from,
    this.until,
    this.storeId,
    this.currency,
    this.productLimit = 10,
  });

  final String? from;
  final String? until;
  final int? storeId;
  final String? currency;
  final int productLimit;

  @override
  bool operator ==(Object other) {
    return other is AnalyticsQuery &&
        other.from == from &&
        other.until == until &&
        other.storeId == storeId &&
        other.currency == currency &&
        other.productLimit == productLimit;
  }

  @override
  int get hashCode => Object.hash(from, until, storeId, currency, productLimit);
}

abstract class AnalyticsRepository {
  Future<AnalyticsOverview> overview(AnalyticsQuery query);
}
