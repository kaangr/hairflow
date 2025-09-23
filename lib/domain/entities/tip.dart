import 'package:equatable/equatable.dart';

enum TipCategory {
  product,
  routine,
  general,
  nutrition,
}

class Tip extends Equatable {
  final int? id;
  final String title;
  final String content;
  final TipCategory category;
  final String? imageUrl;
  final bool isFavorite;
  final DateTime createdAt;

  const Tip({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl,
    this.isFavorite = false,
    required this.createdAt,
  });

  Tip copyWith({
    int? id,
    String? title,
    String? content,
    TipCategory? category,
    String? imageUrl,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Tip(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        category,
        imageUrl,
        isFavorite,
        createdAt,
      ];
}
