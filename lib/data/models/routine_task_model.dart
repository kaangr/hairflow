import '../../domain/entities/routine_task.dart';

class RoutineTaskModel extends RoutineTask {
  const RoutineTaskModel({
    super.id,
    required super.routineId,
    required super.title,
    super.description,
    required super.order,
    super.isCompleted,
    super.completedAt,
    required super.date,
    super.scheduledTime,
    required super.createdAt,
  });

  factory RoutineTaskModel.fromJson(Map<String, dynamic> json) {
    return RoutineTaskModel(
      id: json['id'] as int?,
      routineId: json['routine_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      order: json['order_index'] as int,
      isCompleted: (json['is_completed'] as int) == 1,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
      date: DateTime.parse(json['date'] as String),
      scheduledTime: json['scheduled_time'] != null 
          ? DateTime.parse(json['scheduled_time'] as String) 
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routine_id': routineId,
      'title': title,
      'description': description,
      'order_index': order,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'scheduled_time': scheduledTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RoutineTaskModel.fromEntity(RoutineTask task) {
    return RoutineTaskModel(
      id: task.id,
      routineId: task.routineId,
      title: task.title,
      description: task.description,
      order: task.order,
      isCompleted: task.isCompleted,
      completedAt: task.completedAt,
      date: task.date,
      scheduledTime: task.scheduledTime,
      createdAt: task.createdAt,
    );
  }

  @override
  RoutineTaskModel copyWith({
    int? id,
    int? routineId,
    String? title,
    String? description,
    int? order,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? date,
    DateTime? scheduledTime,
    DateTime? createdAt,
  }) {
    return RoutineTaskModel(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      date: date ?? this.date,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}