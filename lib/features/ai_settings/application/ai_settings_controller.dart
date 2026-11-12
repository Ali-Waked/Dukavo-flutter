import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/ai_settings_data.dart';
import '../domain/ai_settings_domain.dart';

final aiSettingsRepositoryProvider = Provider<AiSettingsRepository>((ref) {
  return AiSettingsRepositoryImpl(
    AiSettingsRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final tenantAiSettingsProvider = FutureProvider<AiSettingsOverview>((ref) {
  return ref.watch(aiSettingsRepositoryProvider).getSettings();
});

final tenantAiUsageProvider = FutureProvider<AiUsageSummary>((ref) {
  return ref.watch(aiSettingsRepositoryProvider).getUsage();
});

final tenantAiCredentialsProvider =
    FutureProvider<AiCredentialsOverview>((ref) {
  return ref.watch(aiSettingsRepositoryProvider).getCredentials();
});

class AiSettingsActions {
  AiSettingsActions(this._ref);

  final Ref _ref;

  /// Flip one feature for the workspace. The server refuses enabling a
  /// feature the platform has off (422); the caller reverts the switch on
  /// failure so the UI never shows a state the server rejected.
  Future<AiSettingsOverview> toggleFeature(String feature, bool enabled) async {
    final overview = await _ref
        .read(aiSettingsRepositoryProvider)
        .patchSettings(features: {feature: enabled});
    _ref.invalidate(tenantAiSettingsProvider);
    _ref.invalidate(tenantAiUsageProvider);
    return overview;
  }

  /// Opt the workspace in or out of routing through its own keys. The server
  /// answers 403 while the platform has BYOK off.
  Future<AiSettingsOverview> setByokOptIn(bool optIn) async {
    final overview = await _ref
        .read(aiSettingsRepositoryProvider)
        .patchSettings(byokOptIn: optIn);
    _ref.invalidate(tenantAiSettingsProvider);
    _ref.invalidate(tenantAiCredentialsProvider);
    return overview;
  }

  Future<AiCredential> storeCredential(AiCredentialDraft draft) async {
    final credential =
        await _ref.read(aiSettingsRepositoryProvider).storeCredential(draft);
    _ref.invalidate(tenantAiCredentialsProvider);
    return credential;
  }

  /// Exercises the workspace's own key — never the platform's.
  Future<AiConnectionTestResult> testCredential(String providerKey) {
    return _ref.read(aiSettingsRepositoryProvider).testCredential(providerKey);
  }

  Future<void> revokeCredential(int id) async {
    await _ref.read(aiSettingsRepositoryProvider).revokeCredential(id);
    _ref.invalidate(tenantAiCredentialsProvider);
  }
}

final aiSettingsActionsProvider =
    Provider<AiSettingsActions>(AiSettingsActions.new);
