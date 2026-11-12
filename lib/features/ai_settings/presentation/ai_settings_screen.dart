import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../application/ai_settings_controller.dart';
import '../domain/ai_settings_domain.dart';

/// The workspace's AI settings.
///
/// Feature switches can only narrow what the platform allows, the BYOK
/// opt-in only means something while the platform flag is on, and a stored
/// key is shown masked — the plaintext never travels back out. All of it
/// goes through the Laravel API; the app never talks to an AI provider.
class AiSettingsScreen extends ConsumerStatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  ConsumerState<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends ConsumerState<AiSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionsProvider);
    final canManage = permissions.canManageAiSettings;
    final settingsAsync = ref.watch(tenantAiSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('aiSettings')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () {
              ref.invalidate(tenantAiSettingsProvider);
              ref.invalidate(tenantAiUsageProvider);
              ref.invalidate(tenantAiCredentialsProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(tenantAiSettingsProvider),
        ),
        data: (overview) => ListView(
          padding: AppSpacing.page,
          children: [
            if (!overview.aiEnabled) ...[
              InfoBanner(
                tone: InfoBannerTone.warning,
                title: context.tr('aiSettingsPlatformOffTitle'),
                message: context.tr('aiSettingsPlatformOffBody'),
                icon: Icons.power_settings_new_outlined,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            _FeaturesSection(
              overview: overview,
              canManage: canManage,
              onToggle: _toggleFeature,
            ),
            const SizedBox(height: AppSpacing.sm),
            _ByokSection(
              overview: overview,
              canManage: canManage,
              onOptIn: _setByokOptIn,
            ),
            const SizedBox(height: AppSpacing.sm),
            const _UsageSection(),
            if (overview.byokPlatformEnabled) ...[
              const SizedBox(height: AppSpacing.sm),
              _CredentialsSection(
                canManage: canManage,
                onAdd: _openCredentialSheet,
                onTest: _testCredential,
                onRevoke: _revokeCredential,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFeature(AiFeatureToggle feature, bool value) async {
    try {
      await ref
          .read(aiSettingsActionsProvider)
          .toggleFeature(feature.feature, value);
      if (mounted) {
        AppSnack.show(
          context,
          context.tr(
            value ? 'aiSettingsFeatureEnabled' : 'aiSettingsFeatureDisabled',
          ),
        );
      }
    } catch (error) {
      // The server refused the change (e.g. the platform ceiling); return
      // to the server's truth instead of leaving a stale switch on screen.
      ref.invalidate(tenantAiSettingsProvider);
      if (mounted) AppSnack.show(context, _message(error), isError: true);
    }
  }

  Future<void> _setByokOptIn(bool value) async {
    try {
      await ref.read(aiSettingsActionsProvider).setByokOptIn(value);
      if (mounted) {
        AppSnack.show(
          context,
          context.tr(
            value ? 'aiSettingsByokOptedIn' : 'aiSettingsByokOptedOut',
          ),
        );
      }
    } catch (error) {
      ref.invalidate(tenantAiSettingsProvider);
      ref.invalidate(tenantAiCredentialsProvider);
      if (mounted) AppSnack.show(context, _message(error), isError: true);
    }
  }

  Future<void> _openCredentialSheet() async {
    final overview = ref.read(tenantAiCredentialsProvider).valueOrNull;
    final providers = overview?.providers ?? const <AiCredentialProvider>[];
    if (providers.isEmpty) {
      AppSnack.show(context, context.tr('aiSettingsNoProviders'),
          isError: true);
      return;
    }

    final result = await showModalBottomSheet<_AiCredentialFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: _AiCredentialFormSheet(providers: providers),
      ),
    );

    if (result == null) return;

    try {
      await ref.read(aiSettingsActionsProvider).storeCredential(
            AiCredentialDraft(
              provider: result.providerKey,
              apiKey: result.apiKey,
              baseUrl: result.baseUrl,
              model: result.model,
            ),
          );
      if (mounted) AppSnack.show(context, context.tr('aiSettingsKeyStored'));
    } catch (error) {
      if (mounted) AppSnack.show(context, _message(error), isError: true);
    }
  }

  Future<void> _testCredential(AiCredential credential) async {
    final overview = ref.read(tenantAiCredentialsProvider).valueOrNull;
    final provider = overview?.providerOf(credential.providerId);
    if (provider == null) return;

    try {
      final result = await ref
          .read(aiSettingsActionsProvider)
          .testCredential(provider.key);
      if (!mounted) return;

      if (result.ok) {
        AppSnack.show(
          context,
          context
              .tr('aiSettingsKeyTestOk', args: {'latency': result.latencyMs}),
        );
      } else {
        AppSnack.show(context, context.tr('aiSettingsKeyTestFailed'),
            isError: true);
      }
    } catch (error) {
      if (mounted) AppSnack.show(context, _message(error), isError: true);
    }
  }

  Future<void> _revokeCredential(AiCredential credential) async {
    final overview = ref.read(tenantAiCredentialsProvider).valueOrNull;
    final provider = overview?.providerOf(credential.providerId);

    final confirmed = await ConfirmDialog.show(
      context,
      title: context.tr('aiSettingsKeyRevokeTitle'),
      message: context.tr('aiSettingsKeyRevokeBody', args: {
        'masked': credential.maskedKey,
        'provider': provider?.name ?? '',
      }),
      confirmLabel: context.tr('delete'),
      cancelLabel: context.tr('cancel'),
      destructive: true,
    );
    if (!confirmed) return;

    try {
      await ref.read(aiSettingsActionsProvider).revokeCredential(credential.id);
      if (mounted) AppSnack.show(context, context.tr('aiSettingsKeyRevoked'));
    } catch (error) {
      if (mounted) AppSnack.show(context, _message(error), isError: true);
    }
  }

  /// Server messages are the honest reason (platform ceiling, BYOK off, key
  /// too short); anything else collapses to the generic copy.
  String _message(Object error) {
    if (error is ApiException) return error.message;
    return error.toString();
  }
}

/// The per-feature switches. A feature the platform has off renders locked,
/// with its subtitle saying so — it reads as platform policy, not a bug.
class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({
    required this.overview,
    required this.canManage,
    required this.onToggle,
  });

  final AiSettingsOverview overview;
  final bool canManage;
  final Future<void> Function(AiFeatureToggle feature, bool value) onToggle;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: context.tr('aiSettingsFeaturesTitle'),
      subtitle: context.tr('aiSettingsFeaturesSubtitle'),
      child: overview.features.isEmpty
          ? Text(context.tr('noData'))
          : Column(
              children: [
                for (final feature in overview.features)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        feature.feature,
                        textAlign: TextAlign.start,
                        style: context.texts.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    subtitle: !feature.platformEnabled
                        ? Text(context.tr('aiSettingsFeaturePlatformOff'))
                        : null,
                    value: feature.platformEnabled && feature.enabled,
                    onChanged: canManage && feature.platformEnabled
                        ? (value) => onToggle(feature, value)
                        : null,
                  ),
              ],
            ),
    );
  }
}

/// The BYOK opt-in, offered only while the platform allows it.
class _ByokSection extends StatelessWidget {
  const _ByokSection({
    required this.overview,
    required this.canManage,
    required this.onOptIn,
  });

  final AiSettingsOverview overview;
  final bool canManage;
  final Future<void> Function(bool value) onOptIn;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: context.tr('aiSettingsByokTitle'),
      child: overview.byokPlatformEnabled
          ? SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(context.tr('aiSettingsByokLabel')),
              subtitle: Text(context.tr('aiSettingsByokSubtitle')),
              value: overview.byokOptedIn,
              onChanged: canManage ? onOptIn : null,
            )
          : Text(context.tr('aiSettingsByokOff')),
    );
  }
}

