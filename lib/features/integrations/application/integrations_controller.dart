import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/integrations_data.dart';
import '../domain/integrations_domain.dart';

final integrationsRepositoryProvider = Provider<IntegrationsRepository>((ref) {
  return IntegrationsRepositoryImpl(
    IntegrationsRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

/// Every declared channel annotated with this workspace's connections.
final integrationsProvider = FutureProvider<List<ChannelDefinition>>((ref) {
  return ref.watch(integrationsRepositoryProvider).getChannels();
});

class IntegrationsActions {
  IntegrationsActions(this._ref);

  final Ref _ref;

  Future<void> connect(String channel, IntegrationDraft draft) async {
    await _ref.read(integrationsRepositoryProvider).connect(channel, draft);
    _ref.invalidate(integrationsProvider);
  }

  Future<void> update(int id, IntegrationDraft draft) async {
    await _ref.read(integrationsRepositoryProvider).update(id, draft);
    _ref.invalidate(integrationsProvider);
  }

  Future<void> disconnect(int id) async {
    await _ref.read(integrationsRepositoryProvider).disconnect(id);
    _ref.invalidate(integrationsProvider);
  }

  Future<void> test(int id) async {
    await _ref.read(integrationsRepositoryProvider).test(id);
    _ref.invalidate(integrationsProvider);
  }

  Future<void> reconnect(int id) async {
    await _ref.read(integrationsRepositoryProvider).reconnect(id);
    _ref.invalidate(integrationsProvider);
  }
}

final integrationsActionsProvider =
    Provider<IntegrationsActions>(IntegrationsActions.new);
