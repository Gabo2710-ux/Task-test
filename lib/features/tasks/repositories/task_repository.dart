import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/task_model.dart';

class TaskRepository {
  final Dio _dio;

  TaskRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await _dio.get(ApiEndpoints.tasks);

      if (response.statusCode == 200) {
        // En json-server si devuelve un array directo
        final List data = response.data;
        return data.map((e) => TaskModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
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
          }
        ]
      };
      await _dio.post(ApiEndpoints.tasks, data: newTask);
    } catch (e) {
      throw Exception('Error adding task: $e');
    }
  }
}
