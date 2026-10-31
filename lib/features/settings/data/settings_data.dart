import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/settings_domain.dart';

class WorkspaceSettingsModel {
  const WorkspaceSettingsModel._();

  static WorkspaceSettings fromJson(Map<String, dynamic> json) {
    return WorkspaceSettings(
      id: _int(json['id']),
      name: '${json['name'] ?? ''}',
      slug: '${json['slug'] ?? ''}',
      currency: '${json['currency'] ?? 'USD'}',
      timezone: '${json['timezone'] ?? 'UTC'}',
      contactEmail: json['contact_email'] as String?,
      phone: json['phone'] as String?,
      locale: json['locale'] as String?,
    );
  }

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}

class SettingsRemoteDataSource {
  SettingsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<WorkspaceSettings> get() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.workspaceSettings,
      decode: _asMap,
    );
    return WorkspaceSettingsModel.fromJson(data);
  }

  Future<WorkspaceSettings> update(WorkspaceSettingsDraft draft) async {
    final data = await _api.patch<Map<String, dynamic>>(
      ApiPaths.workspaceSettings,
      body: draft.toJson(),
      decode: _asMap,
    );
    return WorkspaceSettingsModel.fromJson(data);
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._remote);

  final SettingsRemoteDataSource _remote;

  @override
  Future<WorkspaceSettings> get() => _remote.get();

  @override
  Future<WorkspaceSettings> update(WorkspaceSettingsDraft draft) =>
      _remote.update(draft);
}
