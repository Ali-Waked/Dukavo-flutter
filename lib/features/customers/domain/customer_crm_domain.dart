/// Customer CRM models, mirroring `CustomerCrmController`,
/// `CustomerMemoryController` and their resources.
library;

import 'customer_domain.dart';

class CustomerStats {
  const CustomerStats({
    required this.ordersCount,
    required this.paidOrdersCount,
    required this.totalSpent,
    required this.averageOrderValue,
    this.currency,
    this.lastOrderAt,
    this.lastInteractionAt,
  });

  final int ordersCount;
  final int paidOrdersCount;
  final num totalSpent;
  final num averageOrderValue;
  final String? currency;
  final String? lastOrderAt;
  final String? lastInteractionAt;

  static CustomerStats fromJson(Map<String, dynamic> json) {
    return CustomerStats(
      ordersCount: _int(json['orders_count']),
      paidOrdersCount: _int(json['paid_orders_count']),
      totalSpent: _num(json['total_spent']),
      averageOrderValue: _num(json['average_order_value']),
      currency: json['currency']?.toString(),
      lastOrderAt: json['last_order_at']?.toString(),
      lastInteractionAt: json['last_interaction_at']?.toString(),
    );
  }
}

class CustomerSummary {
  const CustomerSummary({
    required this.id,
    required this.summary,
    this.highlights = const [],
    this.risks = const [],
    this.opportunities = const [],
    this.model,
    this.isEdited = false,
    this.generatedBy,
    this.editedBy,
    this.editedAt,
    this.refreshedAt,
  });

  final int id;
  final String summary;
  final List<String> highlights;
  final List<String> risks;
  final List<String> opportunities;
  final String? model;
  final bool isEdited;
  final String? generatedBy;
  final String? editedBy;
  final String? editedAt;
  final String? refreshedAt;

  bool get isEmpty =>
      summary.trim().isEmpty &&
      highlights.isEmpty &&
      risks.isEmpty &&
      opportunities.isEmpty;

  static CustomerSummary fromJson(Map<String, dynamic> json) {
    return CustomerSummary(
      id: _int(json['id']),
      summary: '${json['summary'] ?? ''}',
      highlights: _stringList(json['highlights']),
      risks: _stringList(json['risks']),
      opportunities: _stringList(json['opportunities']),
      model: json['model']?.toString(),
      isEdited: json['is_edited'] == true,
      generatedBy: _personName(json['generated_by']),
      editedBy: _personName(json['edited_by']),
      editedAt: json['edited_at']?.toString(),
      refreshedAt: json['refreshed_at']?.toString(),
    );
  }
}

class CustomerCrmOverview {
  const CustomerCrmOverview({
    required this.customer,
    required this.stats,
    required this.summary,
    this.lastInteractionAt,
  });

  final Customer customer;
  final CustomerStats stats;
  final CustomerSummary summary;
  final String? lastInteractionAt;

  static CustomerCrmOverview fromJson(
    Map<String, dynamic> json,
    Customer customer,
  ) {
    final rawStats = json['stats'];
    final rawSummary = json['summary'];
    return CustomerCrmOverview(
      customer: customer,
      stats: CustomerStats.fromJson(
        rawStats is Map ? Map<String, dynamic>.from(rawStats) : const {},
      ),
      summary: CustomerSummary.fromJson(
        rawSummary is Map ? Map<String, dynamic>.from(rawSummary) : const {},
      ),
      lastInteractionAt: json['last_interaction_at']?.toString(),
    );
  }
}

/// One entry in the customer's merged order/conversation timeline.
class CustomerTimelineEntry {
  const CustomerTimelineEntry({
    required this.id,
    required this.type,
    required this.data,
    this.timestamp,
  });

  final String id;
  final String type;
  final DateTime? timestamp;
  final Map<String, dynamic> data;

  bool get isOrder => type == 'order';
  bool get isConversation => type == 'conversation';

  String? get orderNumber => data['order_number']?.toString();
  String? get orderStatus => data['status']?.toString();
  String? get currency => data['currency']?.toString();
  num? get grandTotal => data['grand_total'] is num
      ? data['grand_total'] as num
      : num.tryParse('${data['grand_total']}');
  int? get itemCount => data['item_count'] is num
      ? (data['item_count'] as num).toInt()
      : int.tryParse('${data['item_count']}');

  String? get conversationSubject => data['subject']?.toString();
  String? get conversationDisplayName => data['display_name']?.toString();
  String? get conversationChannel => data['channel']?.toString();
  int? get conversationId => data['conversation_id'] is num
      ? (data['conversation_id'] as num).toInt()
      : int.tryParse('${data['conversation_id']}');

  static CustomerTimelineEntry fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return CustomerTimelineEntry(
      id: '${json['id'] ?? ''}',
      type: '${json['type'] ?? ''}',
      timestamp: _date(json['timestamp']),
      data: rawData is Map ? Map<String, dynamic>.from(rawData) : const {},
    );
  }
}

class CustomerMemory {
  const CustomerMemory({
    required this.id,
    required this.key,
    required this.value,
    required this.category,
    required this.source,
    this.confidence,
    this.expiresAt,
    this.reviewAt,
    this.createdBy,
    this.updatedBy,
    this.updatedAt,
  });

  final int id;
  final String key;
  final String value;
  final String category;
  final String source;
  final int? confidence;
  final String? expiresAt;
  final String? reviewAt;
  final String? createdBy;
  final String? updatedBy;
  final String? updatedAt;

  static CustomerMemory fromJson(Map<String, dynamic> json) {
    return CustomerMemory(
      id: _int(json['id']),
      key: '${json['key'] ?? ''}',
      value: '${json['value'] ?? ''}',
      category: '${json['category'] ?? 'general'}',
      source: '${json['source'] ?? 'manual'}',
      confidence: json['confidence'] == null ? null : _int(json['confidence']),
      expiresAt: json['expires_at']?.toString(),
      reviewAt: json['review_at']?.toString(),
      createdBy: _personName(json['created_by']),
      updatedBy: _personName(json['updated_by']),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class CustomerMemoryDraft {
  const CustomerMemoryDraft({
    required this.key,
    required this.value,
    this.category = 'general',
    this.source = 'manual',
    this.confidence,
  });

  final String key;
  final String value;
  final String category;
  final String source;
  final int? confidence;
}

int _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

num _num(Object? value) {
  if (value is num) return value;
  return num.tryParse('$value') ?? 0;
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse('$value');
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value
      .map((entry) => entry?.toString().trim() ?? '')
      .where((entry) => entry.isNotEmpty)
      .toList();
}

String? _personName(Object? value) {
  if (value is Map) {
    final name = value['name']?.toString().trim();
    return name == null || name.isEmpty ? null : name;
  }
  return null;
}
