import '../../domain/entities/tip.dart';

class TipModel extends Tip {
  const TipModel({
    super.id,
    required super.title,
    required super.content,
    required super.category,
    super.imageUrl,
    super.isFavorite,
    required super.createdAt,
  });

  factory TipModel.fromJson(Map<String, dynamic> json) {
    return TipModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      content: json['content'] as String,
      category: TipCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => TipCategory.general,
      ),
      imageUrl: json['image_url'] as String?,
      isFavorite: (json['is_favorite'] as int) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category.toString().split('.').last,
      'image_url': imageUrl,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TipModel.fromEntity(Tip tip) {
    return TipModel(
      id: tip.id,
      title: tip.title,
      content: tip.content,
      category: tip.category,
      imageUrl: tip.imageUrl,
      isFavorite: tip.isFavorite,
      createdAt: tip.createdAt,
    );
  }

  @override
  TipModel copyWith({
    int? id,
    String? title,
    String? content,
    TipCategory? category,
    String? imageUrl,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return TipModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
