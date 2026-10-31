/// Dashboard aggregates, mirroring `DashboardService`'s payloads.
///
/// The server computes every figure in SQL; the app only formats what it is
/// given. Nothing here derives or re-rounds a number.
class DashboardSummary {
  const DashboardSummary({
    required this.revenueToday,
    required this.ordersToday,
    required this.averageOrderValue,
    required this.revenueMonth,
    required this.ordersMonth,
    required this.openConversations,
    required this.lowStockItems,
    required this.activeCustomers,
    required this.awaitingFulfilment,
  });

  final num revenueToday;
  final int ordersToday;
  final num averageOrderValue;
  final num revenueMonth;
  final int ordersMonth;
  final int openConversations;
  final int lowStockItems;
  final int activeCustomers;
  final int awaitingFulfilment;

  static const empty = DashboardSummary(
    revenueToday: 0,
    ordersToday: 0,
    averageOrderValue: 0,
    revenueMonth: 0,
    ordersMonth: 0,
    openConversations: 0,
    lowStockItems: 0,
    activeCustomers: 0,
    awaitingFulfilment: 0,
  );
}

class DashboardContext {
  const DashboardContext({
    required this.tenant,
    required this.currency,
    required this.timezone,
  });

  final String tenant;
  final String currency;
  final String timezone;
}

class DashboardOverview {
  const DashboardOverview({
    required this.context,
    required this.summary,
  });

  final DashboardContext context;
  final DashboardSummary summary;
}

class RevenuePoint {
  const RevenuePoint({
    required this.date,
    required this.total,
    required this.orders,
  });

  final String date;
  final num total;
  final int orders;
}

class TopProduct {
  const TopProduct({
    required this.productId,
    required this.name,
    required this.units,
    required this.revenue,
    this.productSlug,
    this.sku,
  });

  final int productId;
  final String? productSlug;
  final String name;
  final String? sku;
  final int units;
  final num revenue;
}

class DeadStockItem {
  const DeadStockItem({
    required this.id,
    required this.name,
    required this.stock,
    this.sku,
  });

  final int id;
  final String name;
  final String? sku;
  final int stock;
}

abstract class DashboardRepository {
  Future<DashboardOverview> overview({int? storeId});

  Future<List<RevenuePoint>> revenue({int days = 30, int? storeId});

  Future<List<TopProduct>> topProducts({int limit = 5, int? storeId});

  Future<List<DeadStockItem>> deadStock({int limit = 5});
}
