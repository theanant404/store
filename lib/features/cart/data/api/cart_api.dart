import 'package:store/config/app_config.dart';
import 'package:store/core/network/api_client.dart';
import 'package:store/features/cart/data/models/cart_item.dart';
import 'package:store/features/product/data/model/product.dart';

/// Cart API helper for managing cart items in the backend.
class CartApi {
  CartApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Base URL for the cart API.
  String get _baseUrl => '${AppConfig.apiBaseUrl}/user/cart';

  /// Fetch all cart items for current user.
  Future<List<CartItem>> fetchCartItems() async {
    try {
      final response = await _client.get(_baseUrl);

      if (!_client.isSuccess(response)) {
        throw Exception('Failed to fetch cart items (${response.statusCode})');
      }

      final decoded = _client.decodeResponse(response);
      final cartItemsJson = decoded['data'] ?? [];

      return (cartItemsJson as List)
          .map((item) => _parseCartItem(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching cart items: $e');
    }
  }

  /// Add item to cart.
  Future<CartItem> addToCart({
    required String productId,
    required String varietyId,
    required int quantity,
  }) async {
    try {
      final response = await _client.post(
        _baseUrl,
        body: {
          'productId': productId,
          'varietyId': varietyId,
          'quantity': quantity,
        },
      );

      if (!_client.isSuccess(response)) {
        final errorMsg = _client.getErrorMessage(response);
        throw Exception(errorMsg);
      }

      final decoded = _client.decodeResponse(response);
      return _parseCartItem(decoded['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }

  /// Update cart item quantity.
  Future<CartItem> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await _client.put(
        '$_baseUrl/$cartItemId',
        body: {'quantity': quantity},
      );

      if (!_client.isSuccess(response)) {
        final errorMsg = _client.getErrorMessage(response);
        throw Exception(errorMsg);
      }

      final decoded = _client.decodeResponse(response);
      return _parseCartItem(decoded['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error updating cart item: $e');
    }
  }

  /// Remove item from cart.
  Future<void> removeFromCart(String cartItemId) async {
    try {
      final response = await _client.delete('$_baseUrl/$cartItemId');

      if (!_client.isSuccess(response)) {
        final errorMsg = _client.getErrorMessage(response);
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Error removing from cart: $e');
    }
  }

  /// Clear all cart items.
  Future<void> clearCart() async {
    try {
      final response = await _client.delete(_baseUrl);

      if (!_client.isSuccess(response)) {
        final errorMsg = _client.getErrorMessage(response);
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Error clearing cart: $e');
    }
  }

  /// Parse cart item from API response.
  CartItem _parseCartItem(Map<String, dynamic> json) {
    final productData = json['product'] as Map<String, dynamic>;
    final varietyData = json['variety'] as Map<String, dynamic>;

    final product = ProductModel.fromJson(productData);
    final variety = ProductVariety.fromJson(varietyData);

    return CartItem(
      id: json['_id']?.toString() ?? '',
      product: product,
      variety: variety,
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}
