import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/task_detail_model.dart';

class TaskDetailRepository {
  final Dio _dio;

  TaskDetailRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  Future<TaskDetailModel> getTaskDetail(String taskId) async {
    try {
      final response = await _dio.get(ApiEndpoints.taskDetail(taskId));
      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic> && response.data.containsKey('data')) {
          return TaskDetailModel.fromJson(response.data['data']);
        } else {
          // Fallback if the endpoint hasn't updated or returns direct object
          return TaskDetailModel.fromJson(response.data);
        }
      } else {
        throw Exception('Failed to load task detail');
      }
    } catch (e) {
      throw Exception('Error fetching task detail: $e');
    }
  }

  Future<void> updateTaskStatus(String taskId, String newStatus, String note, {bool hasImage = false}) async {
    try {
      final requestData = {
        'status': newStatus,
        'note': note.isNotEmpty ? note : null,
      };

      if (hasImage) {
        // Simulate an uploaded image URL
        requestData['image_url'] = "https://picsum.photos/400/300";
      }

      await _dio.post(
        '${ApiEndpoints.tasks}/$taskId/status-transitions',
        data: requestData,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 && e.response?.data != null) {
        final errorData = e.response?.data['error'];
        if (errorData != null && errorData['code'] == 'VALIDATION_ERROR') {
          final fields = errorData['fields'] as Map<String, dynamic>?;
          final messages = fields?.values.expand((v) => (v as List).map((s) => s.toString())).join('\n');
          throw Exception(messages ?? errorData['message'] ?? 'Validation Error');
        }
      }
      
      // Friendly message for network/connection errors
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Error de conexión. Verifica tu red y el servidor.');
      }
      
      throw Exception('Error updating task status: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
