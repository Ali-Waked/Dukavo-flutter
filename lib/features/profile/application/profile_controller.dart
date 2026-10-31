import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../auth/application/auth_controller.dart';
import '../data/profile_data.dart';
import '../domain/profile_domain.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    ProfileRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final profileProvider = FutureProvider<UserProfile>((ref) {
  return ref.watch(profileRepositoryProvider).get();
});

final profileSessionsProvider = FutureProvider<List<ProfileSession>>((ref) {
  return ref.watch(profileRepositoryProvider).sessions();
});

final notificationPreferencesProvider =
    FutureProvider<NotificationPreferences>((ref) {
  return ref.watch(profileRepositoryProvider).notificationPreferences();
});

final notificationChannelsProvider =
    FutureProvider<Map<String, NotificationChannelState>>((ref) {
  return ref.watch(profileRepositoryProvider).notificationChannels();
});

class ProfileActions {
  ProfileActions(this._ref);

  final Ref _ref;

  Future<UserProfile> update(ProfileUpdateDraft draft) async {
    final profile = await _ref.read(profileRepositoryProvider).update(draft);
    _refresh();
    return profile;
  }

  Future<UserProfile> uploadAvatar(List<int> bytes, String filename) async {
    final profile =
        await _ref.read(profileRepositoryProvider).uploadAvatar(bytes, filename);
    _refresh();
    return profile;
  }

  Future<UserProfile> removeAvatar() async {
    final profile = await _ref.read(profileRepositoryProvider).removeAvatar();
    _refresh();
    return profile;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _ref.read(profileRepositoryProvider).changePassword(
          currentPassword: currentPassword,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );
    // The server signs every other device out after a password change.
    _ref.invalidate(profileSessionsProvider);
  }

  Future<void> revokeSession(int id) async {
    await _ref.read(profileRepositoryProvider).revokeSession(id);
    _ref.invalidate(profileSessionsProvider);
  }

  Future<void> revokeOtherSessions() async {
    await _ref.read(profileRepositoryProvider).revokeOtherSessions();
    _ref.invalidate(profileSessionsProvider);
  }

  Future<NotificationPreferences> saveNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    final saved = await _ref
        .read(profileRepositoryProvider)
        .updateNotificationPreferences(preferences);
    _ref.invalidate(notificationPreferencesProvider);
    return saved;
  }

  void _refresh() {
    _ref.invalidate(profileProvider);
    // The session feeds the shell's name/avatar, so keep it in step.
    _ref.read(authControllerProvider.notifier).refreshSession();
  }
}

final profileActionsProvider = Provider<ProfileActions>(ProfileActions.new);
