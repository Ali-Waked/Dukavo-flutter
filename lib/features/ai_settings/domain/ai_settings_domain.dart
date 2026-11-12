/// The workspace's own AI surface: feature switches, BYOK keys and usage.
///
/// Everything here can only *narrow* what the platform allows: a feature the
/// platform has disabled reads as platform policy, not a bug, and
/// bring-your-own-key only means anything while the platform flag is on.
library;

/// One AI feature the workspace may run or switch off.
class AiFeatureToggle {
  const AiFeatureToggle({
    required this.feature,
    required this.enabled,
    required this.platformEnabled,
  });

  /// The server's feature identifier, e.g. `merchant_copilot`.
  final String feature;

  /// Whether this workspace runs it.
  final bool enabled;

  /// The platform ceiling: when off, the workspace cannot switch it on.
  final bool platformEnabled;
}

/// The settings payload from `GET /tenant/ai-settings`.
class AiSettingsOverview {
  const AiSettingsOverview({
    required this.aiEnabled,
    required this.features,
    required this.byokPlatformEnabled,
    required this.byokOptedIn,
  });

  final bool aiEnabled;
  final List<AiFeatureToggle> features;
  final bool byokPlatformEnabled;
  final bool byokOptedIn;
}

/// One feature's share of the workspace's AI consumption.
class AiFeatureUsage {
  const AiFeatureUsage({
    required this.feature,
    required this.requests,
    required this.failures,
    required this.tokens,
  });

  final String feature;
  final int requests;
  final int failures;
  final int tokens;
}

/// The workspace's consumption summary from `GET /tenant/ai-settings/usage`.
class AiUsageSummary {
  const AiUsageSummary({
    required this.todayRequests,
    required this.todayTokens,
    required this.requests,
    required this.failures,
    required this.tokens,
    required this.estimatedCostUsd,
    required this.byFeature,
  });

  final int todayRequests;
  final int todayTokens;
  final int requests;
  final int failures;
  final int tokens;

  /// An estimate from declared model prices — operational signal, never a
  /// billing figure.
  final double estimatedCostUsd;
  final List<AiFeatureUsage> byFeature;
}

/// A provider the workspace may bring its own key for.
class AiCredentialProvider {
  const AiCredentialProvider({
    required this.id,
    required this.key,
    required this.name,
    required this.driver,
  });

  final int id;

  /// The provider's stable key — credentials are addressed by it.
  final String key;
  final String name;
  final String driver;
}

/// A stored workspace key, masked. The plaintext never travels back out.
class AiCredential {
  const AiCredential({
    required this.id,
    required this.providerId,
    required this.maskedKey,
    this.baseUrl,
    this.model,
    this.lastCheckedAt,
    this.lastCheckStatus,
  });

  final int id;
  final int providerId;

  /// Only the trailing characters. Not the key.
  final String maskedKey;
  final String? baseUrl;
  final String? model;
  final String? lastCheckedAt;
  final String? lastCheckStatus;
}

/// The BYOK surface: stored keys plus the providers they may be stored for.
class AiCredentialsOverview {
  const AiCredentialsOverview({
    required this.byokPlatformEnabled,
    required this.byokOptedIn,
    required this.credentials,
    required this.providers,
  });

  final bool byokPlatformEnabled;
  final bool byokOptedIn;
  final List<AiCredential> credentials;
  final List<AiCredentialProvider> providers;

  /// Credentials carry only `provider_id`; the name is looked up here so the
  /// list can render a human label without a second request.
  AiCredentialProvider? providerOf(int id) {
    for (final provider in providers) {
      if (provider.id == id) return provider;
    }
    return null;
  }
}

/// A new key to store (or rotate) for one provider.
class AiCredentialDraft {
  const AiCredentialDraft({
    required this.provider,
    required this.apiKey,
    this.baseUrl,
    this.model,
  });

  /// The provider's stable key.
  final String provider;
  final String apiKey;
  final String? baseUrl;
  final String? model;

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'api_key': apiKey,
        if (_clean(baseUrl) != null) 'base_url': _clean(baseUrl),
        if (_clean(model) != null) 'model': _clean(model),
      };

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

/// The result of exercising a stored key against its provider.
class AiConnectionTestResult {
  const AiConnectionTestResult({
    required this.ok,
    required this.status,
    required this.latencyMs,
    this.reason,
  });

  final bool ok;
  final int status;
  final int latencyMs;

  /// `not_configured`, `unsupported` or `connection` when the check failed.
  final String? reason;
}

abstract class AiSettingsRepository {
  Future<AiSettingsOverview> getSettings();

  Future<AiSettingsOverview> patchSettings({
    Map<String, bool>? features,
    bool? byokOptIn,
  });

  Future<AiUsageSummary> getUsage({int days = 30});

  Future<AiCredentialsOverview> getCredentials();

  Future<AiCredential> storeCredential(AiCredentialDraft draft);

  Future<AiConnectionTestResult> testCredential(String providerKey);

  Future<void> revokeCredential(int id);
}
