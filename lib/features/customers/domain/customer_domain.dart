import '../../../core/api/paginated.dart';

/// Customers, mirroring `CustomerResource`.
class CustomerAddress {
  const CustomerAddress({
    required this.id,
    this.label,
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.phone,
    this.isDefault = false,
  });

  final int id;
  final String? label;
  final String? line1;
  final String? line2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? phone;
  final bool isDefault;

  String get oneLine => [
        line1,
        line2,
        city,
        state,
        postalCode,
        country,
      ].where((part) => part != null && part.trim().isNotEmpty).join(', ');
}

class Customer {
  const Customer({
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
}

class CustomerDraft {
  const CustomerDraft({
    required this.name,
    this.email,
    this.phone,
    this.status = 'active',
    this.locale,
    this.notes,
  });

  final String name;
  final String? email;
  final String? phone;
  final String status;
  final String? locale;
  final String? notes;
}

abstract class CustomerRepository {
  Future<Paginated<Customer>> list({
    String? search,
    String? status,
    int page = 1,
    int perPage = 20,
  });

  Future<Customer> get(int id);

  Future<Customer> create(CustomerDraft draft);

  Future<Customer> update(int id, CustomerDraft draft);

  Future<void> delete(int id);
}
