import 'package:flutter/material.dart';
import 'package:store/features/auth/data/session_store.dart';
import 'package:store/features/cart/data/api/cart_api.dart';
import 'package:store/features/cart/data/models/cart_item.dart';
import 'package:store/features/product/data/model/product.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  final List<CartItem> _items = [];
  final CartApi _cartApi = CartApi();
  bool _isLoadingFromApi = false;

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);

  bool get isLoadingFromApi => _isLoadingFromApi;

  /// Check if user is logged in
  bool get _isLoggedIn => SessionStore.currentUser.value != null;

  /// Load cart items from API when user logs in
  Future<void> loadCartFromApi() async {
    if (!_isLoggedIn) return;

    _isLoadingFromApi = true;
    notifyListeners();

    try {
      final apiItems = await _cartApi.fetchCartItems();
      _items.clear();
      _items.addAll(apiItems);
    } catch (e) {
      debugPrint('Error loading cart from API: $e');
    } finally {
      _isLoadingFromApi = false;
      notifyListeners();
    }
  }

  void addItem({
    required ProductModel product,
    required ProductVariety variety,
    int quantity = 1,
  }) async {
    final cartItemId = '${product.id}_${variety.id}';
    final existingIndex = _items.indexWhere((item) => item.id == cartItemId);

    if (existingIndex >= 0) {
      // Update existing item
      final newQuantity = _items[existingIndex].quantity + quantity;
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: newQuantity,
      );
      notifyListeners();

      // Update in database if logged in
      if (_isLoggedIn) {
        try {
          await _cartApi.updateCartItem(
            cartItemId: _items[existingIndex].id,
            quantity: newQuantity,
          );
        } catch (e) {
          debugPrint('Error updating cart in API: $e');
        }
      }
    } else {
      // Add new item locally first for instant UI feedback
      final newItem = CartItem(
        id: cartItemId,
        product: product,
        variety: variety,
        quantity: quantity,
      );
      _items.add(newItem);
      notifyListeners();

      // Add to database if logged in
      if (_isLoggedIn) {
        try {
          final apiItem = await _cartApi.addToCart(
            productId: product.id,
            varietyId: variety.id,
            quantity: quantity,
          );
          // Update with API-generated ID
          final index = _items.indexWhere((item) => item.id == cartItemId);
          if (index >= 0) {
            _items[index] = apiItem;
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Error adding to cart in API: $e');
          // Keep the local item even if API fails
        }
      }
    }
  }

  void removeItem(String cartItemId) async {
    // Remove from local list first for instant UI feedback
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();

    // Remove from database if logged in
    if (_isLoggedIn) {
      try {
        await _cartApi.removeFromCart(cartItemId);
      } catch (e) {
        debugPrint('Error removing from cart in API: $e');
      }
    }
  }

  void updateQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      removeItem(cartItemId);
      return;
    }
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      notifyListeners();

      // Update in database if logged in
      if (_isLoggedIn) {
        try {
          await _cartApi.updateCartItem(
            cartItemId: cartItemId,
            quantity: quantity,
          );
        } catch (e) {
          debugPrint('Error updating quantity in API: $e');
        }
      }
    }
  }

  void clearCart() async {
    _items.clear();
    notifyListeners();

    // Clear from database if logged in
    if (_isLoggedIn) {
      try {
        await _cartApi.clearCart();
      } catch (e) {
        debugPrint('Error clearing cart in API: $e');
      }
    }
  }

  bool hasItem(String productId, String varietyId) {
    return _items.any(
      (item) => item.product.id == productId && item.variety.id == varietyId,
    );
  }
}
