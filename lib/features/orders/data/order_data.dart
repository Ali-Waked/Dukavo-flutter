import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/api/paginated.dart';
import '../domain/order_domain.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.subtotal,
    required this.grandTotal,
    required this.currency,
    this.storeId,
    this.customerId,
    this.conversationId,
    this.statusLabel,
    this.paymentStatusLabel,
    this.discountTotal = 0,
    this.taxTotal = 0,
    this.shippingTotal = 0,
    this.customerName,
    this.customerPhone,
    this.notes,
    this.itemCount,
    this.allowedTransitions = const [],
    this.customer,
    this.items = const [],
    this.statusHistory = const [],
    this.placedAt,
    this.createdAt,
  });

  final int id;
  final String orderNumber;
  final int? storeId;
  final int? customerId;
  final int? conversationId;
  final String status;
  final String? statusLabel;
  final String paymentStatus;
  final String? paymentStatusLabel;
  final num subtotal;
  final num discountTotal;
  final num taxTotal;
  final num shippingTotal;
  final num grandTotal;
  final String currency;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final int? itemCount;
  final List<String> allowedTransitions;
  final OrderCustomerRef? customer;
  final List<OrderItem> items;
  final List<OrderHistoryEntry> statusHistory;
  final String? placedAt;
  final String? createdAt;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawCustomer = json['customer'];
    final rawItems = json['items'];
    final rawHistory = json['status_history'];
    final rawTransitions = json['allowed_transitions'];

    return OrderModel(
      id: _int(json['id']),
      orderNumber: '${json['order_number'] ?? ''}',
      storeId: _nullableInt(json['store_id']),
      customerId: _nullableInt(json['customer_id']),
      conversationId: _nullableInt(json['conversation_id']),
      status: '${json['status'] ?? 'pending'}',
      statusLabel: json['status_label'] as String?,
      paymentStatus: '${json['payment_status'] ?? 'unpaid'}',
      paymentStatusLabel: json['payment_status_label'] as String?,
      subtotal: _num(json['subtotal']),
      discountTotal: _num(json['discount_total']),
      taxTotal: _num(json['tax_total']),
      shippingTotal: _num(json['shipping_total']),
      grandTotal: _num(json['grand_total']),
      currency: '${json['currency'] ?? 'USD'}',
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      notes: json['notes'] as String?,
      itemCount: _nullableInt(json['item_count']),
      allowedTransitions: rawTransitions is List
          ? rawTransitions.map((entry) => '$entry').toList()
          : const [],
      customer: rawCustomer is Map
          ? OrderCustomerRef(
              id: _int(rawCustomer['id']),
              name: '${rawCustomer['name'] ?? ''}',
              email: rawCustomer['email'] as String?,
              phone: rawCustomer['phone'] as String?,
            )
          : null,
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((entry) => _item(Map<String, dynamic>.from(entry)))
              .toList()
          : const [],
      statusHistory: rawHistory is List
          ? rawHistory
              .whereType<Map>()
              .map((entry) => _history(Map<String, dynamic>.from(entry)))
              .toList()
          : const [],
      placedAt: json['placed_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Order toEntity() => Order(
        id: id,
        orderNumber: orderNumber,
        storeId: storeId,
        customerId: customerId,
        conversationId: conversationId,
        status: status,
        statusLabel: statusLabel,
        paymentStatus: paymentStatus,
        paymentStatusLabel: paymentStatusLabel,
        subtotal: subtotal,
        discountTotal: discountTotal,
        taxTotal: taxTotal,
        shippingTotal: shippingTotal,
        grandTotal: grandTotal,
        currency: currency,
        customerName: customerName,
        customerPhone: customerPhone,
        notes: notes,
        itemCount: itemCount,
        allowedTransitions: allowedTransitions,
        customer: customer,
        items: items,
        statusHistory: statusHistory,
        placedAt: placedAt,
        createdAt: createdAt,
      );

  static OrderItem _item(Map<String, dynamic> json) => OrderItem(
        id: _int(json['id']),
        productId: _nullableInt(json['product_id']),
        productVariantId: _nullableInt(json['product_variant_id']),
        name: '${json['name'] ?? ''}',
        sku: json['sku'] as String?,
        unitPrice: _num(json['unit_price']),
        quantity: _int(json['quantity']),
        discountTotal: _num(json['discount_total']),
        taxTotal: _num(json['tax_total']),
        lineTotal: _num(json['line_total']),
      );

  static OrderHistoryEntry _history(Map<String, dynamic> json) {
    final actor = json['user'] ?? json['actor'];
    return OrderHistoryEntry(
      fromStatus: json['from_status'] as String?,
      toStatus: '${json['to_status'] ?? ''}',
      note: json['note'] as String?,
      createdAt: json['created_at'] as String?,
      actorName: actor is Map ? '${actor['name'] ?? ''}' : null,
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

  static num _num(Object? value) {
    if (value is num) return value;
    return num.tryParse('$value') ?? 0;
  }
}

class OrderRemoteDataSource {
  OrderRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Paginated<Order>> list({
    String? search,
    String? status,
    int? customerId,
    int page = 1,
    int perPage = 20,
  }) {
    return _api.list<Order>(
      ApiPaths.orders,
      query: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.isNotEmpty) 'status': status,
        if (customerId != null) 'customer_id': customerId,
      },
      item: (json) => OrderModel.fromJson(json).toEntity(),
    );
  }

  Future<Order> get(String orderNumber) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.order(orderNumber),
      decode: _asMap,
    );
    return OrderModel.fromJson(data).toEntity();
  }

  Future<OrderTransitions> transitions(int id) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.orderTransitions(id),
      decode: _asMap,
    );
    final rawAllowed = data['allowed'];
    return OrderTransitions(
      current: '${data['current'] ?? ''}',
      isCancellable: data['is_cancellable'] == true,
      allowed: rawAllowed is List
          ? rawAllowed.whereType<Map>().map((entry) {
              final map = Map<String, dynamic>.from(entry);
              return OrderTransitionOption(
                status: '${map['status'] ?? ''}',
                label: '${map['label'] ?? map['status'] ?? ''}',
              );
            }).toList()
          : const [],
    );
  }

  Future<Order> create(OrderDraft draft) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.orders,
      body: {
        'customer_id': draft.customerId,
        'store_id': draft.storeId,
        if (draft.customerName != null) 'customer_name': draft.customerName,
        if (draft.customerPhone != null) 'customer_phone': draft.customerPhone,
        if (draft.notes != null) 'notes': draft.notes,
        'items': draft.items
            .map((item) => {
                  if (item.productId != null) 'product_id': item.productId,
                  'product_variant_id': item.productVariantId,
                  'quantity': item.quantity,
                })
            .toList(),
      },
      decode: _asMap,
    );
    return OrderModel.fromJson(data).toEntity();
  }

  Future<Order> transition(
    int id, {
    required String status,
    String? note,
    String? paymentStatus,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.orderTransition(id),
      body: {
        'status': status,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        if (paymentStatus != null) 'payment_status': paymentStatus,
      },
      decode: _asMap,
    );
    return OrderModel.fromJson(data).toEntity();
  }

  Future<void> delete(int id) {
    return _api.delete(ApiPaths.orderById(id));
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._remote);

  final OrderRemoteDataSource _remote;

  @override
  Future<Paginated<Order>> list({
    String? search,
    String? status,
    int? customerId,
    int page = 1,
    int perPage = 20,
  }) {
    return _remote.list(
      search: search,
      status: status,
      customerId: customerId,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<Order> get(String orderNumber) => _remote.get(orderNumber);

  @override
  Future<OrderTransitions> transitions(int id) => _remote.transitions(id);

  @override
  Future<Order> create(OrderDraft draft) => _remote.create(draft);

  @override
  Future<Order> transition(
    int id, {
    required String status,
    String? note,
    String? paymentStatus,
  }) {
    return _remote.transition(
      id,
      status: status,
      note: note,
      paymentStatus: paymentStatus,
    );
  }

  @override
  Future<void> delete(int id) => _remote.delete(id);
}
