import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/paginated_response.dart';
import '../models/task_model.dart';

class TaskRepository {
  final Dio _dio;

  TaskRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  Future<PaginatedResponse<TaskModel>> getTasks({
    String? search,
    String? status,
    int? page,
    int? perPage,
    CancelToken? cancelToken,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (page != null) queryParams['page'] = page;
      if (perPage != null) queryParams['per_page'] = perPage;

      final response = await _dio.get(
        ApiEndpoints.tasks,
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        if (response.data is! Map<String, dynamic>) {
          throw const FormatException('Expected a JSON object with data and meta');
        }
        return PaginatedResponse<TaskModel>.fromJson(
          response.data,
          (json) => TaskModel.fromJson(json),
        );
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        rethrow;
      }
      throw Exception('Error fetching tasks: $e');
    }
  }

  Future<void> addTask({
    required String title,
    required String description,
    required String location,
  }) async {
    try {
      final newTask = {
        'id': 'task_${DateTime.now().millisecondsSinceEpoch}',
        'reference': 'REF-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        'title': title,
        'description': description,
        'status': 'pending',
        'priority': 'low',
        'location': location,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'assignees': [
          {
            "id": "user_001",
            "name": "Pedrinho Moreno", // Current user based on db.json
            "avatar_url": "https://example.test/images/users/user_001.jpg"
          },
          {
            "id": "user_003",
            "name": "Taylor Smith",
            "avatar_url": "https://example.test/images/users/user_003.jpg"
          }
        ]
      };
      await _dio.post(ApiEndpoints.tasks, data: newTask);
    } catch (e) {
      throw Exception('Error adding task: $e');
    }
  }
}
