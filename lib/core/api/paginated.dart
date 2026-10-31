/// Pager metadata exactly as Laravel's resource collections emit it.
class PaginationMeta {
  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;

  bool get hasMore => currentPage < lastPage;

  factory PaginationMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PaginationMeta(
        currentPage: 1,
        lastPage: 1,
        perPage: 15,
        total: 0,
      );
    }
    return PaginationMeta(
      currentPage: _int(json['current_page'], 1),
      lastPage: _int(json['last_page'], 1),
      perPage: _int(json['per_page'], 15),
      total: _int(json['total'], 0),
      from: _nullableInt(json['from']),
      to: _nullableInt(json['to']),
    );
  }

  factory PaginationMeta.single(int count) => PaginationMeta(
        currentPage: 1,
        lastPage: 1,
        perPage: count == 0 ? 15 : count,
        total: count,
        from: count == 0 ? null : 1,
        to: count == 0 ? null : count,
      );

  static int _int(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }

  static int? _nullableInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }
}

/// A page of rows plus the information needed to fetch the next one.
class Paginated<T> {
  const Paginated({required this.items, required this.meta});

  final List<T> items;
  final PaginationMeta meta;
}
