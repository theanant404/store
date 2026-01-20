import 'package:flutter/material.dart';
import 'package:store/features/cart/data/models/cart_item.dart';
import 'package:store/features/product/data/model/product.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);

  void addItem({
    required ProductModel product,
    required ProductVariety variety,
    int quantity = 1,
  }) {
    final cartItemId = '${product.id}_${variety.id}';
    final existingIndex = _items.indexWhere((item) => item.id == cartItemId);

    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      _items.add(
        CartItem(
          id: cartItemId,
          product: product,
          variety: variety,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(cartItemId);
      return;
    }
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool hasItem(String productId, String varietyId) {
    return _items.any(
      (item) => item.product.id == productId && item.variety.id == varietyId,
    );
  }
}
