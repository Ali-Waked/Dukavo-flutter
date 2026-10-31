import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/store_data.dart';
import '../domain/store_domain.dart';

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreRepositoryImpl(
    StoreRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

/// Every store in the active workspace, default first.
final storeOptionsProvider = FutureProvider<List<Store>>((ref) {
  return ref.watch(storeRepositoryProvider).list();
});

/// The store a new order or stock movement should default to.
final defaultStoreProvider = Provider<Store?>((ref) {
  final stores = ref.watch(storeOptionsProvider).valueOrNull ?? const <Store>[];
  if (stores.isEmpty) return null;
  for (final store in stores) {
    if (store.isDefault) return store;
  }
  return stores.first;
});
