import 'package:store/features/product/data/model/product.dart';

class CartItem {
  final String id;
  final ProductModel product;
  final ProductVariety variety;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.variety,
    this.quantity = 1,
  });

  double get subtotal => variety.price * quantity;

  CartItem copyWith({
    String? id,
    ProductModel? product,
    ProductVariety? variety,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      variety: variety ?? this.variety,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          product.id == other.product.id &&
          variety.id == other.variety.id;

  @override
  int get hashCode => id.hashCode ^ product.id.hashCode ^ variety.id.hashCode;
}
