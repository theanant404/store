import 'package:store/config/app_config.dart';
import 'package:store/core/network/api_client.dart';
import 'package:store/features/checkout/data/models/order_model.dart';

/// Order API helper for managing orders.
class OrderApi {
  OrderApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Base URL for the order API.
  String get _baseUrl => '${AppConfig.apiBaseUrl}/user/orders';

  /// Create a new order.
  Future<Order> createOrder({
    required List<OrderItem> items,
    required String addressId,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    try {
      final body = {
        'items': items.map((item) => item.toJson()).toList(),
        'addressId': addressId,
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
      };

      final response = await _client.post(_baseUrl, body: body);

      if (!_client.isSuccess(response)) {
        final errorMsg = _client.getErrorMessage(response);
        throw Exception(errorMsg);
      }

      final decoded = _client.decodeResponse(response);
      return Order.fromJson(decoded['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  /// Fetch all orders for current user.
  Future<List<Order>> fetchOrders() async {
    try {
      final response = await _client.get(_baseUrl);

      if (!_client.isSuccess(response)) {
        throw Exception('Failed to fetch orders (${response.statusCode})');
      }

      final decoded = _client.decodeResponse(response);
      final ordersJson = decoded['data'] ?? [];

      return (ordersJson as List)
          .map((order) => Order.fromJson(order as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  /// Fetch single order by ID.
  Future<Order> fetchOrderById(String orderId) async {
    try {
      final response = await _client.get('$_baseUrl/$orderId');

      if (!_client.isSuccess(response)) {
        throw Exception('Failed to fetch order (${response.statusCode})');
      }

      final decoded = _client.decodeResponse(response);
      return Order.fromJson(decoded['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching order: $e');
    }
  }
}
