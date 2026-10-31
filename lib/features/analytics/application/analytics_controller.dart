import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/analytics_data.dart';
import '../domain/analytics_domain.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepositoryImpl(
    AnalyticsRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final analyticsOverviewProvider =
    FutureProvider.autoDispose.family<AnalyticsOverview, AnalyticsQuery>(
  (ref, query) => ref.watch(analyticsRepositoryProvider).overview(query),
);
