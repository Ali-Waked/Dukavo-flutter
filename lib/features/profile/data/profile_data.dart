import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/profile_domain.dart';

class ProfileModel {
  const ProfileModel._();

  static UserProfile fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: _int(json['id']),
      name: '${json['name'] ?? ''}',
      email: '${json['email'] ?? ''}',
      phone: json['phone'] as String?,
      locale: json['locale'] as String?,
      status: '${json['status'] ?? 'active'}',
      avatarUrl: json['avatar_url'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      lastLoginAt: json['last_login_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._api);

  final ApiClient _api;

  Future<UserProfile> get() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.profile,
      decode: _asMap,
    );
    return ProfileModel.fromJson(data);
  }

  Future<UserProfile> update(ProfileUpdateDraft draft) async {
    final data = await _api.patch<Map<String, dynamic>>(
      ApiPaths.profile,
      body: draft.toJson(),
      decode: _asMap,
    );
    return ProfileModel.fromJson(data);
  }

  Future<UserProfile> uploadAvatar(List<int> bytes, String filename) async {
    final form = FormData.fromMap({
      'avatar': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.profileAvatar,
      body: form,
      decode: _asMap,
    );
    return ProfileModel.fromJson(data);
  }

  Future<UserProfile> removeAvatar() async {
    final data = await _api.deleteJson<Map<String, dynamic>>(
      ApiPaths.profileAvatar,
      decode: _asMap,
    );
    return ProfileModel.fromJson(data);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) {
    return _api.putVoid(
      ApiPaths.profilePassword,
      body: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  Future<List<ProfileSession>> sessions() async {
    final data = await _api.get<List<dynamic>>(
      ApiPaths.profileSessions,
      decode: (raw) => raw is List ? raw : const <dynamic>[],
    );
    return data.whereType<Map>().map((entry) {
      final map = Map<String, dynamic>.from(entry);
      return ProfileSession(
        id: ProfileModel._int(map['id']),
        name: '${map['name'] ?? ''}',
        isCurrent: map['is_current'] == true,
        lastUsedAt: map['last_used_at'] as String?,
        expiresAt: map['expires_at'] as String?,
        createdAt: map['created_at'] as String?,
      );
    }).toList();
  }

  Future<void> revokeSession(int id) {
    return _api.delete(ApiPaths.profileSession('$id'));
  }

  Future<void> revokeOtherSessions() {
    return _api.delete(ApiPaths.profileSessions);
  }

  Future<NotificationPreferences> notificationPreferences() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.profileNotifications,
      decode: _asMap,
    );
    return _preferences(data);
  }

  Future<NotificationPreferences> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    final data = await _api.put<Map<String, dynamic>>(
      ApiPaths.profileNotifications,
      body: preferences.toJson(),
      decode: _asMap,
    );
    return _preferences(data);
  }

  Future<Map<String, NotificationChannelState>> notificationChannels() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.profileNotificationChannels,
      decode: _asMap,
    );
    return {
      for (final entry in data.entries)
        if (entry.value is Map)
          entry.key: NotificationChannelState(
            available: (entry.value as Map)['available'] == true,
            label: '${(entry.value as Map)['label'] ?? entry.key}',
            reason: (entry.value as Map)['reason'] as String?,
          ),
    };
  }

  static NotificationPreferences _preferences(Map<String, dynamic> data) {
    return NotificationPreferences({
      for (final channel in data.entries)
        if (channel.value is Map)
          channel.key: {
            for (final event in (channel.value as Map).entries)
              if (event.value is bool) '${event.key}': event.value as bool,
          },
    });
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<UserProfile> get() => _remote.get();

  @override
  Future<UserProfile> update(ProfileUpdateDraft draft) => _remote.update(draft);

  @override
  Future<UserProfile> uploadAvatar(List<int> bytes, String filename) =>
      _remote.uploadAvatar(bytes, filename);

  @override
  Future<UserProfile> removeAvatar() => _remote.removeAvatar();

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) {
    return _remote.changePassword(
      currentPassword: currentPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  @override
  Future<List<ProfileSession>> sessions() => _remote.sessions();

  @override
  Future<void> revokeSession(int id) => _remote.revokeSession(id);

  @override
  Future<void> revokeOtherSessions() => _remote.revokeOtherSessions();

  @override
  Future<NotificationPreferences> notificationPreferences() =>
      _remote.notificationPreferences();

  @override
  Future<NotificationPreferences> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) {
    return _remote.updateNotificationPreferences(preferences);
  }

  @override
  Future<Map<String, NotificationChannelState>> notificationChannels() =>
      _remote.notificationChannels();
}
