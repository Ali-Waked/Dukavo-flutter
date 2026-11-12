import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/permissions.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../application/settings_controller.dart';
import '../domain/settings_models.dart';

/// The configuration hub.
///
/// One screen lists every section the server says exists. Nothing is invented
/// here: a category the registry does not define cannot appear, and a category
/// the operator cannot read is filtered out before it is drawn.
class PlatformSettingsScreen extends ConsumerWidget {
  const PlatformSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);

    if (!permissions.canViewPlatformSettings) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('platformSettings'))),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: context.tr('noPermissionTitle'),
          message: context.tr('noPermissionMessage'),
        ),
      );
    }

    final catalogue = ref.watch(settingsCatalogueProvider);
    final system = ref.watch(platformSystemProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('platformSettings')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () {
              ref.invalidate(settingsCatalogueProvider);
              ref.invalidate(platformSystemProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(settingsCatalogueProvider);
          ref.invalidate(platformSystemProvider);
        },
        child: ListView(
          padding: AppSpacing.page,
          children: [
            Text(
              context.tr('platformSettingsSubtitle'),
              style: context.texts.bodyMedium
                  ?.copyWith(color: context.dukavo.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            system.maybeWhen(
              data: (summary) => _SystemSummary(
                summary: summary,
                onMaintenance: permissions.canViewPlatformSecurity
                    ? () => context.push(
                          RoutePaths.platformSettingsSection('maintenance'),
                        )
                    : null,
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.lg),
            catalogue.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: LoadingView(),
              ),
              error: (error, stack) => ErrorView(
                message: _message(context, error),
                onRetry: () => ref.invalidate(settingsCatalogueProvider),
              ),
              data: (data) => _Catalogue(
                catalogue: data,
                isArabic: isArabic,
                permissions: permissions,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _OperationsGroup(),
            const SizedBox(height: AppSpacing.lg),
            InfoBanner(
              icon: Icons.info_outline_rounded,
              message: context.tr('platformSettingsSpecialists'),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.tr('platformSettingsAuditNote'),
              style: context.texts.bodySmall
                  ?.copyWith(color: context.dukavo.textMuted),
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

class _Catalogue extends StatelessWidget {
  const _Catalogue({
    required this.catalogue,
    required this.isArabic,
    required this.permissions,
  });

  final SettingsCatalogue catalogue;
  final bool isArabic;
  final Permissions permissions;

  @override
  Widget build(BuildContext context) {
    final sections = <SettingsCategory>[];
    SettingsCategory? features;

    for (final category in catalogue.categories) {
      if (category.key == 'features') {
        features = category;
        continue;
      }

      if (category.key == 'infrastructure') continue;

      sections.add(category);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppListGroup(
          title: context.tr('platformSettingsSections'),
          children: [
            for (final category in sections)
              _SectionTile(
                icon: _iconFor(category.key),
                title: category.labelFor(isArabic),
                subtitle: context.tr('platformSettingsSectionMeta', args: {
                  'settings': category.settings.length,
                  'overrides': category.overrideCount,
                }),
                trailing: category.holdsSecrets && category.secretCount > 0
                    ? StatusChip(
                        status: 'active',
                        label: context.tr('platformSettingsSecretCount',
                            args: {'count': category.secretCount}),
                        compact: true,
                        showDot: false,
                      )
                    : null,
                onTap: () => context.push(
                  RoutePaths.platformSettingsSection(category.key),
                ),
              ),
          ],
        ),
        if (features != null && permissions.canViewPlatformFeatures) ...[
          const SizedBox(height: AppSpacing.md),
          AppListGroup(
            title: context.tr('platformSettingsControls'),
            children: [
              _SectionTile(
                icon: Icons.toggle_on_outlined,
                title: context.tr('platformSettingsFeaturesTitle'),
                subtitle: context.tr('platformSettingsFeaturesSubtitle'),
                onTap: () => context.push(RoutePaths.platformSettingsFeatures),
              ),
            ],
          ),
        ],
      ],
    );
  }

  static IconData _iconFor(String category) {
    return switch (category) {
      'general' => Icons.tune_rounded,
      'localization' => Icons.language_rounded,
      'email' => Icons.mail_outline_rounded,
      'storage' => Icons.folder_outlined,
      'security' => Icons.shield_outlined,
      'whatsapp' => Icons.chat_outlined,
      'maintenance' => Icons.construction_outlined,
      'ai' => Icons.auto_awesome_outlined,
      _ => Icons.settings_outlined,
    };
  }
}

class _OperationsGroup extends StatelessWidget {
  const _OperationsGroup();

  @override
  Widget build(BuildContext context) {
    return AppListGroup(
      title: context.tr('platformSettingsOperations'),
      children: [
        _SectionTile(
          icon: Icons.monitor_heart_outlined,
          title: context.tr('platformSettingsHealthTitle'),
          subtitle: context.tr('platformSettingsHealthSubtitle'),
          onTap: () => context.push(RoutePaths.platformSettingsHealth),
        ),
        _SectionTile(
          icon: Icons.history_rounded,
          title: context.tr('platformSettingsHistoryTitle'),
          subtitle: context.tr('platformSettingsHistorySubtitle'),
          onTap: () => context.push(RoutePaths.platformSettingsHistory),
        ),
        _SectionTile(
          icon: Icons.dns_outlined,
          title: context.tr('platformSettingsInfrastructureTitle'),
          subtitle: context.tr('platformSettingsInfrastructureSubtitle'),
          onTap: () =>
              context.push(RoutePaths.platformSettingsInfrastructure),
        ),
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.scheme.primary.withValues(
            alpha: context.isDark ? 0.18 : 0.09,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, size: 20, color: context.scheme.primary),
      ),
      title: Text(
        title,
        style: context.texts.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: context.texts.bodySmall
            ?.copyWith(color: context.dukavo.textSecondary),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _SystemSummary extends StatelessWidget {
  const _SystemSummary({required this.summary, this.onMaintenance});

  final PlatformSystemSummary summary;
  final VoidCallback? onMaintenance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary.maintenanceEnabled) ...[
          StatusBanner(
            message: summary.maintenanceMessage.isEmpty
                ? context.tr('platformSettingsMaintenanceActive')
                : summary.maintenanceMessage,
            title: context.tr('platformSettingsMaintenanceActive'),
            tone: StatusBannerTone.warning,
            actionLabel: onMaintenance == null
                ? null
                : context.tr('platformSettingsOpenMaintenance'),
            onAction: onMaintenance,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.dns_outlined,
                      size: 18, color: context.dukavo.textMuted),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    context.tr('platformSettingsRuntime'),
                    style: context.texts.labelLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.sm,
                children: [
                  _Metric(
                    label: context.tr('environment'),
                    value: summary.environment,
                  ),
                  _Metric(
                    label: context.tr('platformSettingsOverrides'),
                    value: '${summary.overrides}',
                  ),
                  _Metric(
                    label: context.tr('platformSettingsSecrets'),
                    value: '${summary.secretOverrides}',
                  ),
                  _Metric(
                    label: context.tr('platformSettingsDefinitions'),
                    value: '${summary.definitions}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: context.texts.labelSmall?.copyWith(
            color: context.dukavo.textMuted,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? '—' : value,
          style: context.texts.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
