import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:prueba/features/chat/repositories/chat_repository.dart';
import 'package:prueba/features/chat/models/chat_message_model.dart';

void main() {
  group('ChatRepository', () {
    late ChatRepository repository;
    late Dio dio;

    setUp(() {
      dio = Dio();
      repository = ChatRepository(dio: dio);
    });

    test('getMessages parses wrapped response correctly', () async {
      // Create a mock adapter to intercept Dio requests
      dio.httpClientAdapter = _MockAdapter((options, requestStream, cancelFuture) async {
        return ResponseBody.fromString(
          '''
          {
            "data": [
              {
                "id": "msg1",
                "task_id": "task1",
                "type": "text",
                "content": "Hello",
                "created_at": "2026-07-10T09:15:00Z",
                "sender": { "id": "u1", "name": "Alex" }
              }
            ],
            "meta": {
              "participants": [
                { "id": "u1", "name": "Alex" }
              ]
            }
          }
          ''',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final response = await repository.getMessages('task1');
      expect(response.messages.length, 1);
      expect(response.participants.length, 1);
      expect(response.messages.first.content, 'Hello');
      expect(response.participants.first.name, 'Alex');
    });
    
    test('sendMessage maps success response', () async {
      dio.httpClientAdapter = _MockAdapter((options, requestStream, cancelFuture) async {
        return ResponseBody.fromString(
          '''
          {
            "data": {
                "id": "msg2",
                "task_id": "task1",
                "type": "text",
                "content": "Reply",
                "created_at": "2026-07-10T09:16:00Z",
                "sender": { "id": "u1", "name": "Alex" }
            }
          }
          ''',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final message = await repository.sendMessage('task1', 'Reply');
      expect(message.id, 'msg2');
      expect(message.content, 'Reply');
    });

    test('sendMessage maps validation error', () async {
      dio.httpClientAdapter = _MockAdapter((options, requestStream, cancelFuture) async {
        return ResponseBody.fromString(
          '''
          {
            "error": {
              "code": "VALIDATION_ERROR",
              "fields": {
                "content": ["The message content is required."]
              }
            }
          }
          ''',
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      expect(
        () => repository.sendMessage('task1', '   '),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('The message content is required.')))
      );
    });
  });
  
  test('Deterministic chronological ordering parsing', () {
      final m1 = ChatMessageModel(id: '1', taskId: '1', type: 'text', content: 'A', sender: const ChatMessageModel(id:'', taskId:'', type:'', content:'', sender: null).sender, createdAt: '2026-07-10T09:16:00Z');
      final m2 = ChatMessageModel(id: '2', taskId: '1', type: 'text', content: 'B', sender: const ChatMessageModel(id:'', taskId:'', type:'', content:'', sender: null).sender, createdAt: '2026-07-10T09:15:00Z');
      final list = [m1, m2];
      list.sort((a, b) => a.parsedDate.compareTo(b.parsedDate));
      expect(list.first.id, '2'); // older first
  });
}

class _MockAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options, Stream<List<int>>? requestStream, Future<dynamic>? cancelFuture) handler;

  _MockAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future<dynamic>? cancelFuture) {
    return handler(options, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) {}
}
