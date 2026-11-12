import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../application/settings_controller.dart';
import '../domain/settings_models.dart';

/// Infrastructure posture, read-only by design.
///
/// These values come from the deployment environment — application key,
/// database, cache, queue, session and mailer. They are shown so an operator can
/// confirm what the running process uses; they cannot be changed from here and a
/// secret renders only as configured or not configured.
class PlatformSettingsInfrastructureScreen extends ConsumerWidget {
  const PlatformSettingsInfrastructureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final system = ref.watch(platformSystemProvider);
    final section = ref.watch(settingsSectionProvider('infrastructure'));
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('platformSettingsInfrastructureTitle')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () {
              ref.invalidate(platformSystemProvider);
              ref.invalidate(settingsSectionProvider('infrastructure'));
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: !permissions.canViewPlatformConfiguration
          ? EmptyState(
              icon: Icons.lock_outline_rounded,
              title: context.tr('noPermissionTitle'),
              message: context.tr('noPermissionMessage'),
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(platformSystemProvider);
                ref.invalidate(settingsSectionProvider('infrastructure'));
              },
              child: ListView(
                padding: AppSpacing.page,
                children: [
                  StatusBanner(
                    title: context.tr('platformSettingsInfraReadOnlyTitle'),
                    message: context.tr('platformSettingsInfraReadOnlyBody'),
                    tone: StatusBannerTone.info,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  system.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: LoadingView(),
                    ),
                    error: (error, stack) => ErrorView(
                      message: _message(context, error),
                      onRetry: () => ref.invalidate(platformSystemProvider),
                    ),
                    data: (summary) => _RuntimeCard(summary: summary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  section.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: LoadingView(),
                    ),
                    error: (error, stack) => ErrorView(
                      message: _message(context, error),
                      onRetry: () => ref.invalidate(
                        settingsSectionProvider('infrastructure'),
                      ),
                    ),
                    data: (data) => _VariablesCard(
                      settings: data.category.settings,
                      isArabic:
                          Localizations.localeOf(context).languageCode == 'ar',
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  static String _message(BuildContext context, Object error) {
    if (error is ApiException && error.message.isNotEmpty) return error.message;
    return context.tr('errorGeneric');
  }
}

class _RuntimeCard extends StatelessWidget {
  const _RuntimeCard({required this.summary});

  final PlatformSystemSummary summary;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      (context.tr('environment'), summary.environment),
      (context.tr('platformSettingsInfraPhp'), summary.phpVersion),
      (context.tr('platformSettingsInfraLaravel'), summary.laravelVersion),
      (context.tr('timezone'), summary.timezone),
      (context.tr('platformSettingsInfraDatabase'), summary.database),
      (context.tr('platformSettingsInfraCache'), summary.cache),
      (context.tr('platformSettingsInfraQueue'), summary.queue),
      (context.tr('platformSettingsInfraSession'), summary.session),
      (context.tr('platformSettingsInfraMailer'), summary.mailer),
      (context.tr('platformSettingsInfraFilesystem'), summary.filesystem),
    ];

    return SectionCard(
      title: context.tr('platformSettingsInfraRuntimeTitle'),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    rows[index].$1,
                    style: context.texts.bodySmall
                        ?.copyWith(color: context.dukavo.textSecondary),
                  ),
                ),
                Text(
                  rows[index].$2.isEmpty ? '—' : rows[index].$2,
                  style: context.texts.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            if (index != rows.length - 1)
              const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _VariablesCard extends StatelessWidget {
  const _VariablesCard({required this.settings, required this.isArabic});

  final List<SettingDefinition> settings;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: context.tr('platformSettingsInfraVariablesTitle'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          for (var index = 0; index < settings.length; index++) ...[
            _VariableRow(setting: settings[index], isArabic: isArabic),
            if (index != settings.length - 1) ...[
              const SizedBox(height: AppSpacing.xs),
              Divider(height: 1, color: context.dukavo.border),
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
        ],
      ),
    );
  }
}

class _VariableRow extends StatelessWidget {
  const _VariableRow({required this.setting, required this.isArabic});

  final SettingDefinition setting;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      setting.labelFor(isArabic),
                      style: context.texts.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (setting.isSecret) ...[
                    const SizedBox(width: AppSpacing.xxs),
                    Icon(Icons.lock_outline_rounded,
                        size: 14, color: context.dukavo.textMuted),
                  ],
                ],
              ),
              if (setting.descriptionFor(isArabic).isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  setting.descriptionFor(isArabic),
                  style: context.texts.bodySmall?.copyWith(
                    color: context.dukavo.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
              if (setting.envKey != null) ...[
                const SizedBox(height: 2),
                Text(
                  setting.envKey!,
                  style: context.texts.labelSmall?.copyWith(
                    color: context.dukavo.textMuted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        StatusChip(
          status: setting.configured ? 'active' : 'inactive',
          label: setting.isSecret
              ? (setting.configured
                  ? context.tr('platformSettingsSecretConfigured')
                  : context.tr('platformSettingsSecretMissing'))
              : _display(context, setting.value),
          compact: true,
        ),
      ],
    );
  }

  String _display(BuildContext context, Object? value) {
    if (value == null) return context.tr('platformSettingsHistoryNone');
    if (value is bool) {
      return value ? context.tr('enabled') : context.tr('disabled');
    }
    final text = '$value';
    return text.isEmpty ? context.tr('platformSettingsHistoryNone') : text;
  }
}
