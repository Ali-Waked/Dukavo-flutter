import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/api/paginated.dart';
import '../domain/conversation_domain.dart';

class ConversationModel {
  const ConversationModel({required this.conversation});

  final Conversation conversation;

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final rawCustomer = json['customer'];
    final rawAssignee = json['assignee'];
    final rawLast = json['last_message'];
    final rawWindow = json['reply_window'];

    return ConversationModel(
      conversation: Conversation(
        id: _int(json['id']),
        storeId: _nullableInt(json['store_id']),
        customerId: _nullableInt(json['customer_id']),
        assignedTo: _nullableInt(json['assigned_to']),
        channel: '${json['channel'] ?? 'web'}',
        channelAccount: json['channel_account'] as String?,
        subject: json['subject'] as String?,
        displayName: json['display_name'] as String?,
        phone: json['phone'] as String?,
        status: '${json['status'] ?? 'open'}',
        statusLabel: json['status_label'] as String?,
        unreadCount: _int(json['unread_count']),
        replyWindow: rawWindow is Map
            ? ReplyWindow(
                isOpen: rawWindow['is_open'] != false,
                requiresTemplate: rawWindow['requires_template'] == true,
                expiresAt: rawWindow['expires_at'] as String?,
              )
            : const ReplyWindow(isOpen: true, requiresTemplate: false),
        customer: rawCustomer is Map
            ? ConversationContact(
                id: _int(rawCustomer['id']),
                name: '${rawCustomer['name'] ?? ''}',
                email: rawCustomer['email'] as String?,
                phone: rawCustomer['phone'] as String?,
              )
            : null,
        assignee: rawAssignee is Map
            ? ConversationAssignee(
                id: _int(rawAssignee['id']),
                name: '${rawAssignee['name'] ?? ''}',
              )
            : null,
        lastMessage: rawLast is Map
            ? ConversationLastMessage(
                id: _int(rawLast['id']),
                body: rawLast['body'] as String?,
                direction: '${rawLast['direction'] ?? 'inbound'}',
                isInternal: rawLast['is_internal'] == true,
                type: rawLast['type'] as String?,
                deliveryStatus: rawLast['delivery_status'] as String?,
                sentAt: rawLast['sent_at'] as String?,
              )
            : null,
        messagesCount: _nullableInt(json['messages_count']),
        lastMessageAt: json['last_message_at'] as String?,
        lastInboundAt: json['last_inbound_at'] as String?,
        closedAt: json['closed_at'] as String?,
        createdAt: json['created_at'] as String?,
      ),
    );
  }

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static int? _nullableInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }
}

class MessageModel {
  const MessageModel({required this.message});

  final ConversationMessage message;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final rawAuthor = json['author'];
    final rawMedia = json['media'];
    return MessageModel(
      message: ConversationMessage(
        id: ConversationModel._int(json['id']),
        conversationId: ConversationModel._int(json['conversation_id']),
        userId: ConversationModel._nullableInt(json['user_id']),
        direction: '${json['direction'] ?? 'inbound'}',
        type: '${json['type'] ?? 'text'}',
        isInternal: json['is_internal'] == true,
        body: json['body'] as String?,
        deliveryStatus: json['delivery_status'] as String?,
        deliveryStatusLabel: json['delivery_status_label'] as String?,
        failureReason:
            (json['delivery_error'] ?? json['failure_reason']) as String?,
        canRetry: json['can_retry'] is bool ? json['can_retry'] as bool : null,
        attemptCount: ConversationModel._int(json['attempt_count']),
        hasMedia: rawMedia is Map,
        mediaFilename: rawMedia is Map ? rawMedia['filename'] as String? : null,
        authorName: rawAuthor is Map ? '${rawAuthor['name'] ?? ''}' : null,
        sentAt: json['sent_at'] as String?,
        createdAt: json['created_at'] as String?,
      ),
    );
  }
}

