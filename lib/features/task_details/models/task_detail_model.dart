import '../../tasks/models/user_model.dart';
import '../../tasks/models/task_model.dart';

class StatusTransition {
  final String id;
  final String? previousStatus;
  final String newStatus;
  final String? note;
  final String? imageUrl;
  final String? createdAt;
  final UserModel createdBy;

  StatusTransition({
    required this.id,
    this.previousStatus,
    required this.newStatus,
    this.note,
    this.imageUrl,
    this.createdAt,
    required this.createdBy,
  });

  factory StatusTransition.fromJson(Map<String, dynamic> json) {
    return StatusTransition(
      id: json['id'] ?? '',
      previousStatus: json['previous_status'],
      newStatus: json['new_status'] ?? '',
      note: json['note'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
      createdBy: UserModel.fromJson(json['created_by'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'previous_status': previousStatus,
      'new_status': newStatus,
      'note': note,
      'image_url': imageUrl,
      'created_at': createdAt,
      'created_by': createdBy.toJson(),
    };
  }
}

class TaskDetailModel extends TaskModel {
  final List<StatusTransition> statusHistory;
  final String? createdAt;

  TaskDetailModel({
    required super.id,
    required super.reference,
    required super.title,
    required super.description,
    required super.status,
    required super.priority,
    required super.location,
    super.dueAt,
    super.updatedAt,
    super.assignees,
    this.createdAt,
    this.statusHistory = const [],
  });

  factory TaskDetailModel.fromJson(Map<String, dynamic> json) {
    return TaskDetailModel(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'low',
      location: json['location'] ?? '',
      dueAt: json['due_at'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      assignees: (json['assignees'] as List<dynamic>?)
              ?.map((e) => UserModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      statusHistory: (json['status_history'] as List<dynamic>?)
              ?.map((e) => StatusTransition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
