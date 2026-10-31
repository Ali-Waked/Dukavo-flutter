/// The signed-in person's own account, mirroring `ProfileResource`.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    this.phone,
    this.locale,
    this.avatarUrl,
    this.emailVerifiedAt,
    this.lastLoginAt,
    this.createdAt,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? locale;
  final String status;
  final String? avatarUrl;
  final String? emailVerifiedAt;
  final String? lastLoginAt;
  final String? createdAt;
}

/// One Sanctum token, described as a signed-in device.
class ProfileSession {
  const ProfileSession({
    required this.id,
    required this.name,
    required this.isCurrent,
    this.lastUsedAt,
    this.expiresAt,
    this.createdAt,
  });

  final int id;
  final String name;
  final bool isCurrent;
  final String? lastUsedAt;
  final String? expiresAt;
  final String? createdAt;
}

class NotificationChannelState {
  const NotificationChannelState({
    required this.available,
    required this.label,
    this.reason,
  });

  final bool available;
  final String label;
  final String? reason;
}

/// Channel -> event -> enabled.
class NotificationPreferences {
  const NotificationPreferences(this.values);

  final Map<String, Map<String, bool>> values;

  bool isEnabled(String channel, String event) =>
      values[channel]?[event] ?? false;

  NotificationPreferences copyWithEvent(
    String channel,
    String event,
    bool enabled,
  ) {
    final next = <String, Map<String, bool>>{
      for (final entry in values.entries)
        entry.key: Map<String, bool>.from(entry.value),
    };
    next.putIfAbsent(channel, () => <String, bool>{})[event] = enabled;
    return NotificationPreferences(next);
  }

  Map<String, dynamic> toJson() => {
        for (final entry in values.entries) entry.key: entry.value,
      };
}

class ProfileUpdateDraft {
  const ProfileUpdateDraft({
    this.name,
    this.phone,
    this.locale,
  });

  final String? name;
  final String? phone;
  final String? locale;

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (locale != null) 'locale': locale,
      };
}

abstract class ProfileRepository {
  Future<UserProfile> get();

  Future<UserProfile> update(ProfileUpdateDraft draft);

  Future<UserProfile> uploadAvatar(List<int> bytes, String filename);

  Future<UserProfile> removeAvatar();

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  });

  Future<List<ProfileSession>> sessions();

  Future<void> revokeSession(int id);

  Future<void> revokeOtherSessions();

  Future<NotificationPreferences> notificationPreferences();

  Future<NotificationPreferences> updateNotificationPreferences(
    NotificationPreferences preferences,
  );

  Future<Map<String, NotificationChannelState>> notificationChannels();
}
