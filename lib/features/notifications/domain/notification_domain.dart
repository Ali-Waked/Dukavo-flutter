import '../../../core/api/paginated.dart';

/// The notification centre's wire model, mirroring `NotificationResource`.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.eventKey,
    required this.category,
    required this.severity,
    required this.title,
    required this.body,
    required this.read,
    this.actionUrl,
    this.params = const {},
    this.readAt,
    this.createdAt,
  });

  final String id;
  final String eventKey;
  final String category;
  final String severity;
  final String title;
  final String body;
  final String? actionUrl;
  final Map<String, dynamic> params;
  final bool read;
  final String? readAt;
  final String? createdAt;

  AppNotification copyWith({bool? read, String? readAt}) {
    return AppNotification(
      id: id,
      eventKey: eventKey,
      category: category,
      severity: severity,
      title: title,
      body: body,
      actionUrl: actionUrl,
      params: params,
      read: read ?? this.read,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
    );
  }
}

/// One channel's availability, as reported by the server.
class NotificationChannelAvailability {
  const NotificationChannelAvailability({
    required this.available,
    required this.label,
    this.reason,
  });

  final bool available;
  final String label;
  final String? reason;
}

abstract class NotificationRepository {
  Future<Paginated<AppNotification>> list({
    String status = 'all',
    String? category,
    String? severity,
    int page = 1,
    int perPage = 20,
  });

  Future<AppNotification> fetch(String id);

  Future<int> unreadCount();

  Future<AppNotification> markRead(String id);

  Future<AppNotification> markUnread(String id);

  Future<int> markAllRead();

  Future<void> dismiss(String id);

  Future<Map<String, NotificationChannelAvailability>> channelAvailability();
}
