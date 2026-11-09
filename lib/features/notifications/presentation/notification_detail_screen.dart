import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../application/notification_controller.dart';
import '../application/push_service.dart';
import '../domain/notification_domain.dart';

/// A single notification, opened from the list or from a push tap.
///
/// The body is read from Laravel, not from the push payload. A cold-start deep
/// link therefore fetches the record by id, marks it read once and shows the
/// same message the centre would.
class NotificationDetailScreen extends ConsumerStatefulWidget {
  const NotificationDetailScreen({
    super.key,
    required this.id,
    this.initial,
  });

  final String id;
  final AppNotification? initial;

  @override
  ConsumerState<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends ConsumerState<NotificationDetailScreen> {
  AppNotification? _notification;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _notification = widget.initial;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initial == null) {
        _load();
      } else {
        _markReadIfNeeded(widget.initial!);
      }
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final loaded =
          await ref.read(notificationRepositoryProvider).fetch(widget.id);

      if (!mounted) return;
      setState(() {
        _notification = loaded;
        _loading = false;
      });
      await _markReadIfNeeded(loaded);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _markReadIfNeeded(AppNotification notification) async {
    if (notification.read) return;

    try {
      final updated = await ref
          .read(notificationRepositoryProvider)
          .markRead(notification.id);

      if (!mounted) return;
      setState(() => _notification = updated);
      ref.read(notificationUnreadProvider.notifier).decrement();
      ref.read(notificationInboxProvider.notifier).replaceNotification(updated);
    } catch (_) {
      // Viewing the detail is still useful if the read call fails.
    }
  }

  Future<void> _toggleRead() async {
    final notification = _notification;
    if (notification == null) return;

    try {
      final repository = ref.read(notificationRepositoryProvider);
      final updated = notification.read
          ? await repository.markUnread(notification.id)
          : await repository.markRead(notification.id);

      if (!mounted) return;
      setState(() => _notification = updated);
      ref.read(notificationInboxProvider.notifier).replaceNotification(updated);

      if (updated.read) {
        ref.read(notificationUnreadProvider.notifier).decrement();
      } else {
        ref.read(notificationUnreadProvider.notifier).increment();
      }
    } catch (error) {
      if (mounted) AppSnack.show(context, error.toString(), isError: true);
    }
  }

  Future<void> _delete() async {
    final notification = _notification;
    if (notification == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('delete')),
        content: Text(context.tr('deleteNotificationConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(notificationRepositoryProvider).dismiss(notification.id);

      if (!mounted) return;
      ref
          .read(notificationInboxProvider.notifier)
          .removeNotification(notification.id);

      if (!notification.read) {
        ref.read(notificationUnreadProvider.notifier).decrement();
      }

      AppSnack.show(context, context.tr('notificationDeleted'));
      context.go(RoutePaths.notifications);
    } catch (error) {
      if (mounted) AppSnack.show(context, error.toString(), isError: true);
    }
  }

  void _openRelated(AppNotification notification) {
    final path = resolveNotificationPath(
      notification.actionUrl,
      notificationId: notification.id,
    );

    if (path == RoutePaths.notificationDetail(notification.id)) {
      return;
    }

    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final notification = _notification;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('notificationDetail')),
        actions: [
          if (notification != null)
            IconButton(
              tooltip: notification.read
                  ? context.tr('markAsUnread')
                  : context.tr('markAsRead'),
              onPressed: _toggleRead,
              icon: Icon(
                notification.read
                    ? Icons.mark_email_unread_outlined
                    : Icons.mark_email_read_outlined,
              ),
            ),
          if (notification != null)
            IconButton(
              tooltip: context.tr('delete'),
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: _buildBody(context, notification),
    );
  }

  Widget _buildBody(BuildContext context, AppNotification? notification) {
    if (_loading && notification == null) {
      return const LoadingView();
    }

    if (_error != null && notification == null) {
      return ErrorView(message: _error!, onRetry: _load);
    }

    if (notification == null) {
      return EmptyState(
        title: context.tr('notificationNotFound'),
        icon: Icons.notifications_off_outlined,
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasAction =
        notification.actionUrl != null && notification.actionUrl!.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            StatusChip(status: notification.severity, compact: true),
            const SizedBox(width: 8),
            StatusChip(status: notification.category, compact: true),
            const Spacer(),
            if (!notification.read)
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: context.dukavo.accent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          notification.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          Formatters.dateTime(notification.createdAt),
          style: theme.textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        SelectableText(
          notification.body,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
        ),
        if (hasAction) ...[
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () => _openRelated(notification),
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(context.tr('openRelated')),
          ),
        ],
        const SizedBox(height: 32),
        Text(
          notification.eventKey.replaceAll('_', ' '),
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
