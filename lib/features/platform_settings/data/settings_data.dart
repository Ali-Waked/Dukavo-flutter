import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/settings_models.dart';

/// Typed access to the platform configuration API.
///
/// Nothing here decides what a setting means: the registry on the server owns
/// the catalogue, the validation and the source precedence. The phone renders
/// what it is told and sends back a flat `values` map keyed by field name.
class SettingsRemoteDataSource {
  SettingsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<SettingsCatalogue> catalogue() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.platformSettings,
      decode: _asMap,
    );

    return SettingsCatalogue.fromJson(data);
  }

  Future<SettingsSection> section(String category) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.platformSettingsSection(category),
      decode: _asMap,
    );

    return SettingsSection.fromJson(data);
  }

  /// Saves a partial section.
  ///
  /// A secret field that is absent stays as it was; an empty string therefore
  /// means "leave it alone" and is never sent. Clearing a non-secret override
  /// is an explicit `null`.
  Future<SettingsSection> updateSection(
    String category,
    Map<String, Object?> values,
  ) async {
    final data = await _api.put<Map<String, dynamic>>(
      ApiPaths.platformSettingsSection(category),
      body: <String, dynamic>{'values': values},
      decode: _asMap,
    );

    final settings = data['settings'];

    return SettingsSection(
      category: SettingsCategory(
        key: category,
        label: '',
        labelAr: '',
        holdsSecrets: false,
        settings: settings is List
            ? settings
                .whereType<Map>()
                .map((entry) =>
                    SettingDefinition.fromJson(Map<String, dynamic>.from(entry)))
                .toList()
            : const <SettingDefinition>[],
      ),
      permissions: const SettingsPermissions(),
    );
  }

  Future<List<PlatformFeatureFlag>> features() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.platformSettingsFeatures,
      decode: _asMap,
    );

    return _features(data);
  }

  Future<List<PlatformFeatureFlag>> toggleFeature(
    String key,
    bool enabled,
  ) async {
    final data = await _api.put<Map<String, dynamic>>(
      ApiPaths.platformSettingsFeature(key),
      body: <String, dynamic>{'enabled': enabled},
      decode: _asMap,
    );

    return _features(data);
  }

  Future<List<IntegrationHealth>> health() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.platformSettingsHealth,
      decode: _asMap,
    );

    return _integrations(data);
  }

  /// Probes one integration and returns the refreshed list.
  Future<List<IntegrationHealth>> check(String integration) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.platformSettingsHealthCheck(integration),
      decode: _asMap,
    );

    return _integrations(data);
  }

  Future<List<SettingsHistoryEntry>> history({String? key, int limit = 50}) async {
    final query = <String, dynamic>{'limit': limit};
    if (key != null && key.trim().isNotEmpty) query['key'] = key.trim();

    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.platformSettingsHistory,
      query: query,
      decode: _asMap,
    );

    final raw = data['changes'];

    return raw is List
        ? raw
            .whereType<Map>()
            .map((entry) =>
                SettingsHistoryEntry.fromJson(Map<String, dynamic>.from(entry)))
            .toList()
        : const <SettingsHistoryEntry>[];
  }

  Future<PlatformSystemSummary> system() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.platformSettingsSystem,
      decode: _asMap,
    );

    return PlatformSystemSummary.fromJson(data);
  }

  List<PlatformFeatureFlag> _features(Map<String, dynamic> data) {
    final raw = data['features'];

    return raw is List
        ? raw
            .whereType<Map>()
            .map((entry) =>
                PlatformFeatureFlag.fromJson(Map<String, dynamic>.from(entry)))
            .toList()
        : const <PlatformFeatureFlag>[];
  }

  List<IntegrationHealth> _integrations(Map<String, dynamic> data) {
    final raw = data['integrations'];

    return raw is List
        ? raw
            .whereType<Map>()
            .map((entry) =>
                IntegrationHealth.fromJson(Map<String, dynamic>.from(entry)))
            .toList()
        : const <IntegrationHealth>[];
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}
