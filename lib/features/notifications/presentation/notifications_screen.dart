import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../application/notification_controller.dart';
import '../domain/notification_domain.dart';

/// The notification centre: personal to the account, never tenant scoped.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationInboxProvider.notifier).loadInitial();
      ref.read(notificationUnreadProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationInboxProvider);
    final notifier = ref.read(notificationInboxProvider.notifier);
    final unread = ref.watch(notificationUnreadProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('notificationCenter')),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () async {
                await notifier.markAllRead();
                if (context.mounted) {
                  AppSnack.show(context, context.tr('allNotificationsRead'));
                }
              },
              child: Text(context.tr('markAllRead')),
            ),
        ],
      ),
      body: Column(
        children: [
          _StatusFilters(
            selected: notifier.filters.status,
            onChanged: (value) async {
              await notifier.setStatus(value);
              if (mounted) setState(() {});
            },
          ),
          _CategorySeverityFilters(
            category: notifier.filters.category,
            severity: notifier.filters.severity,
            onCategoryChanged: (value) async {
              await notifier.setCategory(value);
              if (mounted) setState(() {});
            },
            onSeverityChanged: (value) async {
              await notifier.setSeverity(value);
              if (mounted) setState(() {});
            },
          ),
          Expanded(
            child: PagedListView<AppNotification>(
              state: state,
              onRefresh: () async {
                await notifier.reload();
                await ref.read(notificationUnreadProvider.notifier).refresh();
              },
              onLoadMore: notifier.loadMore,
              empty: EmptyState(
                title: context.tr('noNotifications'),
                icon: Icons.notifications_none_outlined,
              ),
              itemBuilder: (context, item, index) {
                return _NotificationTile(
                  notification: item,
                  onTap: () {
                    // The detail screen marks it read and folds that state back
                    // into this list, so tapping twice cannot double-count.
                    context.push(
                      RoutePaths.notificationDetail(item.id),
                      extra: item,
                    );
                  },
                  onToggleRead: () async {
                    if (item.read) {
                      await notifier.markUnread(item);
                    } else {
                      await notifier.markRead(item);
                    }
                  },
                  onDismiss: () async {
                    await notifier.dismiss(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = <String, String>{
      'all': 'all',
      'unread': 'unreadOnly',
      'read': 'readOnlyFilter',
    };

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: options.entries.map((entry) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(
              label: Text(context.tr(entry.value)),
              selected: selected == entry.key,
              onSelected: (_) => onChanged(entry.key),
            ),
          );
        }).toList(),
      ),
    );
  }
}

const _notificationCategories = <String>[
  'orders',
  'inventory',
  'messages',
  'customers',
  'billing',
  'ai',
  'approvals',
  'security',
  'reports',
  'announcements',
  'team',
];

const _notificationSeverities = <String>[
  'info',
  'success',
  'warning',
  'critical',
];

String _categoryLabel(BuildContext context, String value) {
  return switch (value) {
    'orders' => context.tr('categoryOrders'),
    'inventory' => context.tr('categoryInventory'),
    'messages' || 'conversations' => context.tr('categoryMessages'),
    'customers' => context.tr('categoryCustomers'),
    'billing' => context.tr('categoryBilling'),
    'ai' => context.tr('categoryAi'),
    'approvals' => context.tr('categoryApprovals'),
    'security' => context.tr('categorySecurity'),
    'reports' => context.tr('categoryReports'),
    'announcements' => context.tr('categoryAnnouncements'),
    'team' => context.tr('categoryTeam'),
    _ => value,
  };
}

String _severityLabel(BuildContext context, String value) {
  return switch (value) {
    'success' => context.tr('severitySuccess'),
    'warning' => context.tr('severityWarning'),
    'critical' => context.tr('severityCritical'),
    _ => context.tr('severityInfo'),
  };
}

class _CategorySeverityFilters extends StatelessWidget {
  const _CategorySeverityFilters({
    required this.category,
    required this.severity,
    required this.onCategoryChanged,
    required this.onSeverityChanged,
  });

  final String? category;
  final String? severity;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onSeverityChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: category ?? '',
              isExpanded: true,
              underline: const SizedBox.shrink(),
              hint: Text(context.tr('categoryFilter')),
              items: [
                DropdownMenuItem(
                  value: '',
                  child: Text(context.tr('allCategories')),
                ),
                for (final value in _notificationCategories)
                  DropdownMenuItem(
                    value: value,
                    child: Text(_categoryLabel(context, value)),
                  ),
              ],
              onChanged: (value) => onCategoryChanged(
                  value == null || value.isEmpty ? null : value),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String>(
              value: severity ?? '',
              isExpanded: true,
              underline: const SizedBox.shrink(),
              hint: Text(context.tr('severity')),
              items: [
                DropdownMenuItem(
                  value: '',
                  child: Text(context.tr('allSeverities')),
                ),
                for (final value in _notificationSeverities)
                  DropdownMenuItem(
                    value: value,
                    child: Text(_severityLabel(context, value)),
                  ),
              ],
              onChanged: (value) => onSeverityChanged(
                  value == null || value.isEmpty ? null : value),
            ),
          ),
          if (category != null || severity != null)
            IconButton(
              tooltip: context.tr('filters'),
              onPressed: () {
                onCategoryChanged(null);
                onSeverityChanged(null);
              },
              icon: const Icon(Icons.filter_alt_off_outlined),
            ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onToggleRead,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onToggleRead;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final unread = !notification.read;
    final accent = _severityColor(notification.severity, context.dukavo);

    return Dismissible(
      key: ValueKey('notification-${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 20),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
      ),
      onDismissed: (_) => onDismiss(),
      child: Material(
        color: unread ? scheme.surface : scheme.surface.withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: unread ? accent.withValues(alpha: 0.35) : scheme.outline,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          onLongPress: onToggleRead,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_categoryIcon(notification.category),
                      size: 20, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight:
                                    unread ? FontWeight.w700 : FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unread) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: context.dukavo.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          StatusChip(
                            status: notification.severity,
                            compact: true,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            Formatters.relative(notification.createdAt),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _categoryIcon(String category) {
    switch (category) {
      case 'orders':
        return Icons.receipt_long_outlined;
      case 'inventory':
        return Icons.inventory_2_outlined;
      case 'messages':
      case 'conversations':
        return Icons.chat_bubble_outline;
      case 'customers':
        return Icons.people_outline;
      case 'billing':
        return Icons.credit_card_outlined;
      case 'security':
        return Icons.shield_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  static Color _severityColor(String severity, DukavoColors colors) {
    switch (severity) {
      case 'success':
        return colors.success;
      case 'warning':
        return colors.warning;
      case 'critical':
        return colors.danger;
      default:
        return colors.info;
    }
  }
}
