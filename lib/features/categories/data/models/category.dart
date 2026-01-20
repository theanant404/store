class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.title,
    required this.slug,
    this.imageUrl,
    this.description,
  });

  final String id;
  final String title;
  final String slug;
  final String? imageUrl;
  final String? description;

  /// Create a CategoryModel from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'],
      description: json['description'] ?? '',
    );
  }

  CategoryModel copyWith({
    String? id,
    String? title,
    String? slug,
    String? imageUrl,
    String? description,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }
}
