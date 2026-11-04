import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/platform_data.dart';
import '../domain/platform_domain.dart';

final platformRepositoryProvider = Provider<PlatformRepository>((ref) {
  return _PlatformRepositoryImpl(
    PlatformRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

class _PlatformRepositoryImpl implements PlatformRepository {
  _PlatformRepositoryImpl(this._remote);

  final PlatformRemoteDataSource _remote;

  @override
  Future<PlatformDashboard> dashboard({String range = '30d'}) {
    return _remote.dashboard(range: range);
  }
}

/// Selected dashboard window. Kept separate from the future so switching the
/// range never rebuilds the whole console shell.
final platformRangeProvider = StateProvider<String>((ref) => '30d');

final platformDashboardProvider =
    FutureProvider.autoDispose<PlatformDashboard>((ref) {
  final range = ref.watch(platformRangeProvider);
  return ref.watch(platformRepositoryProvider).dashboard(range: range);
});
