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

final accountOverviewProvider = FutureProvider<AccountOverview>((ref) {
  return ref.watch(profileRepositoryProvider).overview();
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

/* First-login preferences */

final onboardingStatusProvider = FutureProvider<OnboardingStatus>((ref) {
  return ref.watch(profileRepositoryProvider).onboardingStatus();
});

/* Location catalogues */

final countriesProvider = FutureProvider<CountryCatalogue>((ref) {
  return ref.watch(profileRepositoryProvider).countries();
});

final timezonesProvider = FutureProvider<TimezoneCatalogue>((ref) {
  return ref.watch(profileRepositoryProvider).timezones();
});

/* Two-factor authentication */

final twoFactorStatusProvider = FutureProvider<TwoFactorStatus>((ref) {
  return ref.watch(profileRepositoryProvider).twoFactorStatus();
});

/* Security history */

final securityActivityProvider = FutureProvider<List<SecurityEvent>>((ref) {
  return ref.watch(profileRepositoryProvider).securityActivity();
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
    final profile = await _ref
        .read(profileRepositoryProvider)
        .uploadAvatar(bytes, filename);
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
    _ref.invalidate(securityActivityProvider);
    _ref.invalidate(profileProvider);
  }

  Future<void> revokeSession(int id) async {
    await _ref.read(profileRepositoryProvider).revokeSession(id);
    _ref.invalidate(profileSessionsProvider);
    _ref.invalidate(securityActivityProvider);
  }

  Future<void> revokeOtherSessions() async {
    await _ref.read(profileRepositoryProvider).revokeOtherSessions();
    _ref.invalidate(profileSessionsProvider);
    _ref.invalidate(securityActivityProvider);
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

  /* First-login preferences */

  Future<UserProfile> completeOnboarding(OnboardingDraft draft) async {
    final profile =
        await _ref.read(profileRepositoryProvider).completeOnboarding(draft);
    _ref.invalidate(onboardingStatusProvider);
    _refresh();
    return profile;
  }

  Future<void> skipOnboarding() async {
    await _ref.read(profileRepositoryProvider).skipOnboarding();
    _ref.invalidate(onboardingStatusProvider);
    _ref.invalidate(profileProvider);
  }

  /* Two-factor authentication */

  Future<TwoFactorSetup> startTwoFactorSetup() async {
    return _ref.read(profileRepositoryProvider).startTwoFactorSetup();
  }

  Future<TwoFactorConfirmResult> confirmTwoFactor(String code) async {
    final result =
        await _ref.read(profileRepositoryProvider).confirmTwoFactor(code);
    _ref.invalidate(twoFactorStatusProvider);
    _ref.invalidate(profileProvider);
    _ref.invalidate(securityActivityProvider);
    return result;
  }

  Future<List<String>> regenerateRecoveryCodes(String code) async {
    final codes =
        await _ref.read(profileRepositoryProvider).regenerateRecoveryCodes(code);
    _ref.invalidate(twoFactorStatusProvider);
    _ref.invalidate(securityActivityProvider);
    return codes;
  }

  Future<TwoFactorStatus> disableTwoFactor({
    required String password,
    String? code,
    String? recoveryCode,
  }) async {
    final status = await _ref.read(profileRepositoryProvider).disableTwoFactor(
          password: password,
          code: code,
          recoveryCode: recoveryCode,
        );
    _ref.invalidate(twoFactorStatusProvider);
    _ref.invalidate(profileProvider);
    _ref.invalidate(securityActivityProvider);
    return status;
  }

  void _refresh() {
    _ref.invalidate(profileProvider);
    // The session feeds the shell's name/avatar, so keep it in step.
    _ref.read(authControllerProvider.notifier).refreshSession();
  }
}

final profileActionsProvider = Provider<ProfileActions>(ProfileActions.new);
