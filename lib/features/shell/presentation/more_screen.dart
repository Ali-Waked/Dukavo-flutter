import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/auth/permissions.dart';
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
    final theme = Theme.of(context);

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
            labelKey: 'notifications',
            icon: Icons.notifications_none_outlined,
            path: RoutePaths.notifications,
            badge: unread,
          ),
        ],
      ),
      _MoreGroup(
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  AppAvatar(
                    name: session?.user.name ?? '?',
                    url: session?.user.avatarUrl,
                    size: 52,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session?.user.name ?? '',
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          session?.user.email ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('switchWorkspace'),
                    onPressed: () => showTenantSwitcher(context, ref),
                    icon: const Icon(Icons.swap_horiz),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: Text(context.tr('workspace')),
              subtitle: Text(session?.activeTenant?.name ?? context.tr('noStore')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showTenantSwitcher(context, ref),
            ),
          ),
          for (final group in groups)
            if (group.entries.any((entry) => entry.visible)) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
                child: Text(
                  context.tr(group.titleKey),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final entry in group.entries.where((e) => e.visible))
                      ListTile(
                        leading: Icon(entry.icon),
                        title: Text(context.tr(entry.labelKey)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (entry.badge > 0)
                              Badge(
                                label: Text(
                                  entry.badge > 99 ? '99+' : '${entry.badge}',
                                ),
                              ),
                            const SizedBox(width: 6),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () => context.push(entry.path),
                      ),
                  ],
                ),
              ),
            ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
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
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Dukavo 1.0.0',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
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
    this.badge = 0,
  });

  final String labelKey;
  final IconData icon;
  final String path;
  final bool visible;
  final int badge;
}
