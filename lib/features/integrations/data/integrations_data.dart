import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/integrations_domain.dart';

/// JSON decoding for the omnichannel integration centre.
class IntegrationsModel {
  const IntegrationsModel._();

  static List<ChannelDefinition> catalogue(Map<String, dynamic> json) {
    final channels = json['channels'];
    if (channels is! List) return const <ChannelDefinition>[];

    return channels
        .whereType<Map>()
        .map((entry) =>
            ChannelDefinition.fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }
}

class IntegrationsRemoteDataSource {
  IntegrationsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<ChannelDefinition>> getChannels() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.integrations,
      decode: _asMap,
    );
    return IntegrationsModel.catalogue(data);
  }

  Future<void> connect(String channel, IntegrationDraft draft) async {
    await _api.post<Map<String, dynamic>>(
      ApiPaths.integrations,
      body: draft.toJson(channel: channel),
      decode: _asMap,
    );
  }

  Future<void> update(int id, IntegrationDraft draft) async {
    await _api.patch<Map<String, dynamic>>(
      ApiPaths.integration(id),
      body: draft.toJson(),
      decode: _asMap,
    );
  }

  Future<void> disconnect(int id) async {
    await _api.delete(ApiPaths.integration(id));
  }

  Future<void> test(int id) async {
    await _api.post<Map<String, dynamic>>(
      ApiPaths.integrationTest(id),
      decode: _asMap,
    );
  }

  Future<void> reconnect(int id) async {
    await _api.post<Map<String, dynamic>>(
      ApiPaths.integrationReconnect(id),
      decode: _asMap,
    );
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}

class IntegrationsRepositoryImpl implements IntegrationsRepository {
  IntegrationsRepositoryImpl(this._remote);

  final IntegrationsRemoteDataSource _remote;

  @override
  Future<List<ChannelDefinition>> getChannels() => _remote.getChannels();

  @override
  Future<void> connect(String channel, IntegrationDraft draft) =>
      _remote.connect(channel, draft);

  @override
  Future<void> update(int id, IntegrationDraft draft) =>
      _remote.update(id, draft);

  @override
  Future<void> disconnect(int id) => _remote.disconnect(id);

  @override
  Future<void> test(int id) => _remote.test(id);

  @override
  Future<void> reconnect(int id) => _remote.reconnect(id);
}
