import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../models/chat_message_model.dart';
import '../models/chat_response_model.dart';

class ChatRepository {
  final Dio _dio;

  ChatRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  Future<ChatResponseModel> getMessages(String taskId) async {
    try {
      final response = await _dio.get('/api/tasks/$taskId/messages');
      if (response.statusCode == 200) {
        return ChatResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      if (e is DioException && (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout)) {
        throw Exception('Connection error. Check your network and the server.');
      }
      throw Exception('Error fetching messages: $e');
    }
  }

  Future<ChatMessageModel> sendMessage(String taskId, String content) async {
    try {
      final response = await _dio.post(
        '/api/tasks/$taskId/messages',
        data: {
          'content': content,
        },
      );
      return ChatMessageModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 && e.response?.data != null) {
        final errorData = e.response?.data['error'];
        if (errorData != null && errorData['code'] == 'VALIDATION_ERROR') {
          final fields = errorData['fields'] as Map<String, dynamic>?;
          final messages = fields?.values.expand((v) => (v as List).map((s) => s.toString())).join('\n');
          throw Exception(messages ?? errorData['message'] ?? 'Validation Error');
        }
      }
      
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection error. Check your network and the server.');
      }
      
      throw Exception('Error sending message: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
