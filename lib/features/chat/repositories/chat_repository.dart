import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/chat_message_model.dart';

class ChatRepository {
  final Dio _dio;

  ChatRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  Future<List<ChatMessageModel>> getMessages(String taskId) async {
    try {
      final response = await _dio.get(ApiEndpoints.taskMessages(taskId));
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => ChatMessageModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  Future<void> sendMessage(String taskId, String content, {
    String senderId = 'user_001',
    String senderName = 'Alex Morgan',
    String avatarUrl = 'https://example.test/images/users/user_001.jpg',
  }) async {
    try {
      await _dio.post(
        '/messages',
        data: {
          'task_id': taskId,
          'type': 'text',
          'content': content,
          'created_at': DateTime.now().toIso8601String(),
          'sender': {
             "id": senderId,
             "name": senderName,
             "avatar_url": avatarUrl,
          }
        },
      );
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
}
