import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/api/paginated.dart';
import '../../../core/pagination/paginated_notifier.dart';
import '../../../core/providers.dart';
import '../data/notification_data.dart';
import '../domain/notification_domain.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    NotificationRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

/// The list's filters. Changing one reloads from page one.
class NotificationFilters {
  const NotificationFilters({
    this.status = 'all',
    this.category,
    this.severity,
  });

  final String status;
  final String? category;
  final String? severity;

  NotificationFilters copyWith({
    String? status,
    String? category,
    String? severity,
    bool clearCategory = false,
    bool clearSeverity = false,
  }) {
    return NotificationFilters(
      status: status ?? this.status,
      category: clearCategory ? null : (category ?? this.category),
      severity: clearSeverity ? null : (severity ?? this.severity),
    );
  }
}

class NotificationInboxNotifier extends PaginatedNotifier<AppNotification> {
  NotificationInboxNotifier(this._repository, this._ref);

  final NotificationRepository _repository;
  final Ref _ref;

  NotificationFilters filters = const NotificationFilters();

  @override
  Future<Paginated<AppNotification>> fetchPage(int page) {
    return _repository.list(
      status: filters.status,
      category: filters.category,
      severity: filters.severity,
      page: page,
    );
  }

  Future<void> setStatus(String status) async {
    if (filters.status == status) return;
    filters = filters.copyWith(status: status);
    await reload();
  }

  Future<void> setCategory(String? category) async {
    filters = filters.copyWith(
      category: category,
      clearCategory: category == null,
    );
    await reload();
  }

  Future<void> setSeverity(String? severity) async {
    filters = filters.copyWith(
      severity: severity,
      clearSeverity: severity == null,
    );
    await reload();
  }

  Future<void> markRead(AppNotification notification) async {
    if (notification.read) return;
    try {
      final updated = await _repository.markRead(notification.id);
      _replace(updated);
    } on ApiException catch (error) {
      if (!error.isNetworkError) rethrow;
      // Read state is idempotent and safe to replay. Keep the UI truthful now
      // and let the sync manager send it when the connection returns.
      await _ref.read(offlineQueueProvider).enqueue(
            method: 'POST',
            path: '${ApiPaths.notifications}/${notification.id}/read',
          );
      _replace(notification.copyWith(read: true));
    }
    _ref.read(notificationUnreadProvider.notifier).decrement();
  }

  Future<void> markUnread(AppNotification notification) async {
    if (!notification.read) return;
    try {
      final updated = await _repository.markUnread(notification.id);
      _replace(updated);
    } on ApiException catch (error) {
      if (!error.isNetworkError) rethrow;
      await _ref.read(offlineQueueProvider).enqueue(
            method: 'POST',
            path: '${ApiPaths.notifications}/${notification.id}/unread',
          );
      _replace(notification.copyWith(read: false, readAt: ''));
    }
    _ref.read(notificationUnreadProvider.notifier).increment();
  }

  Future<void> markAllRead() async {
    try {
      await _repository.markAllRead();
    } on ApiException catch (error) {
      if (!error.isNetworkError) rethrow;
      await _ref.read(offlineQueueProvider).enqueue(
            method: 'POST',
            path: ApiPaths.notificationsReadAll,
          );
    }
    state = state.copyWith(
      items: state.items
          .map((item) => item.read ? item : item.copyWith(read: true))
          .toList(),
    );
    _ref.read(notificationUnreadProvider.notifier).set(0);
  }

  Future<void> dismiss(AppNotification notification) async {
    await _repository.dismiss(notification.id);
    state = state.copyWith(
      items: state.items.where((item) => item.id != notification.id).toList(),
      total: state.total > 0 ? state.total - 1 : 0,
    );
    if (!notification.read) {
      _ref.read(notificationUnreadProvider.notifier).decrement();
    }
  }

  /// Fold a change made outside the list (the detail screen) into the page.
  void replaceNotification(AppNotification updated) {
    _replace(updated);
  }

  /// Remove a notification dismissed from its detail screen.
  void removeNotification(String id) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
      total: state.total > 0 ? state.total - 1 : 0,
    );
  }

  void _replace(AppNotification updated) {
    state = state.copyWith(
      items: state.items
          .map((item) => item.id == updated.id ? updated : item)
          .toList(),
    );
  }
}

final notificationInboxProvider = StateNotifierProvider<
    NotificationInboxNotifier, PaginatedState<AppNotification>>((ref) {
  final notifier = NotificationInboxNotifier(
    ref.watch(notificationRepositoryProvider),
    ref,
  );
  refreshOnReconnect(ref, notifier.reload);
  return notifier;
});

/// The unread badge. Refreshed on boot, on pull-to-refresh and after mutations.
class UnreadCountNotifier extends StateNotifier<int> {
  UnreadCountNotifier(this._repository) : super(0);

  final NotificationRepository _repository;

  Future<void> refresh() async {
    try {
      state = await _repository.unreadCount();
    } catch (_) {
      // A badge is not worth an error screen; the list reports failures.
    }
  }

  void set(int value) => state = value;

  void increment([int by = 1]) => state = (state + by).clamp(0, 9999).toInt();

  void decrement([int by = 1]) => state = (state - by).clamp(0, 9999).toInt();
}

final notificationUnreadProvider =
    StateNotifierProvider<UnreadCountNotifier, int>((ref) {
  final notifier =
      UnreadCountNotifier(ref.watch(notificationRepositoryProvider));
  notifier.refresh();
  return notifier;
});
