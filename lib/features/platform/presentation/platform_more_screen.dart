import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/presentation/tenant_screens.dart';

/// Platform-only destinations that do not deserve a primary tab.
class PlatformMoreScreen extends ConsumerWidget {
  const PlatformMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentSessionProvider);
    final permissions = ref.watch(permissionsProvider);
    final theme = Theme.of(context);
    final tenantCount = session?.tenants.length ?? 0;

    final groups = <_MoreGroup>[
      _MoreGroup(
        titleKey: 'operations',
        entries: [
          _MoreEntry(
            labelKey: 'aiAdministration',
            icon: Icons.auto_awesome_outlined,
            path: RoutePaths.platformAiAdmin,
            visible: permissions.canViewAiAdmin,
          ),
          _MoreEntry(
            labelKey: 'paymentCatalogue',
            icon: Icons.account_balance_outlined,
            path: RoutePaths.platformPayments,
            visible: permissions.canViewPlatformPayments,
          ),
          _MoreEntry(
            labelKey: 'integrationHealth',
            icon: Icons.hub_outlined,
            path: RoutePaths.platformIntegrations,
            visible: permissions.canViewPlatformIntegrations,
          ),
          _MoreEntry(
            labelKey: 'notificationOperations',
            icon: Icons.notifications_active_outlined,
            path: RoutePaths.platformNotifications,
            visible: permissions.canViewNotifications,
          ),
          _MoreEntry(
            labelKey: 'automationTemplates',
            icon: Icons.bolt_outlined,
            path: RoutePaths.platformAutomationTemplates,
            visible: permissions.canViewAutomation,
          ),
        ],
      ),
      _MoreGroup(
        titleKey: 'configuration',
        entries: [
          _MoreEntry(
            labelKey: 'platformSettings',
            icon: Icons.tune_rounded,
            path: RoutePaths.platformSettings,
            visible: permissions.canViewPlatformSettings,
          ),
        ],
      ),
      _MoreGroup(
        titleKey: 'accessControl',
        entries: [
          _MoreEntry(
            labelKey: 'roles',
            icon: Icons.verified_user_outlined,
            path: RoutePaths.platformRoles,
            visible: permissions.canViewRoles,
          ),
          _MoreEntry(
            labelKey: 'auditLog',
            icon: Icons.history,
            path: RoutePaths.platformAudit,
            visible: permissions.canViewAudit,
          ),
        ],
      ),
      const _MoreGroup(
        titleKey: 'marketing',
        entries: [
          _MoreEntry(
            labelKey: 'pricingPlans',
            icon: Icons.sell_outlined,
            path: RoutePaths.platformPricing,
          ),
          _MoreEntry(
            labelKey: 'faqEntries',
            icon: Icons.help_outline,
            path: RoutePaths.platformFaq,
          ),
          _MoreEntry(
            labelKey: 'contentPages',
            icon: Icons.article_outlined,
            path: RoutePaths.platformContentPages,
          ),
          _MoreEntry(
            labelKey: 'newsletters',
            icon: Icons.newspaper_outlined,
            path: RoutePaths.platformNewsletters,
          ),
        ],
      ),
      const _MoreGroup(
        titleKey: 'account',
        entries: [
          _MoreEntry(
            labelKey: 'profile',
            icon: Icons.person_outline,
            path: RoutePaths.profile,
          ),
          _MoreEntry(
            labelKey: 'settings',
            icon: Icons.settings_outlined,
            path: RoutePaths.settings,
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('platformConsole'))),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  context.dukavo.primary.withValues(
                    alpha: context.isDark ? 0.24 : 0.10,
                  ),
                  context.dukavo.surface,
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.dukavo.border),
            ),
            child: Row(
              children: [
                AppAvatar(
                  name: session?.user.name ?? '?',
                  url: session?.user.avatarUrl,
                  size: 54,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session?.user.name ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        session?.user.email ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.dukavo.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (session?.user.isSuperAdmin ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: StatusChip(
                            status: 'active',
                            label: context.tr('superAdmin'),
                            compact: true,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (tenantCount > 0) ...[
            const SizedBox(height: AppSpacing.md),
            AppCard(
              onTap: () => showTenantSwitcher(context, ref),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: context.scheme.primary.withValues(
                        alpha: context.isDark ? 0.16 : 0.09,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.storefront_outlined,
                      size: 21,
                      color: context.scheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('merchantWorkspace'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          tenantCount == 1
                              ? session!.tenants.first.name
                              : '$tenantCount ${context.tr('workspaces')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.dukavo.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.dukavo.textMuted,
                  ),
                ],
              ),
            ),
          ],
          for (final group in groups)
            if (group.entries.any((entry) => entry.visible)) ...[
              const SizedBox(height: AppSpacing.lg),
              AppListGroup(
                title: context.tr(group.titleKey),
                children: [
                  for (final entry in group.entries.where((e) => e.visible))
                    ListTile(
                      leading: Icon(entry.icon, size: 21),
                      title: Text(context.tr(entry.labelKey)),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: context.dukavo.textMuted,
                      ),
                      onTap: () => context.push(entry.path),
                    ),
                ],
              ),
            ],
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: context.dukavo.danger,
              minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
            ),
            onPressed: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: context.tr('signOutConfirm'),
                message: context.tr('signOutMessage'),
                confirmLabel: context.tr('logout'),
                destructive: true,
              );
              if (confirmed) {
                await ref.read(authControllerProvider.notifier).logout();
              }
            },
            icon: const Icon(Icons.logout),
            label: Text(context.tr('logout')),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              'Dukavo 1.0.0',
              style: theme.textTheme.labelSmall?.copyWith(
                color: context.dukavo.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreGroup {
  const _MoreGroup({required this.titleKey, required this.entries});

  final String titleKey;
  final List<_MoreEntry> entries;
}

class _MoreEntry {
  const _MoreEntry({
    required this.labelKey,
    required this.icon,
    required this.path,
    this.visible = true,
  });

  final String labelKey;
  final IconData icon;
  final String path;
  final bool visible;
}
