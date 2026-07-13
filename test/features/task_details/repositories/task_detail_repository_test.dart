import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:prueba/features/task_details/repositories/task_detail_repository.dart';
import 'package:prueba/features/task_details/models/task_detail_model.dart';
import 'package:prueba/core/api/api_endpoints.dart';

class MockDio extends Fake implements Dio {
  final Future<Response> Function(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) onPost;
  final Future<Response> Function(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) onGet;

  MockDio({required this.onPost, required this.onGet});

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    final response = await onGet(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
    return response as Response<T>;
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    final response = await onPost(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
    return response as Response<T>;
  }
}

void main() {
  group('TaskDetailRepository', () {
    test('getTaskDetail successfully parses wrapped data response', () async {
      final mockDio = MockDio(
        onGet: (path, {data, options, queryParameters, cancelToken}) async {
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {
              "data": {
                "id": "task_1001",
                "reference": "NET-1001",
                "title": "Replace the warehouse router",
                "description": "Replace the damaged router installed in warehouse area B.",
                "status": "in_progress",
                "priority": "high",
                "location": "Warehouse B",
                "created_at": "2026-07-07T08:00:00Z",
                "due_at": "2026-07-15T16:00:00Z",
                "updated_at": "2026-07-10T09:32:00Z",
                "assignees": [],
                "status_history": [
                  {
                    "id": "transition_001",
                    "new_status": "in_progress",
                    "created_by": {
                      "id": "user_001",
                      "name": "Alex Morgan"
                    }
                  }
                ]
              }
            },
          );
        },
        onPost: (path, {data, options, queryParameters, cancelToken}) async => throw UnimplementedError(),
      );

      final repository = TaskDetailRepository(dio: mockDio);
      final task = await repository.getTaskDetail('task_1001');

      expect(task.id, 'task_1001');
      expect(task.statusHistory.length, 1);
      expect(task.statusHistory.first.newStatus, 'in_progress');
      expect(task.statusHistory.first.createdBy.name, 'Alex Morgan');
    });

    test('updateTaskStatus sends POST request with correct payload for note only', () async {
      bool called = false;
      final mockDio = MockDio(
        onGet: (path, {data, options, queryParameters, cancelToken}) async => throw UnimplementedError(),
        onPost: (path, {data, options, queryParameters, cancelToken}) async {
          called = true;
          expect(path, '${ApiEndpoints.tasks}/task_1001/status-transitions');
          
          final requestData = data as Map<String, dynamic>;
          expect(requestData['status'], 'completed');
          expect(requestData['note'], 'Done!');
          expect(requestData.containsKey('image_url'), false);
          
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {},
          );
        },
      );

      final repository = TaskDetailRepository(dio: mockDio);
      await repository.updateTaskStatus('task_1001', 'completed', 'Done!', hasImage: false);
      expect(called, true);
    });

    test('updateTaskStatus throws Validation Error correctly mapping the fields', () async {
      final mockDio = MockDio(
        onGet: (path, {data, options, queryParameters, cancelToken}) async => throw UnimplementedError(),
        onPost: (path, {data, options, queryParameters, cancelToken}) async {
          throw DioException(
            requestOptions: RequestOptions(path: path),
            response: Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 400,
              data: {
                "error": {
                  "code": "VALIDATION_ERROR",
                  "message": "The status transition could not be created.",
                  "fields": {
                    "status": [
                      "The new status must be different from the current status."
                    ],
                    "evidence": [
                      "A note or an image is required."
                    ]
                  }
                }
              }
            )
          );
        },
      );

      final repository = TaskDetailRepository(dio: mockDio);
      
      try {
        await repository.updateTaskStatus('task_1001', 'in_progress', '');
        fail('Should have thrown');
      } catch (e) {
        expect(e.toString(), contains('The new status must be different from the current status.'));
        expect(e.toString(), contains('A note or an image is required.'));
      }
    });

    test('updateTaskStatus throws server error', () async {
      final mockDio = MockDio(
        onGet: (path, {data, options, queryParameters, cancelToken}) async => throw UnimplementedError(),
        onPost: (path, {data, options, queryParameters, cancelToken}) async {
          throw DioException(
            requestOptions: RequestOptions(path: path),
            response: Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 500,
            )
          );
        },
      );

      final repository = TaskDetailRepository(dio: mockDio);
      
      try {
        await repository.updateTaskStatus('task_1001', 'completed', 'Server failure');
        fail('Should have thrown');
      } catch (e) {
        expect(e.toString(), contains('Error updating task status'));
      }
    });
  });
}
