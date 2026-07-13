import 'package:flutter_test/flutter_test.dart';
import 'package:prueba/core/models/pagination_meta.dart';

void main() {
  group('PaginationMeta Tests', () {
    test('Parses correctly from valid JSON', () {
      final json = {
        'current_page': 2,
        'per_page': 15,
        'total': 45,
        'last_page': 3,
      };

      final meta = PaginationMeta.fromJson(json);

      expect(meta.currentPage, 2);
      expect(meta.perPage, 15);
      expect(meta.total, 45);
      expect(meta.lastPage, 3);
    });

    test('Provides defaults when fields are missing', () {
      final json = <String, dynamic>{};

      final meta = PaginationMeta.fromJson(json);

      expect(meta.currentPage, 1);
      expect(meta.perPage, 20);
      expect(meta.total, 0);
      expect(meta.lastPage, 1);
    });
  });
}