/// The workspace's own consumption: counts and estimates, never billing.
class _UsageSection extends ConsumerWidget {
  const _UsageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageAsync = ref.watch(tenantAiUsageProvider);

    return SectionCard(
      title: context.tr('aiSettingsUsageTitle'),
      child: usageAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        ),
        error: (error, stack) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('errorGeneric'),
              style: context.texts.bodySmall
                  ?.copyWith(color: context.dukavo.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: context.tr('retry'),
              variant: AppButtonVariant.text,
              onPressed: () => ref.invalidate(tenantAiUsageProvider),
            ),
          ],
        ),
        data: (usage) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - AppSpacing.sm) / 2;
                return Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    SizedBox(
                      width: width,
                      child: StatisticCard(
                        compact: true,
                        label: context.tr('aiSettingsUsageTodayRequests'),
                        value: '${usage.todayRequests}',
                        icon: Icons.auto_awesome_outlined,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: StatisticCard(
                        compact: true,
                        label: context.tr('aiSettingsUsageTodayTokens'),
                        value: '${usage.todayTokens}',
                        icon: Icons.data_usage,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: StatisticCard(
                        compact: true,
                        label: context.tr('aiSettingsUsageFailures'),
                        value: '${usage.failures}',
                        icon: Icons.error_outline_rounded,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: StatisticCard(
                        compact: true,
                        label: context.tr('aiSettingsUsageCost'),
                        value: '\$${usage.estimatedCostUsd.toStringAsFixed(2)}',
                        icon: Icons.attach_money,
                      ),
                    ),
                  ],
                );
              },
            ),
            if (usage.byFeature.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              for (final feature in usage.byFeature)
                KeyValueRow(
                  label: feature.feature,
                  value: context.tr('aiSettingsUsageRow', args: {
                    'requests': feature.requests,
                    'tokens': feature.tokens,
                  }),
                ),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.tr('aiSettingsUsageEstimatesNote'),
              style: context.texts.bodySmall
                  ?.copyWith(color: context.dukavo.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// The workspace's stored keys. Only shown while BYOK is on.
class _CredentialsSection extends ConsumerWidget {
  const _CredentialsSection({
    required this.canManage,
    required this.onAdd,
    required this.onTest,
    required this.onRevoke,
  });

  final bool canManage;
  final Future<void> Function(AiCredential credential) onTest;
  final Future<void> Function(AiCredential credential) onRevoke;

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentialsAsync = ref.watch(tenantAiCredentialsProvider);

    return SectionCard(
      title: context.tr('aiSettingsKeysTitle'),
      subtitle: context.tr('aiSettingsKeysSubtitle'),
      trailing: canManage
          ? IconButton(
              tooltip: context.tr('create'),
              onPressed: onAdd,
              icon: const Icon(Icons.add),
            )
          : null,
      child: credentialsAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        ),
        error: (error, stack) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('errorGeneric'),
              style: context.texts.bodySmall
                  ?.copyWith(color: context.dukavo.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: context.tr('retry'),
              variant: AppButtonVariant.text,
              onPressed: () => ref.invalidate(tenantAiCredentialsProvider),
            ),
          ],
        ),
        data: (overview) {
          if (overview.credentials.isEmpty) {
            return Text(context.tr('aiSettingsKeysEmpty'));
          }

          return Column(
            children: [
              for (final credential in overview.credentials)
                _CredentialRow(
                  credential: credential,
                  providerName:
                      overview.providerOf(credential.providerId)?.name,
                  canManage: canManage,
                  onTest: onTest,
                  onRevoke: onRevoke,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({
    required this.credential,
    required this.providerName,
    required this.canManage,
    required this.onTest,
    required this.onRevoke,
  });

  final AiCredential credential;
  final String? providerName;
  final bool canManage;
  final Future<void> Function(AiCredential credential) onTest;
  final Future<void> Function(AiCredential credential) onRevoke;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  providerName ?? '#${credential.providerId}',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    credential.maskedKey,
                    textAlign: TextAlign.start,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                if (credential.model != null && credential.model!.isNotEmpty)
                  Text(
                    credential.model!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.textTheme.bodySmall!.color),
                  ),
              ],
            ),
          ),
          if (canManage) ...[
            IconButton(
              tooltip: context.tr('aiSettingsKeyTest'),
              onPressed: () => onTest(credential),
              icon: const Icon(Icons.wifi_tethering),
            ),
            IconButton(
              tooltip: context.tr('delete'),
              onPressed: () => onRevoke(credential),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ],
      ),
    );
  }
}

