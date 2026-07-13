import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prueba/features/tasks/repositories/task_repository.dart';

class MockDio extends Fake implements Dio {
  final Future<Response> Function(String path, {Map<String, dynamic>? queryParameters, CancelToken? cancelToken}) onGet;

  MockDio({required this.onGet});

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await onGet(path, queryParameters: queryParameters, cancelToken: cancelToken);
    return response as Response<T>;
  }
}

void main() {
  group('TaskRepository', () {
    test('getTasks parses PaginatedResponse correctly', () async {
      final mockDio = MockDio(
        onGet: (path, {queryParameters, cancelToken}) async {
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {
              'data': [
                {
                  'id': 'task_1',
                  'reference': 'REF-1',
                  'title': 'Test Task',
                  'description': 'Desc',
                  'status': 'pending',
                  'priority': 'low',
                  'location': 'Loc',
                }
              ],
              'meta': {
                'current_page': 1,
                'per_page': 20,
                'total': 1,
                'last_page': 1,
              }
            },
          );
        },
      );

      final repository = TaskRepository(dio: mockDio);
      final response = await repository.getTasks();

      expect(response.data.length, 1);
      expect(response.data.first.id, 'task_1');
      expect(response.meta.currentPage, 1);
      expect(response.meta.total, 1);
    });

    test('getTasks sends correct query parameters', () async {
      Map<String, dynamic>? capturedQuery;
      
      final mockDio = MockDio(
        onGet: (path, {queryParameters, cancelToken}) async {
          capturedQuery = queryParameters;
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {
              'data': [],
              'meta': {'current_page': 1, 'per_page': 20, 'total': 0, 'last_page': 1}
            },
          );
        },
      );

      final repository = TaskRepository(dio: mockDio);
      await repository.getTasks(search: 'router', status: 'in_progress', page: 2, perPage: 10);

      expect(capturedQuery?['search'], 'router');
      expect(capturedQuery?['status'], 'in_progress');
      expect(capturedQuery?['page'], 2);
      expect(capturedQuery?['per_page'], 10);
    });

    test('getTasks throws FormatException on malformed data', () async {
      final mockDio = MockDio(
        onGet: (path, {queryParameters, cancelToken}) async {
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: [], // Array instead of object
          );
        },
      );

      final repository = TaskRepository(dio: mockDio);

      expect(() => repository.getTasks(), throwsException);
    });
    
    test('getTasks handles Dio cancel properly', () async {
      final mockDio = MockDio(
        onGet: (path, {queryParameters, cancelToken}) async {
          throw DioException(
            requestOptions: RequestOptions(path: path),
            type: DioExceptionType.cancel,
          );
        },
      );

      final repository = TaskRepository(dio: mockDio);

      expect(() => repository.getTasks(), throwsA(isA<DioException>()));
    });
  });
}
