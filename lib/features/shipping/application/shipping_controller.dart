import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/shipping_data.dart';
import '../domain/shipping_domain.dart';

final shippingRepositoryProvider = Provider<ShippingRepository>((ref) {
  return ShippingRepositoryImpl(
    ShippingRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final shippingZonesProvider =
    FutureProvider.family<List<ShippingZone>, int>((ref, storeId) {
  return ref.watch(shippingRepositoryProvider).list(storeId);
});

class ShippingActions {
  ShippingActions(this._ref);

  final Ref _ref;

  Future<ShippingZone> create(int storeId, ShippingZoneDraft draft) async {
    final zone =
        await _ref.read(shippingRepositoryProvider).create(storeId, draft);
    _refresh(storeId);
    return zone;
  }

  Future<ShippingZone> update(
    int storeId,
    int zoneId,
    ShippingZoneDraft draft,
  ) async {
    final zone = await _ref
        .read(shippingRepositoryProvider)
        .update(storeId, zoneId, draft);
    _refresh(storeId);
    return zone;
  }

  Future<void> delete(int storeId, int zoneId) async {
    await _ref.read(shippingRepositoryProvider).delete(storeId, zoneId);
    _refresh(storeId);
  }

  void _refresh(int storeId) {
    _ref.invalidate(shippingZonesProvider(storeId));
  }
}

final shippingActionsProvider =
    Provider<ShippingActions>(ShippingActions.new);
