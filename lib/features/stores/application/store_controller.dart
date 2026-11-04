import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/store_currency_data.dart';
import '../data/store_data.dart';
import '../domain/store_currency_domain.dart';
import '../domain/store_domain.dart';

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreRepositoryImpl(
    StoreRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final storeCurrencyRepositoryProvider =
    Provider<StoreCurrencyRepository>((ref) {
  return StoreCurrencyRepositoryImpl(
    StoreCurrencyRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final currencyOptionsProvider = FutureProvider<List<CurrencyOption>>((ref) {
  return ref.watch(storeCurrencyRepositoryProvider).options();
});

final storeCurrencyProvider =
    FutureProvider.autoDispose.family<StoreCurrencyState, int>((ref, storeId) {
  return ref.watch(storeCurrencyRepositoryProvider).show(storeId);
});

/// Every store in the active workspace, default first.
final storeOptionsProvider = FutureProvider<List<Store>>((ref) {
  return ref.watch(storeRepositoryProvider).list();
});

/// The store a new order or stock movement should default to.
final defaultStoreProvider = Provider<Store?>((ref) {
  final stores = ref.watch(storeOptionsProvider).valueOrNull ?? const <Store>[];
  return defaultStoreFrom(stores);
});

/// The default store from an already-loaded list, without reading a provider.
///
/// Store-scoped configuration screens share this so they all open on the same
/// store the rest of the app treats as the default.
Store? defaultStoreFrom(List<Store> stores) {
  if (stores.isEmpty) return null;
  for (final store in stores) {
    if (store.isDefault) return store;
  }
  return stores.first;
}
