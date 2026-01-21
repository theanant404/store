import 'dart:convert';
import 'package:store/config/app_config.dart';
import 'package:store/core/network/api_client.dart';
import 'package:store/features/orders/data/models/order_model.dart';

class OrderApi {
  OrderApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  String get _baseUrl => '${AppConfig.apiBaseUrl}/orders';

  /// Fetch all orders (admin)
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await _client.get(_baseUrl);

      if (!_client.isSuccess(response)) {
        throw Exception('Failed to fetch orders (${response.statusCode})');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final ordersData = decoded['data'] ?? decoded['orders'] ?? [];

      if (ordersData is List) {
        return ordersData
            .map((order) => OrderModel.fromJson(order as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching orders: $e');
      throw Exception('Error fetching orders: $e');
    }
  }

  /// Get order by ID
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await _client.get('$_baseUrl/$orderId');

      if (!_client.isSuccess(response)) {
        throw Exception('Failed to fetch order (${response.statusCode})');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final orderData = decoded['data'] ?? decoded['order'];

      return OrderModel.fromJson(orderData as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching order: $e');
    }
  }

  /// Update order status
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _client.put(
        '$_baseUrl/$orderId/status',
        body: {'status': status},
      );

      if (!_client.isSuccess(response)) {
        throw Exception(
          'Failed to update order status (${response.statusCode})',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final orderData = decoded['data'] ?? decoded['order'];

      return OrderModel.fromJson(orderData as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error updating order status: $e');
    }
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      final response = await _client.put('$_baseUrl/$orderId/cancel', body: {});

      if (!_client.isSuccess(response)) {
        throw Exception('Failed to cancel order (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error cancelling order: $e');
    }
  }
}
