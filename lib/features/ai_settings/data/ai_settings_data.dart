import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/ai_settings_domain.dart';

/// JSON decoding for the tenant AI settings surface.
///
/// Everything is defensive: the server's shapes are contracts, but a missing
/// field must never crash the screen.
class AiSettingsModel {
  const AiSettingsModel._();

  static AiSettingsOverview settings(Map<String, dynamic> json) {
    final byok = _map(json['byok']);

    return AiSettingsOverview(
      aiEnabled: json['ai_enabled'] == true,
      features: _list(json['features'])
          .map((entry) => _feature(_map(entry)))
          .toList(),
      byokPlatformEnabled: byok['platform_enabled'] == true,
      byokOptedIn: byok['opted_in'] == true,
    );
  }

  static AiUsageSummary usage(Map<String, dynamic> json) {
    return AiUsageSummary(
      todayRequests: _int(json['today_requests']),
      todayTokens: _int(json['today_tokens']),
      requests: _int(json['requests']),
      failures: _int(json['failures']),
      tokens: _int(json['tokens']),
      estimatedCostUsd: _double(json['estimated_cost_usd']),
      byFeature: _list(json['by_feature'])
          .map((entry) => _featureUsage(_map(entry)))
          .toList(),
    );
  }

  static AiCredentialsOverview credentials(Map<String, dynamic> json) {
    final byok = _map(json['byok']);

    return AiCredentialsOverview(
      byokPlatformEnabled: byok['platform_enabled'] == true,
      byokOptedIn: byok['opted_in'] == true,
      credentials: _list(json['credentials'])
          .map((entry) => credential(_map(entry)))
          .toList(),
      providers: _list(json['providers'])
          .map((entry) => _provider(_map(entry)))
          .toList(),
    );
  }

  static AiCredential credential(Map<String, dynamic> json) {
    return AiCredential(
      id: _int(json['id']),
      providerId: _int(json['provider_id']),
      maskedKey: '${json['masked_key'] ?? ''}',
      baseUrl: json['base_url'] as String?,
      model: json['model'] as String?,
      lastCheckedAt: json['last_checked_at'] as String?,
      lastCheckStatus: json['last_check_status'] as String?,
    );
  }

  static AiConnectionTestResult testResult(Map<String, dynamic> json) {
    return AiConnectionTestResult(
      ok: json['ok'] == true,
      status: _int(json['status']),
      latencyMs: _int(json['latency_ms']),
      reason: json['reason'] as String?,
    );
  }

  static AiFeatureToggle _feature(Map<String, dynamic> json) {
    return AiFeatureToggle(
      feature: '${json['feature'] ?? ''}',
      enabled: json['enabled'] == true,
      platformEnabled: json['platform_enabled'] == true,
    );
  }

  static AiFeatureUsage _featureUsage(Map<String, dynamic> json) {
    return AiFeatureUsage(
      feature: '${json['feature'] ?? ''}',
      requests: _int(json['requests']),
      failures: _int(json['failures']),
      tokens: _int(json['tokens']),
    );
  }

  static AiCredentialProvider _provider(Map<String, dynamic> json) {
    return AiCredentialProvider(
      id: _int(json['id']),
      key: '${json['key'] ?? ''}',
      name: '${json['name'] ?? ''}',
      driver: '${json['driver'] ?? ''}',
    );
  }

  static Map<String, dynamic> _map(Object? value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return const <String, dynamic>{};
  }

  static List<Object?> _list(Object? value) {
    if (value is List) return value;
    return const <Object?>[];
  }

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static double _double(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}

class AiSettingsRemoteDataSource {
  AiSettingsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<AiSettingsOverview> getSettings() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.tenantAiSettings,
      decode: _asMap,
    );
    return AiSettingsModel.settings(data);
  }

  Future<AiSettingsOverview> patchSettings({
    Map<String, bool>? features,
    bool? byokOptIn,
  }) async {
    final data = await _api.patch<Map<String, dynamic>>(
      ApiPaths.tenantAiSettings,
      body: {
        if (features != null) 'features': features,
        if (byokOptIn != null) 'byok_opt_in': byokOptIn,
      },
      decode: _asMap,
    );
    return AiSettingsModel.settings(data);
  }

  Future<AiUsageSummary> getUsage({int days = 30}) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.tenantAiUsage,
      query: {'days': days},
      decode: _asMap,
    );
    return AiSettingsModel.usage(data);
  }

  Future<AiCredentialsOverview> getCredentials() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.tenantAiCredentials,
      decode: _asMap,
    );
    return AiSettingsModel.credentials(data);
  }

  Future<AiCredential> storeCredential(AiCredentialDraft draft) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.tenantAiCredentials,
      body: draft.toJson(),
      decode: _asMap,
    );
    return AiSettingsModel.credential(data);
  }

  Future<AiConnectionTestResult> testCredential(String providerKey) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.tenantAiCredentialTest,
      body: {'provider': providerKey},
      decode: _asMap,
    );
    return AiSettingsModel.testResult(_asMap(data['result']));
  }

  Future<void> revokeCredential(int id) async {
    await _api.delete(ApiPaths.tenantAiCredential(id));
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}

class AiSettingsRepositoryImpl implements AiSettingsRepository {
  AiSettingsRepositoryImpl(this._remote);

  final AiSettingsRemoteDataSource _remote;

  @override
  Future<AiSettingsOverview> getSettings() => _remote.getSettings();

  @override
  Future<AiSettingsOverview> patchSettings({
    Map<String, bool>? features,
    bool? byokOptIn,
  }) =>
      _remote.patchSettings(features: features, byokOptIn: byokOptIn);

  @override
  Future<AiUsageSummary> getUsage({int days = 30}) =>
      _remote.getUsage(days: days);

  @override
  Future<AiCredentialsOverview> getCredentials() => _remote.getCredentials();

  @override
  Future<AiCredential> storeCredential(AiCredentialDraft draft) =>
      _remote.storeCredential(draft);

  @override
  Future<AiConnectionTestResult> testCredential(String providerKey) =>
      _remote.testCredential(providerKey);

  @override
  Future<void> revokeCredential(int id) => _remote.revokeCredential(id);
}
