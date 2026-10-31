import '../../../core/api/paginated.dart';

/// The inbox, mirroring `ConversationResource`, `MessageResource` and the
/// summary endpoint.
class ConversationSummary {
  const ConversationSummary({
    required this.open,
    required this.pending,
    required this.unassigned,
    required this.unread,
  });

  final int open;
  final int pending;
  final int unassigned;
  final int unread;

  static const empty =
      ConversationSummary(open: 0, pending: 0, unassigned: 0, unread: 0);
}

class ConversationContact {
  const ConversationContact({
    required this.id,
    required this.name,
    this.email,
    this.phone,
  });

  final int id;
  final String name;
  final String? email;
  final String? phone;
}

class ConversationAssignee {
  const ConversationAssignee({required this.id, required this.name});

  final int id;
  final String name;
}

class ConversationLastMessage {
  const ConversationLastMessage({
    required this.id,
    required this.body,
    required this.direction,
    required this.isInternal,
    this.type,
    this.deliveryStatus,
    this.sentAt,
  });

  final int id;
  final String? body;
  final String direction;
  final bool isInternal;
  final String? type;
  final String? deliveryStatus;
  final String? sentAt;
}

class ReplyWindow {
  const ReplyWindow({
    required this.isOpen,
    required this.requiresTemplate,
    this.expiresAt,
  });

  final bool isOpen;
  final bool requiresTemplate;
  final String? expiresAt;
}

class Conversation {
  const Conversation({
    required this.id,
    required this.channel,
    required this.status,
    required this.unreadCount,
    required this.replyWindow,
    this.storeId,
    this.customerId,
    this.assignedTo,
    this.channelAccount,
    this.subject,
    this.displayName,
    this.phone,
    this.statusLabel,
    this.customer,
    this.assignee,
    this.lastMessage,
    this.messagesCount,
    this.lastMessageAt,
    this.lastInboundAt,
    this.closedAt,
    this.createdAt,
  });

  final int id;
  final int? storeId;
  final int? customerId;
  final int? assignedTo;
  final String channel;
  final String? channelAccount;
  final String? subject;
  final String? displayName;
  final String? phone;
  final String status;
  final String? statusLabel;
  final int unreadCount;
  final ReplyWindow replyWindow;
  final ConversationContact? customer;
  final ConversationAssignee? assignee;
  final ConversationLastMessage? lastMessage;
  final int? messagesCount;
  final String? lastMessageAt;
  final String? lastInboundAt;
  final String? closedAt;
  final String? createdAt;

  String get title => displayName ?? customer?.name ?? phone ?? '#$id';
}

class ConversationMessage {
  const ConversationMessage({
    required this.id,
    required this.conversationId,
    required this.direction,
    required this.type,
    required this.isInternal,
    this.userId,
    this.body,
    this.deliveryStatus,
    this.deliveryStatusLabel,
    this.failureReason,
    this.canRetry,
    this.attemptCount = 0,
    this.hasMedia = false,
    this.mediaFilename,
    this.authorName,
    this.sentAt,
    this.createdAt,
  });

  final int id;
  final int conversationId;
  final int? userId;
  final String direction;
  final String type;
  final bool isInternal;
  final String? body;
  final String? deliveryStatus;
  final String? deliveryStatusLabel;
  final String? failureReason;
  final bool? canRetry;
  final int attemptCount;
  final bool hasMedia;
  final String? mediaFilename;
  final String? authorName;
  final String? sentAt;
  final String? createdAt;

  bool get isInbound => direction == 'inbound';
  bool get isNote => isInternal || type == 'note';
  bool get isFailed => deliveryStatus == 'failed';
  String? get timestamp => sentAt ?? createdAt;
}

class ConversationDraft {
  const ConversationDraft({
    this.status,
    this.search,
    this.channel,
    this.mine = false,
    this.unassigned = false,
    this.unread = false,
  });

  final String? status;
  final String? search;
  final String? channel;
  final bool mine;
  final bool unassigned;
  final bool unread;
}

abstract class ConversationRepository {
  Future<Paginated<Conversation>> list({
    String? search,
    String? status,
    String? channel,
    bool mine = false,
    bool unassigned = false,
    bool unread = false,
    int page = 1,
    int perPage = 20,
  });

  Future<ConversationSummary> summary();

  Future<Conversation> get(int id);

  Future<Paginated<ConversationMessage>> messages(
    int id, {
    int page = 1,
    int perPage = 30,
  });

  Future<ConversationMessage> reply(int id, String body);

  Future<ConversationMessage> note(int id, String body);

  Future<ConversationMessage> template(
    int id, {
    required String templateName,
    required String languageCode,
    List<String> parameters = const [],
  });

  Future<ConversationMessage> retry(int id, int messageId);

  Future<Conversation> markRead(int id);

  Future<Conversation> assign(int id, int? userId);

  Future<Conversation> updateStatus(int id, String status);

  Future<List<ConversationAssignee>> assignees();
}