class _AiCredentialFormResult {
  const _AiCredentialFormResult({
    required this.providerKey,
    required this.apiKey,
    this.baseUrl,
    this.model,
  });

  final String providerKey;
  final String apiKey;
  final String? baseUrl;
  final String? model;
}

/// Store or rotate the workspace's key for one provider.
class _AiCredentialFormSheet extends StatefulWidget {
  const _AiCredentialFormSheet({required this.providers});

  final List<AiCredentialProvider> providers;

  @override
  State<_AiCredentialFormSheet> createState() => _AiCredentialFormSheetState();
}

class _AiCredentialFormSheetState extends State<_AiCredentialFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _apiKey = TextEditingController();
  final _baseUrl = TextEditingController();
  final _model = TextEditingController();
  late String _providerKey = widget.providers.first.key;

  @override
  void dispose() {
    _apiKey.dispose();
    _baseUrl.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('aiSettingsKeyFormTitle'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.tr('aiSettingsKeyFormHint'),
              style: context.texts.bodySmall
                  ?.copyWith(color: context.dukavo.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _providerKey,
              decoration: InputDecoration(
                labelText: context.tr('aiSettingsKeyProviderLabel'),
              ),
              items: [
                for (final provider in widget.providers)
                  DropdownMenuItem(
                    value: provider.key,
                    child: Text(provider.name),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _providerKey = value);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _apiKey,
              label: context.tr('aiSettingsKeyApiKeyLabel'),
              helper: context.tr('aiSettingsKeyApiKeyHint'),
              obscureText: true,
              validator: (value) => value == null || value.trim().length < 8
                  ? context.tr('aiSettingsKeyTooShort')
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _baseUrl,
              label: context.tr('aiSettingsKeyBaseUrlLabel'),
              helper: context.tr('aiSettingsKeyBaseUrlHint'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _model,
              label: context.tr('aiSettingsKeyModelLabel'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: context.tr('save'),
              expand: true,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

    Navigator.of(context).pop(
      _AiCredentialFormResult(
        providerKey: _providerKey,
        apiKey: _apiKey.text.trim(),
        baseUrl: _baseUrl.text.trim().isEmpty ? null : _baseUrl.text.trim(),
        model: _model.text.trim().isEmpty ? null : _model.text.trim(),
      ),
    );
  }
}
