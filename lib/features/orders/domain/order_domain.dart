import '../../../core/api/paginated.dart';

/// Orders, mirroring `OrderResource` and the transition endpoint.
class OrderCustomerRef {
  const OrderCustomerRef({
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

class OrderItem {
  const OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.productId,
    this.productVariantId,
    this.sku,
    this.discountTotal = 0,
    this.taxTotal = 0,
  });

  final int id;
  final int? productId;
  final int? productVariantId;
  final String name;
  final String? sku;
  final num unitPrice;
  final int quantity;
  final num discountTotal;
  final num taxTotal;
  final num lineTotal;
}

class OrderHistoryEntry {
  const OrderHistoryEntry({
    required this.toStatus,
    this.fromStatus,
    this.note,
    this.createdAt,
    this.actorName,
  });

  final String? fromStatus;
  final String toStatus;
  final String? note;
  final String? createdAt;
  final String? actorName;

  /// The state this entry moved the order into.
  String get status => toStatus;
}

class Order {
  const Order({
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

  String get displayCustomer =>
      customer?.name ?? customerName ?? '—';
}

class OrderTransitionOption {
  const OrderTransitionOption({required this.status, required this.label});

  final String status;
  final String label;
}

class OrderTransitions {
  const OrderTransitions({
    required this.current,
    required this.allowed,
    required this.isCancellable,
  });

  final String current;
  final List<OrderTransitionOption> allowed;
  final bool isCancellable;
}

class OrderItemDraft {
  const OrderItemDraft({
    required this.productVariantId,
    required this.quantity,
    this.productId,
  });

  final int productVariantId;
  final int quantity;
  final int? productId;
}

class OrderDraft {
  const OrderDraft({
    this.customerId,
    this.storeId,
    this.customerName,
    this.customerPhone,
    this.notes,
    this.items = const [],
  });

  final int? customerId;
  final int? storeId;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final List<OrderItemDraft> items;
}

abstract class OrderRepository {
  Future<Paginated<Order>> list({
    String? search,
    String? status,
    int? customerId,
    int page = 1,
    int perPage = 20,
  });

  Future<Order> get(String orderNumber);

  Future<OrderTransitions> transitions(int id);

  Future<Order> create(OrderDraft draft);

  Future<Order> transition(
    int id, {
    required String status,
    String? note,
    String? paymentStatus,
  });

  Future<void> delete(int id);
}
