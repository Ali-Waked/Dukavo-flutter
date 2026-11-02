import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/payment_data.dart';
import '../domain/payment_domain.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(
    PaymentRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final paymentSettingsProvider =
    FutureProvider.family<PaymentSettings, int>((ref, storeId) {
  return ref.watch(paymentRepositoryProvider).get(storeId);
});

class PaymentActions {
  PaymentActions(this._ref);

  final Ref _ref;

  Future<PaymentSettings> update(
    int storeId,
    PaymentSettingsDraft draft,
  ) async {
    final updated =
        await _ref.read(paymentRepositoryProvider).update(storeId, draft);
    _ref.invalidate(paymentSettingsProvider(storeId));
    return updated;
  }
}

final paymentActionsProvider = Provider<PaymentActions>(PaymentActions.new);
