import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/api/paginated.dart';
import '../domain/notification_domain.dart';

class NotificationModel {
  const NotificationModel({
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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawParams = json['params'];
    return NotificationModel(
      id: '${json['id'] ?? ''}',
      eventKey: '${json['event_key'] ?? ''}',
      category: '${json['category'] ?? ''}',
      severity: '${json['severity'] ?? 'info'}',
      title: '${json['title'] ?? ''}',
      body: '${json['body'] ?? ''}',
      actionUrl: json['action_url'] as String?,
      params: rawParams is Map
          ? Map<String, dynamic>.from(rawParams)
          : const <String, dynamic>{},
      read: json['read'] == true,
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  AppNotification toEntity() => AppNotification(
        id: id,
        eventKey: eventKey,
        category: category,
        severity: severity,
        title: title,
        body: body,
        actionUrl: actionUrl,
        params: params,
        read: read,
        readAt: readAt,
        createdAt: createdAt,
      );
}

class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Paginated<AppNotification>> list({
    String status = 'all',
    String? category,
    String? severity,
    int page = 1,
    int perPage = 20,
  }) {
    return _api.list<AppNotification>(
      ApiPaths.notifications,
      query: {
        'status': status,
        if (category != null && category.isNotEmpty) 'category': category,
        if (severity != null && severity.isNotEmpty) 'severity': severity,
        'page': page,
        'per_page': perPage,
      },
      item: (json) => NotificationModel.fromJson(json).toEntity(),
    );
  }

  Future<int> unreadCount() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.notificationsUnreadCount,
      decode: (raw) =>
          raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{},
    );
    final count = data['count'];
    if (count is int) return count;
    return int.tryParse('$count') ?? 0;
  }

  Future<AppNotification> markRead(String id) async {
    final data = await _api.post<Map<String, dynamic>>(
      '${ApiPaths.notifications}/$id/read',
      decode: (raw) =>
          raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{},
    );
    return NotificationModel.fromJson(data).toEntity();
  }

  Future<AppNotification> markUnread(String id) async {
    final data = await _api.post<Map<String, dynamic>>(
      '${ApiPaths.notifications}/$id/unread',
      decode: (raw) =>
          raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{},
    );
    return NotificationModel.fromJson(data).toEntity();
  }

  Future<int> markAllRead() async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.notificationsReadAll,
      decode: (raw) =>
          raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{},
    );
    final updated = data['updated'];
    if (updated is int) return updated;
    return int.tryParse('$updated') ?? 0;
  }

  Future<void> dismiss(String id) {
    return _api.delete('${ApiPaths.notifications}/$id');
  }

  Future<Map<String, NotificationChannelAvailability>> channelAvailability() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.profileNotificationChannels,
      decode: (raw) =>
          raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{},
    );

    final result = <String, NotificationChannelAvailability>{};
    data.forEach((key, value) {
      if (value is Map) {
        final map = Map<String, dynamic>.from(value);
        result[key] = NotificationChannelAvailability(
          available: map['available'] == true,
          label: '${map['label'] ?? key}',
          reason: map['reason'] as String?,
        );
      }
    });
    return result;
  }
}

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remote);

  final NotificationRemoteDataSource _remote;

  @override
  Future<Paginated<AppNotification>> list({
    String status = 'all',
    String? category,
    String? severity,
    int page = 1,
    int perPage = 20,
  }) {
    return _remote.list(
      status: status,
      category: category,
      severity: severity,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<int> unreadCount() => _remote.unreadCount();

  @override
  Future<AppNotification> markRead(String id) => _remote.markRead(id);

  @override
  Future<AppNotification> markUnread(String id) => _remote.markUnread(id);

  @override
  Future<int> markAllRead() => _remote.markAllRead();

  @override
  Future<void> dismiss(String id) => _remote.dismiss(id);

  @override
  Future<Map<String, NotificationChannelAvailability>> channelAvailability() =>
      _remote.channelAvailability();
}
