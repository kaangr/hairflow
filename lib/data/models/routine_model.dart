import '../../domain/entities/routine.dart';

class RoutineModel extends Routine {
  const RoutineModel({
    super.id,
    required super.name,
    required super.description,
    super.isActive,
    required super.createdAt,
    super.updatedAt,
  });

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    return RoutineModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String,
      isActive: (json['is_active'] as int) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory RoutineModel.fromEntity(Routine routine) {
    return RoutineModel(
      id: routine.id,
      name: routine.name,
      description: routine.description,
      isActive: routine.isActive,
      createdAt: routine.createdAt,
      updatedAt: routine.updatedAt,
    );
  }

  @override
  RoutineModel copyWith({
    int? id,
    String? name,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
