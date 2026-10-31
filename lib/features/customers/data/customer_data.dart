import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/api/paginated.dart';
import '../domain/customer_domain.dart';

class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.name,
    required this.status,
    this.email,
    this.phone,
    this.locale,
    this.notes,
    this.ordersCount,
    this.totalSpent,
    this.lastOrderAt,
    this.addresses = const [],
    this.createdAt,
  });

  final int id;
  final String name;
  final String status;
  final String? email;
  final String? phone;
  final String? locale;
  final String? notes;
  final int? ordersCount;
  final num? totalSpent;
  final String? lastOrderAt;
  final List<CustomerAddress> addresses;
  final String? createdAt;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final rawAddresses = json['addresses'];
    return CustomerModel(
      id: _int(json['id']),
      name: '${json['name'] ?? ''}',
      status: '${json['status'] ?? 'active'}',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      locale: json['locale'] as String?,
      notes: json['notes'] as String?,
      ordersCount: _nullableInt(json['orders_count']),
      totalSpent: _nullableNum(json['total_spent']),
      lastOrderAt: json['last_order_at'] as String?,
      addresses: rawAddresses is List
          ? rawAddresses
              .whereType<Map>()
              .map((entry) => _address(Map<String, dynamic>.from(entry)))
              .toList()
          : const [],
      createdAt: json['created_at'] as String?,
    );
  }

  Customer toEntity() => Customer(
        id: id,
        name: name,
        status: status,
        email: email,
        phone: phone,
        locale: locale,
        notes: notes,
        ordersCount: ordersCount,
        totalSpent: totalSpent,
        lastOrderAt: lastOrderAt,
        addresses: addresses,
        createdAt: createdAt,
      );

  static CustomerAddress _address(Map<String, dynamic> json) => CustomerAddress(
        id: _int(json['id']),
        label: json['label'] as String?,
        line1: json['line1'] as String?,
        line2: json['line2'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        postalCode: json['postal_code'] as String?,
        country: json['country'] as String?,
        phone: json['phone'] as String?,
        isDefault: json['is_default'] == true,
      );

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

  static num? _nullableNum(Object? value) {
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse('$value');
  }
}

class CustomerRemoteDataSource {
  CustomerRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Paginated<Customer>> list({
    String? search,
    String? status,
    int page = 1,
    int perPage = 20,
  }) {
    return _api.list<Customer>(
      ApiPaths.customers,
      query: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.isNotEmpty) 'status': status,
      },
      item: (json) => CustomerModel.fromJson(json).toEntity(),
    );
  }

  Future<Customer> get(int id) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.customer(id),
      decode: _asMap,
    );
    return CustomerModel.fromJson(data).toEntity();
  }

  Future<Customer> create(CustomerDraft draft) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.customers,
      body: _payload(draft),
      decode: _asMap,
    );
    return CustomerModel.fromJson(data).toEntity();
  }

  Future<Customer> update(int id, CustomerDraft draft) async {
    final data = await _api.patch<Map<String, dynamic>>(
      ApiPaths.customer(id),
      body: _payload(draft),
      decode: _asMap,
    );
    return CustomerModel.fromJson(data).toEntity();
  }

  Future<void> delete(int id) => _api.delete(ApiPaths.customer(id));

  Map<String, dynamic> _payload(CustomerDraft draft) {
    return {
      'name': draft.name,
      'email': draft.email,
      'phone': draft.phone,
      'status': draft.status,
      if (draft.locale != null) 'locale': draft.locale,
      if (draft.notes != null) 'notes': draft.notes,
    };
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._remote);

  final CustomerRemoteDataSource _remote;

  @override
  Future<Paginated<Customer>> list({
    String? search,
    String? status,
    int page = 1,
    int perPage = 20,
  }) {
    return _remote.list(
      search: search,
      status: status,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<Customer> get(int id) => _remote.get(id);

  @override
  Future<Customer> create(CustomerDraft draft) => _remote.create(draft);

  @override
  Future<Customer> update(int id, CustomerDraft draft) =>
      _remote.update(id, draft);

  @override
  Future<void> delete(int id) => _remote.delete(id);
}
