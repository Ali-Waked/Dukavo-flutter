import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/dashboard_data.dart';
import '../domain/dashboard_domain.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    DashboardRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

/// Everything the overview screen renders, fetched together.
class DashboardBundle {
  const DashboardBundle({
    required this.overview,
    required this.revenue,
    required this.topProducts,
    required this.deadStock,
  });

  final DashboardOverview overview;
  final List<RevenuePoint> revenue;
  final List<TopProduct> topProducts;
  final List<DeadStockItem> deadStock;
}

/// Everything the overview screen renders, fetched together so the screen
/// resolves in one loading state rather than four staggered ones.
final dashboardProvider = FutureProvider<DashboardBundle>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);

  final results = await Future.wait<Object>([
    repository.overview(),
    repository.revenue(days: 30),
    repository.topProducts(limit: 5),
    repository.deadStock(limit: 5),
  ]);

  return DashboardBundle(
    overview: results[0] as DashboardOverview,
    revenue: results[1] as List<RevenuePoint>,
    topProducts: results[2] as List<TopProduct>,
    deadStock: results[3] as List<DeadStockItem>,
  );
});
