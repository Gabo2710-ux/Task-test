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
        return TaskDetailModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load task detail');
      }
    } catch (e) {
      throw Exception('Error fetching task detail: $e');
    }
  }

  Future<void> updateTaskStatus(String taskId, String newStatus, String note, {bool hasImage = false}) async {
    try {
      final currentTask = await getTaskDetail(taskId);
      final newHistory = currentTask.statusHistory.map((e) => e.toJson()).toList();
      
      newHistory.add({
        "id": "transition_${DateTime.now().millisecondsSinceEpoch}",
        "previous_status": currentTask.status,
        "new_status": newStatus,
        "note": note,
        "image_url": hasImage ? "https://picsum.photos/400/300" : null,
        "created_at": DateTime.now().toUtc().toIso8601String(),
        "created_by": {
          "id": "user_001",
          "name": "Alex Morgan",
          "avatar_url": "https://example.test/images/users/user_001.jpg"
        }
      });

      await _dio.patch(
        ApiEndpoints.taskDetail(taskId),
        data: {
          'status': newStatus,
          'status_history': newHistory,
        },
      );
    } catch (e) {
      throw Exception('Error updating task status: $e');
    }
  }
}
