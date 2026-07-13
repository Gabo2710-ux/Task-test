import 'package:flutter_test/flutter_test.dart';
import 'package:prueba/features/chat/models/chat_message_model.dart';

void main() {
  group('ChatMessageModel Tests', () {
    test('Parses correctly from valid JSON', () {
      final json = {
        'id': 'msg_1',
        'task_id': 'task_1',
        'type': 'text',
        'content': 'Hello',
        'created_at': '2026-07-10T12:00:00Z',
        'sender': {
          'id': 'u1',
          'name': 'John',
          'avatar_url': 'http://example.com/u1.jpg'
        }
      };

      final message = ChatMessageModel.fromJson(json);

      expect(message.id, 'msg_1');
      expect(message.taskId, 'task_1');
      expect(message.type, 'text');
      expect(message.content, 'Hello');
      expect(message.createdAt, '2026-07-10T12:00:00Z');
      expect(message.sender.id, 'u1');
    });

    test('Throws error or handles malformed/missing required fields', () {
      final jsonMissingId = {
        'task_id': 'task_1',
        'type': 'text',
        'content': 'Hello',
        'sender': {
          'id': 'u1',
          'name': 'John'
        }
      };

      // Depending on implementation, fromJson will throw TypeError if 'id' is required.
      // We expect it to throw since id is required and we passed null/missing.
      expect(
        () => ChatMessageModel.fromJson(jsonMissingId),
        throwsA(isA<TypeError>()),
      );
    });

    test('parsedDate getter correctly parses ISO string', () {
      final message = ChatMessageModel(
        id: '1',
        taskId: 't1',
        type: 'text',
        content: 'Hi',
        createdAt: '2026-07-10T12:00:00Z',
        sender: null as dynamic, // Ignoring sender for this specific test
      );

      final date = message.parsedDate;
      expect(date.year, 2026);
      expect(date.month, 7);
      expect(date.day, 10);
    });

    test('parsedDate getter falls back to ancient date if parsing fails', () {
      final message = ChatMessageModel(
        id: '1',
        taskId: 't1',
        type: 'text',
        content: 'Hi',
        createdAt: 'invalid-date',
        sender: null as dynamic,
      );

      final date = message.parsedDate;
      expect(date.year, 1970);
    });
  });
}
