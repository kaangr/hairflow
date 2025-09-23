import 'package:equatable/equatable.dart';

class RoutineTask extends Equatable {
  final int? id;
  final int routineId;
  final String title;
  final String? description;
  final int order;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime date; // Görevin hangi güne ait olduğu
  final DateTime createdAt;

  const RoutineTask({
    this.id,
    required this.routineId,
    required this.title,
    this.description,
    required this.order,
    this.isCompleted = false,
    this.completedAt,
    required this.date,
    required this.createdAt,
  });

  RoutineTask copyWith({
    int? id,
    int? routineId,
    String? title,
    String? description,
    int? order,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return RoutineTask(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        routineId,
        title,
        description,
        order,
        isCompleted,
        completedAt,
        date,
        createdAt,
      ];
}
