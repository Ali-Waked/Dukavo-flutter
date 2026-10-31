import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
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
                  onTap: () async {
                    if (!item.read) {
                      await notifier.markRead(item);
                    }
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
    final accent = _severityColor(notification.severity, scheme);

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
                  child: Icon(_categoryIcon(notification.category), size: 20, color: accent),
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
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
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

  static Color _severityColor(String severity, ColorScheme scheme) {
    switch (severity) {
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'critical':
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }
}
