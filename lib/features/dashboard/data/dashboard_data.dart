import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/dashboard_domain.dart';

class DashboardRemoteDataSource {
  DashboardRemoteDataSource(this._api);

  final ApiClient _api;

  Future<DashboardOverview> overview({int? storeId}) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.dashboard,
      query: {
        if (storeId != null) 'store_id': storeId,
      },
      decode: (raw) =>
          raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{},
    );

    final rawContext = data['context'];
    final context = rawContext is Map
        ? Map<String, dynamic>.from(rawContext)
        : const <String, dynamic>{};

    return DashboardOverview(
      context: DashboardContext(
        tenant: '${context['tenant'] ?? ''}',
        currency: '${context['currency'] ?? 'USD'}',
        timezone: '${context['timezone'] ?? 'UTC'}',
      ),
      summary: _summary(
        data['summary'] is Map
            ? Map<String, dynamic>.from(data['summary'] as Map)
            : const <String, dynamic>{},
      ),
    );
  }

  Future<List<RevenuePoint>> revenue({int days = 30, int? storeId}) async {
    final data = await _api.get<List<dynamic>>(
      ApiPaths.dashboardRevenue,
      query: {
        'days': days,
        if (storeId != null) 'store_id': storeId,
      },
      decode: (raw) => raw is List ? raw : const <dynamic>[],
    );

    return data.whereType<Map>().map((entry) {
      final map = Map<String, dynamic>.from(entry);
      return RevenuePoint(
        date: '${map['date'] ?? ''}',
        total: _num(map['total']),
        orders: _int(map['orders']),
      );
    }).toList();
  }

  Future<List<TopProduct>> topProducts({int limit = 5, int? storeId}) async {
    final data = await _api.get<List<dynamic>>(
      ApiPaths.dashboardTopProducts,
      query: {
        'limit': limit,
        if (storeId != null) 'store_id': storeId,
      },
      decode: (raw) => raw is List ? raw : const <dynamic>[],
    );

    return data.whereType<Map>().map((entry) {
      final map = Map<String, dynamic>.from(entry);
      return TopProduct(
        productId: _int(map['product_id']),
        productSlug: map['product_slug'] as String?,
        name: '${map['name'] ?? ''}',
        sku: map['sku'] as String?,
        units: _int(map['units']),
        revenue: _num(map['revenue']),
      );
    }).toList();
  }

  Future<List<DeadStockItem>> deadStock({int limit = 5}) async {
    final data = await _api.get<List<dynamic>>(
      ApiPaths.dashboardDeadStock,
      query: {'limit': limit},
      decode: (raw) => raw is List ? raw : const <dynamic>[],
    );

    return data.whereType<Map>().map((entry) {
      final map = Map<String, dynamic>.from(entry);
      return DeadStockItem(
        id: _int(map['id']),
        name: '${map['name'] ?? ''}',
        sku: map['sku'] as String?,
        stock: _int(map['stock']),
      );
    }).toList();
  }

  DashboardSummary _summary(Map<String, dynamic> json) {
    return DashboardSummary(
      revenueToday: _num(json['revenue_today']),
      ordersToday: _int(json['orders_today']),
      averageOrderValue: _num(json['average_order_value']),
      revenueMonth: _num(json['revenue_month']),
      ordersMonth: _int(json['orders_month']),
      openConversations: _int(json['open_conversations']),
      lowStockItems: _int(json['low_stock_items']),
      activeCustomers: _int(json['active_customers']),
      awaitingFulfilment: _int(json['awaiting_fulfilment']),
    );
  }

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static num _num(Object? value) {
    if (value is num) return value;
    return num.tryParse('$value') ?? 0;
  }
}

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._remote);

  final DashboardRemoteDataSource _remote;

  @override
  Future<DashboardOverview> overview({int? storeId}) =>
      _remote.overview(storeId: storeId);

  @override
  Future<List<RevenuePoint>> revenue({int days = 30, int? storeId}) =>
      _remote.revenue(days: days, storeId: storeId);

  @override
  Future<List<TopProduct>> topProducts({int limit = 5, int? storeId}) =>
      _remote.topProducts(limit: limit, storeId: storeId);

  @override
  Future<List<DeadStockItem>> deadStock({int limit = 5}) =>
      _remote.deadStock(limit: limit);
}
