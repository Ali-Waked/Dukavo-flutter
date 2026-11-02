import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/storefront_data.dart';
import '../domain/storefront_domain.dart';

final storefrontRepositoryProvider = Provider<StorefrontRepository>((ref) {
  return StorefrontRepositoryImpl(
    StorefrontRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final storefrontSettingsProvider =
    FutureProvider.family<StorefrontSettings, int>((ref, storeId) {
  return ref.watch(storefrontRepositoryProvider).get(storeId);
});

class StorefrontActions {
  StorefrontActions(this._ref);

  final Ref _ref;

  Future<StorefrontSettings> update(
    int storeId,
    StorefrontDraft draft,
  ) async {
    final updated =
        await _ref.read(storefrontRepositoryProvider).update(storeId, draft);
    _ref.invalidate(storefrontSettingsProvider(storeId));
    return updated;
  }
}

final storefrontActionsProvider =
    Provider<StorefrontActions>(StorefrontActions.new);
