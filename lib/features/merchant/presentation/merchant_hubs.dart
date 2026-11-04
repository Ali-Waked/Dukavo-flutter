import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';

class _HubEntry {
  const _HubEntry({
    required this.labelKey,
    required this.descriptionKey,
    required this.icon,
    required this.path,
    this.visible = true,
  });

  final String labelKey;
  final String descriptionKey;
  final IconData icon;
  final String path;
  final bool visible;
}

/// The people and governance hub: team, roles and the audit trail.
class MerchantTeamHubScreen extends ConsumerWidget {
  const MerchantTeamHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);
    final theme = Theme.of(context);
    final entries = <_HubEntry>[
      _HubEntry(
        labelKey: 'teamMembers',
        descriptionKey: 'teamMembersHint',
        icon: Icons.people_outline,
        path: RoutePaths.teamMembers,
        visible: permissions.canViewUsers,
      ),
      _HubEntry(
        labelKey: 'roles',
        descriptionKey: 'rolesHint',
        icon: Icons.verified_user_outlined,
        path: RoutePaths.teamRoles,
        visible: permissions.canViewRoles,
      ),
      _HubEntry(
        labelKey: 'auditLog',
        descriptionKey: 'auditLogHint',
        icon: Icons.history,
        path: RoutePaths.audit,
        visible: permissions.canViewAudit,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('teamAndAccess'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SectionCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.groups_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('teamHub'),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('teamHubHint'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final entry in entries.where((entry) => entry.visible))
                  ListTile(
                    leading: Icon(entry.icon),
                    title: Text(context.tr(entry.labelKey)),
                    subtitle: Text(context.tr(entry.descriptionKey)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(entry.path),
                  ),
              ],
            ),
          ),
          if (permissions.canManageUsers) ...[
            const SizedBox(height: 16),
            AppButton(
              label: context.tr('inviteTeamMember'),
              icon: Icons.person_add_alt_1_outlined,
              expand: true,
              onPressed: () => context.push(RoutePaths.createUser),
            ),
          ],
        ],
      ),
    );
  }
}

/// Automation rules, their execution history and the human task queue.
class MerchantAutomationHubScreen extends ConsumerWidget {
  const MerchantAutomationHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);
    final theme = Theme.of(context);
    final entries = <_HubEntry>[
      _HubEntry(
        labelKey: 'automationRules',
        descriptionKey: 'automationRulesHint',
        icon: Icons.bolt_outlined,
        path: RoutePaths.automationRules,
        visible: permissions.canViewAutomation,
      ),
      _HubEntry(
        labelKey: 'automationRuns',
        descriptionKey: 'automationRunsHint',
        icon: Icons.play_circle_outline,
        path: RoutePaths.automationRuns,
        visible: permissions.canViewAutomation,
      ),
      _HubEntry(
        labelKey: 'automationTasks',
        descriptionKey: 'automationTasksHint',
        icon: Icons.task_alt_outlined,
        path: RoutePaths.automationTasks,
        visible: permissions.canViewAutomation,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('automations'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SectionCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.bolt_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('automationHub'),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('automationHubHint'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final entry in entries.where((entry) => entry.visible))
                  ListTile(
                    leading: Icon(entry.icon),
                    title: Text(context.tr(entry.labelKey)),
                    subtitle: Text(context.tr(entry.descriptionKey)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(entry.path),
                  ),
              ],
            ),
          ),
          if (permissions.canManageAutomation) ...[
            const SizedBox(height: 16),
            AppButton(
              label: context.tr('createAutomation'),
              icon: Icons.add,
              expand: true,
              onPressed: () => context.push(RoutePaths.createAutomation),
            ),
          ],
        ],
      ),
    );
  }
}
