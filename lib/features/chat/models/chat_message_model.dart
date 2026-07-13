import '../../tasks/models/user_model.dart';

class ChatMessageModel {
  final String id;
  final String taskId;
  final String type;
  final String content;
  final String? createdAt;
  final UserModel sender;

  ChatMessageModel({
    required this.id,
    required this.taskId,
    required this.type,
    required this.content,
    this.createdAt,
    required this.sender,
  });

  DateTime get parsedDate {
    if (createdAt == null || createdAt!.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    try {
      return DateTime.parse(createdAt!);
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? '',
      taskId: json['task_id'] ?? '',
      type: json['type'] ?? 'text',
      content: json['content'] ?? '',
      createdAt: json['created_at'],
      sender: UserModel.fromJson(json['sender'] ?? {}),
    );
  }
}
