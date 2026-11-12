import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/presentation/tenant_screens.dart';
import '../../notifications/application/notification_controller.dart';

/// The overflow workspace: everything that is not a primary tab.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentSessionProvider);
    final permissions = ref.watch(permissionsProvider);
    final unread = ref.watch(notificationUnreadProvider);

    final groups = <_MoreGroup>[
      _MoreGroup(
        titleKey: 'catalogue',
        entries: [
          _MoreEntry(
            labelKey: 'categories',
            icon: Icons.category_outlined,
            path: RoutePaths.categories,
            visible: permissions.canViewCategories,
          ),
          _MoreEntry(
            labelKey: 'inventory',
            icon: Icons.warehouse_outlined,
            path: RoutePaths.inventory,
            visible: permissions.canViewInventory,
          ),
          _MoreEntry(
            labelKey: 'inventoryTransfer',
            icon: Icons.swap_horiz_rounded,
            path: RoutePaths.inventoryTransfer,
            visible: permissions.canViewInventory,
          ),
        ],
      ),
      _MoreGroup(
        titleKey: 'storefrontGroup',
        entries: [
          _MoreEntry(
            labelKey: 'storefrontSettings',
            icon: Icons.storefront_outlined,
            path: RoutePaths.storefront,
            visible: permissions.canViewStorefront,
          ),
          _MoreEntry(
            labelKey: 'shippingZones',
            icon: Icons.local_shipping_outlined,
            path: RoutePaths.shippingZones,
            visible: permissions.canViewShipping,
          ),
          _MoreEntry(
            labelKey: 'paymentSettings',
            icon: Icons.payments_outlined,
            path: RoutePaths.paymentSettings,
            visible: permissions.canViewPayments,
          ),
          _MoreEntry(
            labelKey: 'payments',
            icon: Icons.receipt_long_outlined,
            path: RoutePaths.paymentConnections,
            visible: permissions.canViewPayments,
          ),
        ],
      ),
      _MoreGroup(
        titleKey: 'customers',
        entries: [
          _MoreEntry(
            labelKey: 'customers',
            icon: Icons.people_outline,
            path: RoutePaths.customers,
            visible: permissions.canViewCustomers,
          ),
        ],
      ),
      _MoreGroup(
        titleKey: 'insights',
        entries: [
          _MoreEntry(
            labelKey: 'analytics',
            icon: Icons.insights_outlined,
            path: RoutePaths.analytics,
            visible: permissions.canViewAnalytics,
          ),
          _MoreEntry(
            labelKey: 'profit',
            icon: Icons.trending_up_outlined,
            path: RoutePaths.profit,
            visible: permissions.canViewProfit,
          ),
          _MoreEntry(
            labelKey: 'inventoryIntelligence',
            icon: Icons.auto_graph_outlined,
            path: RoutePaths.inventoryIntelligence,
            visible: permissions.canViewInventory,
          ),
          _MoreEntry(
            labelKey: 'aiCopilot',
            icon: Icons.auto_awesome_outlined,
            path: RoutePaths.aiCopilot,
            visible: permissions.canUseAi,
          ),
          _MoreEntry(
            labelKey: 'aiInsights',
            icon: Icons.lightbulb_outline_rounded,
            path: RoutePaths.aiInsights,
            visible: permissions.canUseAi,
          ),
          _MoreEntry(
            labelKey: 'notifications',
            icon: Icons.notifications_none_outlined,
            path: RoutePaths.notifications,
            badge: unread,
          ),
        ],
      ),
      _MoreGroup(
        titleKey: 'growth',
        entries: [
          _MoreEntry(
            labelKey: 'recovery',
            icon: Icons.replay_outlined,
            path: RoutePaths.recovery,
            visible: permissions.canViewRecovery,
          ),
          _MoreEntry(
            labelKey: 'bundles',
            icon: Icons.inventory_2_outlined,
            path: RoutePaths.bundles,
            visible: permissions.canViewProducts,
          ),
          _MoreEntry(
            labelKey: 'aiActions',
            icon: Icons.auto_awesome_outlined,
            path: RoutePaths.aiActions,
            visible: permissions.canUseAi,
          ),
          _MoreEntry(
            labelKey: 'automations',
            icon: Icons.bolt_outlined,
            path: RoutePaths.automations,
            visible: permissions.canViewAutomation,
          ),
          _MoreEntry(
            labelKey: 'whatsapp',
            icon: Icons.chat_outlined,
            path: RoutePaths.whatsapp,
            visible: permissions.canViewWhatsapp,
          ),
          _MoreEntry(
            labelKey: 'integrations',
            icon: Icons.hub_outlined,
            path: RoutePaths.integrations,
            visible: permissions.canViewIntegrations,
          ),
        ],
      ),
      _MoreGroup(
        titleKey: 'workspace',
        entries: [
          _MoreEntry(
            labelKey: 'stores',
            icon: Icons.store_outlined,
            path: RoutePaths.stores,
            visible: permissions.canViewStores,
          ),
          _MoreEntry(
            labelKey: 'teamAndAccess',
            icon: Icons.groups_outlined,
            path: RoutePaths.team,
            visible: permissions.canViewUsers ||
                permissions.canViewRoles ||
                permissions.canViewAudit,
          ),
          _MoreEntry(
            labelKey: 'aiSettings',
            icon: Icons.smart_toy_outlined,
            path: RoutePaths.aiSettings,
            visible: permissions.canViewAiSettings,
          ),
        ],
      ),
      const _MoreGroup(
        titleKey: 'about',
        entries: [
          _MoreEntry(
            labelKey: 'helpCenter',
            icon: Icons.help_outline_rounded,
            path: RoutePaths.support,
          ),
          _MoreEntry(
            labelKey: 'aboutDukavo',
            icon: Icons.public_outlined,
            path: RoutePaths.home,
          ),
          _MoreEntry(
            labelKey: 'browseShop',
            icon: Icons.storefront_outlined,
            path: RoutePaths.shop,
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
      appBar: AppBar(title: Text(context.tr('more'))),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          _ProfileCard(
            name: session?.user.name ?? '',
            email: session?.user.email ?? '',
            avatarUrl: session?.user.avatarUrl,
            onSwitch: () => showTenantSwitcher(context, ref),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (session?.canUsePlatform ?? false) ...[
            AppCard(
              padding: EdgeInsets.zero,
              onTap: () async {
                final ok = await ref
                    .read(authControllerProvider.notifier)
                    .enterPlatformMode();
                if (!context.mounted) return;
                if (!ok) {
                  final message =
                      ref.read(authControllerProvider).errorMessage ??
                          context.tr('errorGeneric');
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(message)));
                  return;
                }
                context.go(RoutePaths.platformDashboard);
              },
              child: ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: context.scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Icon(
                    Icons.space_dashboard_outlined,
                    size: 20,
                    color: context.scheme.onPrimaryContainer,
                  ),
                ),
                title: Text(context.tr('platformConsole')),
                subtitle: Text(context.tr('platformOverview')),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          AppCard(
            padding: EdgeInsets.zero,
            onTap: () => showTenantSwitcher(context, ref),
            child: ListTile(
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: context.scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Icon(
                  Icons.storefront_outlined,
                  size: 20,
                  color: context.scheme.onPrimaryContainer,
                ),
              ),
              title: Text(context.tr('workspace')),
              subtitle: Text(
                session?.activeTenant?.name ?? context.tr('noStore'),
              ),
              trailing: const Icon(Icons.swap_horiz_rounded),
            ),
          ),
          for (final group in groups)
            if (group.entries.any((entry) => entry.visible)) ...[
              const SizedBox(height: AppSpacing.lg),
              AppListGroup(
                title: context.tr(group.titleKey),
                children: [
                  for (final entry in group.entries.where((e) => e.visible))
                    _MoreTile(entry: entry),
                ],
              ),
            ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: context.tr('logout'),
            icon: Icons.logout_rounded,
            variant: AppButtonVariant.outlined,
            expand: true,
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
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              'Dukavo 1.0.0',
              style: context.texts.labelSmall?.copyWith(
                color: context.dukavo.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.onSwitch,
  });

  final String name;
  final String email;
  final String? avatarUrl;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      tone: AppCardTone.low,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          AppAvatar(name: name.isEmpty ? '?' : name, url: avatarUrl, size: 56),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.texts.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: context.texts.bodySmall?.copyWith(
                    color: context.dukavo.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.tr('switchWorkspace'),
            onPressed: onSwitch,
            icon: const Icon(Icons.swap_horiz_rounded),
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({required this.entry});

  final _MoreEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: context.dukavo.surfaceLow,
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        child: Icon(
          entry.icon,
          size: 20,
          color: context.dukavo.textSecondary,
        ),
      ),
      title: Text(context.tr(entry.labelKey)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (entry.badge > 0)
            Badge(
              label: Text(entry.badge > 99 ? '99+' : '${entry.badge}'),
            ),
          const SizedBox(width: AppSpacing.xxs),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: context.dukavo.textMuted,
          ),
        ],
      ),
      onTap: () => context.push(entry.path),
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
    this.badge = 0,
  });

  final String labelKey;
  final IconData icon;
  final String path;
  final bool visible;
  final int badge;
}
