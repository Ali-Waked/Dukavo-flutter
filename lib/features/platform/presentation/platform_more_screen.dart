import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';

/// Platform-only destinations that do not deserve a primary tab.
class PlatformMoreScreen extends ConsumerWidget {
  const PlatformMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentSessionProvider);
    final permissions = ref.watch(permissionsProvider);
    final theme = Theme.of(context);

    final groups = <_MoreGroup>[
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
          ),
          if (session?.hasTenant ?? false) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: Text(context.tr('merchantWorkspace')),
                subtitle: Text(session?.activeTenant?.name ?? ''),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(RoutePaths.dashboard),
              ),
            ),
          ],
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
                        trailing: const Icon(Icons.chevron_right),
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
  });

  final String labelKey;
  final IconData icon;
  final String path;
  final bool visible;
}
