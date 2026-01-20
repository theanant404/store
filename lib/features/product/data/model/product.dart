class ProductVariety {
  const ProductVariety({
    required this.id,
    required this.price,
    this.weight,
    this.quantity,
    this.quantityUnit,
    this.discount,
    this.stock = 0,
  });

  final String id;
  final double price;
  final double? weight;
  final int? quantity;
  final String? quantityUnit;
  final double? discount;
  final int stock;

  factory ProductVariety.fromJson(Map<String, dynamic> json) {
    return ProductVariety(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      weight: (json['weight'] as num?)?.toDouble(),
      quantity: json['quantity'] as int?,
      quantityUnit:
          json['quantityUnit'] as String? ?? json['quantity_unit'] as String?,
      discount: (json['discount'] as num?)?.toDouble(),
      stock: json['stock'] is int
          ? json['stock'] as int
          : int.tryParse('${json['stock']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'price': price,
      if (weight != null) 'weight': weight,
      if (quantity != null) 'quantity': quantity,
      if (quantityUnit != null) 'quantityUnit': quantityUnit,
      if (discount != null) 'discount': discount,
      'stock': stock,
    };
  }

  ProductVariety copyWith({
    String? id,
    double? price,
    double? weight,
    int? quantity,
    String? quantityUnit,
    double? discount,
    int? stock,
  }) {
    return ProductVariety(
      id: id ?? this.id,
      price: price ?? this.price,
      weight: weight ?? this.weight,
      quantity: quantity ?? this.quantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      discount: discount ?? this.discount,
      stock: stock ?? this.stock,
    );
  }
}

class ProductModel {
  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    this.imageUrls = const [],
    this.varieties = const [],
  });

  final String id;
  final String title;
  final String description;
  final String categoryId;
  final List<String> imageUrls;
  final List<ProductVariety> varieties;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final images =
        json['imageUrls'] ?? json['image_urls'] ?? json['images'] ?? [];
    final varietiesJson = json['varieties'] ?? json['variants'] ?? [];
    return ProductModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categoryId:
          json['categoryId']?.toString() ??
          json['category_id']?.toString() ??
          json['category']?.toString() ??
          '',
      imageUrls: List<String>.from(
        images is List ? images.map((e) => e.toString()) : const [],
      ),
      varieties: (varietiesJson as List)
          .map((v) => ProductVariety.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': categoryId,
      'images': imageUrls,
      'varieties': varieties.map((v) => v.toJson()).toList(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    List<String>? imageUrls,
    List<ProductVariety>? varieties,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      imageUrls: imageUrls ?? this.imageUrls,
      varieties: varieties ?? this.varieties,
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isFeatured;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.isFeatured = false,
  });
}