class ConversationRemoteDataSource {
  ConversationRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Paginated<Conversation>> list({
    String? search,
    String? status,
    String? channel,
    bool mine = false,
    bool unassigned = false,
    bool unread = false,
    int page = 1,
    int perPage = 20,
  }) {
    return _api.list<Conversation>(
      ApiPaths.conversations,
      query: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.isNotEmpty) 'status': status,
        if (channel != null && channel.isNotEmpty) 'channel': channel,
        if (mine) 'mine': 1,
        if (unassigned) 'unassigned': 1,
        if (unread) 'unread': 1,
      },
      item: (json) => ConversationModel.fromJson(json).conversation,
    );
  }

  Future<ConversationSummary> summary() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.conversationsSummary,
      decode: _asMap,
    );
    return ConversationSummary(
      open: ConversationModel._int(data['open']),
      pending: ConversationModel._int(data['pending']),
      unassigned: ConversationModel._int(data['unassigned']),
      unread: ConversationModel._int(data['unread']),
    );
  }

  Future<Conversation> get(int id) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.conversation(id),
      decode: _asMap,
    );
    return ConversationModel.fromJson(data).conversation;
  }

  Future<Paginated<ConversationMessage>> messages(
    int id, {
    int page = 1,
    int perPage = 30,
  }) {
    return _api.list<ConversationMessage>(
      ApiPaths.conversationMessages(id),
      query: {'page': page, 'per_page': perPage},
      item: (json) => MessageModel.fromJson(json).message,
    );
  }

  Future<ConversationMessage> reply(int id, String body) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.conversationMessages(id),
      body: {'body': body},
      decode: _asMap,
    );
    return MessageModel.fromJson(data).message;
  }

  Future<ConversationMessage> note(int id, String body) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.conversationNotes(id),
      body: {'body': body},
      decode: _asMap,
    );
    return MessageModel.fromJson(data).message;
  }

  Future<ConversationMessage> template(
    int id, {
    required String templateName,
    required String languageCode,
    List<String> parameters = const [],
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.conversationTemplates(id),
      body: {
        'template_name': templateName,
        'language_code': languageCode,
        if (parameters.isNotEmpty) 'parameters': parameters,
      },
      decode: _asMap,
    );
    return MessageModel.fromJson(data).message;
  }

  Future<ConversationMessage> retry(int id, int messageId) async {
    final data = await _api.post<Map<String, dynamic>>(
      '${ApiPaths.conversationMessages(id)}/$messageId/retry',
      decode: _asMap,
    );
    return MessageModel.fromJson(data).message;
  }

  Future<Conversation> markRead(int id) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.conversationRead(id),
      decode: _asMap,
    );
    return ConversationModel.fromJson(data).conversation;
  }

  Future<Conversation> assign(int id, int? userId) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.conversationAssign(id),
      body: {'user_id': userId},
      decode: _asMap,
    );
    return ConversationModel.fromJson(data).conversation;
  }

  Future<Conversation> updateStatus(int id, String status) async {
    final data = await _api.patch<Map<String, dynamic>>(
      ApiPaths.conversation(id),
      body: {'status': status},
      decode: _asMap,
    );
    return ConversationModel.fromJson(data).conversation;
  }

  Future<List<ConversationAssignee>> assignees() async {
    final data = await _api.get<List<dynamic>>(
      ApiPaths.conversationsAssignees,
      decode: (raw) => raw is List ? raw : const <dynamic>[],
    );
    return data
        .whereType<Map>()
        .map(
          (entry) => ConversationAssignee(
            id: ConversationModel._int(entry['id']),
            name: '${entry['name'] ?? ''}',
          ),
        )
        .toList();
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}

class ConversationRepositoryImpl implements ConversationRepository {
  ConversationRepositoryImpl(this._remote);

  final ConversationRemoteDataSource _remote;

  @override
  Future<Paginated<Conversation>> list({
    String? search,
    String? status,
    String? channel,
    bool mine = false,
    bool unassigned = false,
    bool unread = false,
    int page = 1,
    int perPage = 20,
  }) {
    return _remote.list(
      search: search,
      status: status,
      channel: channel,
      mine: mine,
      unassigned: unassigned,
      unread: unread,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<ConversationSummary> summary() => _remote.summary();

  @override
  Future<Conversation> get(int id) => _remote.get(id);

  @override
  Future<Paginated<ConversationMessage>> messages(
    int id, {
    int page = 1,
    int perPage = 30,
  }) {
    return _remote.messages(id, page: page, perPage: perPage);
  }

  @override
  Future<ConversationMessage> reply(int id, String body) =>
      _remote.reply(id, body);

  @override
  Future<ConversationMessage> note(int id, String body) =>
      _remote.note(id, body);

  @override
  Future<ConversationMessage> template(
    int id, {
    required String templateName,
    required String languageCode,
    List<String> parameters = const [],
  }) {
    return _remote.template(
      id,
      templateName: templateName,
      languageCode: languageCode,
      parameters: parameters,
    );
  }

  @override
  Future<ConversationMessage> retry(int id, int messageId) =>
      _remote.retry(id, messageId);

  @override
  Future<Conversation> markRead(int id) => _remote.markRead(id);

  @override
  Future<Conversation> assign(int id, int? userId) =>
      _remote.assign(id, userId);

  @override
  Future<Conversation> updateStatus(int id, String status) =>
      _remote.updateStatus(id, status);

  @override
  Future<List<ConversationAssignee>> assignees() => _remote.assignees();
}
