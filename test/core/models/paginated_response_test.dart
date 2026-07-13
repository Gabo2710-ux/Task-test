import 'package:flutter_test/flutter_test.dart';
import 'package:prueba/core/models/paginated_response.dart';

void main() {
  group('PaginatedResponse Tests', () {
    test('Parses wrapped data and meta correctly', () {
      final json = {
        'data': [
          {'id': 1, 'name': 'Item 1'},
          {'id': 2, 'name': 'Item 2'},
        ],
        'meta': {
          'current_page': 1,
          'per_page': 20,
          'total': 2,
          'last_page': 1,
        }
      };

      // Dummy parser
      int parser(Map<String, dynamic> item) => item['id'] as int;

      final response = PaginatedResponse<int>.fromJson(json, parser);

      expect(response.data.length, 2);
      expect(response.data[0], 1);
      expect(response.data[1], 2);
      
      expect(response.meta.currentPage, 1);
      expect(response.meta.total, 2);
    });

    test('Throws FormatException if data or meta is missing', () {
      final jsonMissingData = {
        'meta': {
          'current_page': 1,
        }
      };

      final jsonMissingMeta = {
        'data': []
      };

      int parser(Map<String, dynamic> item) => 1;

      expect(
        () => PaginatedResponse<int>.fromJson(jsonMissingData, parser),
        throwsA(isA<FormatException>()),
      );

      expect(
        () => PaginatedResponse<int>.fromJson(jsonMissingMeta, parser),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
