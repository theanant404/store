import 'dart:convert';
import 'package:store/config/app_config.dart';
import 'package:store/core/network/api_client.dart';
import 'package:store/features/orders/data/models/order_model.dart';

class OrderApi {
  OrderApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  String get _baseUrl => '${AppConfig.apiBaseUrl}/admin/orders';

  /// Fetch all orders (admin)
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await _client.get(_baseUrl);
      // print(response.body);
      if (!_client.isSuccess(response)) {
        throw Exception('Failed to fetch orders (${response.statusCode})');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      final ordersData = data is Map<String, dynamic>
          ? data['orders'] ?? data['data']
          : data;
      final rawList = ordersData ?? decoded['orders'] ?? [];

      if (rawList is List) {
        return rawList
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

  /// Update order status and return the new status string
  Future<String> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _client.patch(
        '$_baseUrl/$orderId/status',
        body: {'status': status},
      );
      print('bodyResponse: ${response.body}');

      if (!_client.isSuccess(response)) {
        throw Exception(
          'Failed to update order status (${response.statusCode})',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      if (data is String && data.isNotEmpty) {
        return data;
      }
      final orderData = data ?? decoded['order'];
      if (orderData is Map<String, dynamic>) {
        return OrderModel.fromJson(orderData).status;
      }
      return status;
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
