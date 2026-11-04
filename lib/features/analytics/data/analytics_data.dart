import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/analytics_domain.dart';

class AnalyticsModel {
  const AnalyticsModel._();

  static AnalyticsOverview fromJson(Map<String, dynamic> json) {
    final rawContext = json['context'];
    final rawRange = json['range'];
    final rawKpis = json['kpis'];
    final rawTrends = json['sales_trends'];
    final rawProducts = json['product_performance'];
    final rawHealth = json['stock_health'];
    final rawLimitations = json['limitations'];

    final context = rawContext is Map ? rawContext : const <String, dynamic>{};
    final range = rawRange is Map ? rawRange : const <String, dynamic>{};
    final store = context['store'];
    final health = rawHealth is Map ? rawHealth : const <String, dynamic>{};
    final healthSummary = health['summary'] is Map
        ? health['summary'] as Map
        : const <String, dynamic>{};
    final healthItems = health['items'];

    return AnalyticsOverview(
      currency: '${json['currency'] ?? context['currency'] ?? 'USD'}',
      from: range['from'] as String?,
      until: range['until'] as String?,
      tenant: context['tenant'] as String?,
      timezone: context['timezone'] as String?,
      storeName: store is Map ? store['name'] as String? : null,
      kpis: rawKpis is List
          ? rawKpis
              .whereType<Map>()
              .map((entry) => _kpi(Map<String, dynamic>.from(entry)))
              .toList()
          : const [],
      salesTrends: rawTrends is List
          ? rawTrends.whereType<Map>().map((entry) {
              final map = Map<String, dynamic>.from(entry);
              return SalesTrendPoint(
                date: '${map['date'] ?? ''}',
                revenue: _num(map['revenue']),
                orders: _int(map['orders']),
              );
            }).toList()
          : const [],
      productPerformance: rawProducts is List
          ? rawProducts.whereType<Map>().map((entry) {
              final map = Map<String, dynamic>.from(entry);
              return ProductPerformance(
                productId: _nullableInt(map['product_id']),
                name: '${map['name'] ?? ''}',
                sku: map['sku'] as String?,
                orders: _int(map['orders']),
                unitsSold: _int(map['units_sold']),
                revenue: _num(map['revenue']),
                grossProfit: _nullableNum(map['gross_profit']),
                grossMarginPercent: _nullableNum(map['gross_margin_percent']),
              );
            }).toList()
          : const [],
      stockHealth: StockHealth(
        totalItems: _int(healthSummary['total_items']),
        outOfStock: _int(healthSummary['out_of_stock']),
        lowStock: _int(healthSummary['low_stock']),
        healthy: _int(healthSummary['healthy']),
        items: healthItems is List
            ? healthItems.whereType<Map>().map((entry) {
                final map = Map<String, dynamic>.from(entry);
                return StockHealthItem(
                  id: _int(map['id']),
                  store: map['store'] as String?,
                  productName: '${map['product_name'] ?? ''}',
                  sku: map['sku'] as String?,
                  quantity: _int(map['quantity']),
                  available: _int(map['available']),
                  lowStockThreshold: _nullableInt(map['low_stock_threshold']),
                  status: '${map['status'] ?? 'healthy'}',
                );
              }).toList()
            : const [],
      ),
      limitations: rawLimitations is List
          ? rawLimitations.whereType<Map>().map((entry) {
              final map = Map<String, dynamic>.from(entry);
              final affects = map['affects'];
              return AnalyticsLimitation(
                code: '${map['code'] ?? ''}',
                severity: '${map['severity'] ?? 'info'}',
                affects: affects is List
                    ? affects.map((value) => '$value').toList()
                    : const [],
              );
            }).toList()
          : const [],
    );
  }

  static AnalyticsKpi _kpi(Map<String, dynamic> json) {
    return AnalyticsKpi(
      key: '${json['key'] ?? ''}',
      label: '${json['label'] ?? ''}',
      value: _num(json['value']),
      unit: '${json['unit'] ?? 'count'}',
      previousValue: _nullableNum(json['previous_value']),
      changePercent: _nullableNum(json['change_percent']),
      direction: '${json['direction'] ?? 'flat'}',
      definition: '${json['definition'] ?? ''}',
    );
  }

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static int? _nullableInt(Object? value) {
    if (value == null) return null;
    return _int(value);
  }

  static num _num(Object? value) {
    if (value is num) return value;
    return num.tryParse('$value') ?? 0;
  }

  static num? _nullableNum(Object? value) {
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse('$value');
  }
}

class AnalyticsRemoteDataSource {
  AnalyticsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<AnalyticsOverview> overview(AnalyticsQuery query) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.analytics,
      query: {
        if (query.from != null) 'from': query.from,
        if (query.until != null) 'until': query.until,
        if (query.storeId != null) 'store_id': query.storeId,
        if (query.currency != null) 'currency': query.currency,
        'product_limit': query.productLimit,
      },
      decode: (raw) => raw is Map
          ? Map<String, dynamic>.from(raw)
          : const <String, dynamic>{},
    );
    return AnalyticsModel.fromJson(data);
  }
}

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  AnalyticsRepositoryImpl(this._remote);

  final AnalyticsRemoteDataSource _remote;

  @override
  Future<AnalyticsOverview> overview(AnalyticsQuery query) =>
      _remote.overview(query);
}
