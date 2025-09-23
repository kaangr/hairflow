import 'package:equatable/equatable.dart';

class Routine extends Equatable {
  final int? id;
  final String name;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Routine({
    this.id,
    required this.name,
    required this.description,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  Routine copyWith({
    int? id,
    String? name,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        isActive,
        createdAt,
        updatedAt,
      ];
}
