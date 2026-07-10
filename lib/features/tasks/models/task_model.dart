import 'user_model.dart';

class TaskModel {
  final String id;
  final String reference;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String location;
  final String? dueAt;
  final String? updatedAt;
  final List<UserModel> assignees;

  TaskModel({
    required this.id,
    required this.reference,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.location,
    this.dueAt,
    this.updatedAt,
    this.assignees = const [],
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'low',
      location: json['location'] ?? '',
      dueAt: json['due_at'],
      updatedAt: json['updated_at'],
      assignees: (json['assignees'] as List<dynamic>?)
              ?.map((e) => UserModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
