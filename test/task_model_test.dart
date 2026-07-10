import 'package:flutter_test/flutter_test.dart';
import 'package:prueba/features/tasks/models/task_model.dart';
import 'package:prueba/features/tasks/models/user_model.dart';

void main() {
  group('TaskModel Tests', () {
    test('TaskModel.fromJson parses correctly', () {
      final json = {
        'id': 'task_001',
        'reference': 'REF-001',
        'title': 'Test Task',
        'description': 'A simple test task',
        'status': 'pending',
        'priority': 'high',
        'location': 'New York',
        'assignees': [
          {'id': 'u1', 'name': 'John Doe'}
        ]
      };

      final task = TaskModel.fromJson(json);

      expect(task.id, 'task_001');
      expect(task.reference, 'REF-001');
      expect(task.title, 'Test Task');
      expect(task.status, 'pending');
      expect(task.priority, 'high');
      expect(task.location, 'New York');
      expect(task.assignees.length, 1);
      expect(task.assignees.first.name, 'John Doe');
    });

    test('UserModel.toJson serializes correctly', () {
      final user = UserModel(id: 'u2', name: 'Jane Doe', avatarUrl: 'http://example.com/img.jpg');
      
      final json = user.toJson();
      
      expect(json['id'], 'u2');
      expect(json['name'], 'Jane Doe');
      expect(json['avatar_url'], 'http://example.com/img.jpg');
    });
  });
}
