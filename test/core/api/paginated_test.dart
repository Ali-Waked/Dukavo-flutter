import 'package:dukavo_mobile/core/api/paginated.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaginationMeta.fromJson', () {
    test('uses safe defaults for a missing meta block', () {
      final meta = PaginationMeta.fromJson(null);
      expect(meta.currentPage, 1);
      expect(meta.lastPage, 1);
      expect(meta.perPage, 15);
      expect(meta.total, 0);
      expect(meta.from, isNull);
      expect(meta.to, isNull);
      expect(meta.hasMore, isFalse);
    });

    test('parses a Laravel paginator payload', () {
      final meta = PaginationMeta.fromJson(const {
        'current_page': 2,
        'last_page': 5,
        'per_page': 20,
        'total': 93,
        'from': 21,
        'to': 40,
      });

      expect(meta.currentPage, 2);
      expect(meta.lastPage, 5);
      expect(meta.perPage, 20);
      expect(meta.total, 93);
      expect(meta.from, 21);
      expect(meta.to, 40);
      expect(meta.hasMore, isTrue);
    });

    test('coerces string numbers and ignores malformed values', () {
      final meta = PaginationMeta.fromJson(const {
        'current_page': '3',
        'last_page': 'nope',
        'per_page': 10.0,
        'total': '45',
        'from': null,
        'to': '30',
      });

      expect(meta.currentPage, 3);
      expect(meta.lastPage, 1);
      expect(meta.perPage, 10);
      expect(meta.total, 45);
      expect(meta.from, isNull);
      expect(meta.to, 30);
    });
  });

  group('PaginationMeta.single', () {
    test('describes an empty single-page collection', () {
      final meta = PaginationMeta.single(0);
      expect(meta.currentPage, 1);
      expect(meta.lastPage, 1);
      expect(meta.perPage, 15);
      expect(meta.total, 0);
      expect(meta.from, isNull);
      expect(meta.to, isNull);
    });

    test('describes a populated single-page collection', () {
      final meta = PaginationMeta.single(4);
      expect(meta.perPage, 4);
      expect(meta.total, 4);
      expect(meta.from, 1);
      expect(meta.to, 4);
      expect(meta.hasMore, isFalse);
    });
  });

  group('Paginated', () {
    test('carries the rows and their metadata together', () {
      const page = Paginated<String>(
        items: ['a', 'b'],
        meta: PaginationMeta(
          currentPage: 1,
          lastPage: 1,
          perPage: 2,
          total: 2,
        ),
      );

      expect(page.items, ['a', 'b']);
      expect(page.meta.total, 2);
    });
  });
}
