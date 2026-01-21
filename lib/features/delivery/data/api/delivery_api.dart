import 'dart:convert';
import 'package:store/config/app_config.dart';
import 'package:store/core/network/api_client.dart';
import 'package:store/features/delivery/data/models/delivery_order_model.dart';

class DeliveryApi {
  DeliveryApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  String get _baseUrl => '${AppConfig.apiBaseUrl}/delivery/orders';

  /// Fetch all shipped orders (delivery person)
  Future<List<DeliveryOrderModel>> getShippedOrders() async {
    try {
      final response = await _client.get(_baseUrl);
      // print(response.body);
      if (!_client.isSuccess(response)) {
        throw Exception(
          'Failed to fetch shipped orders (${response.statusCode})',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      final ordersData = data is Map<String, dynamic>
          ? data['orders'] ?? data['data']
          : data;
      final rawList = ordersData ?? decoded['orders'] ?? [];

      if (rawList is List) {
        return rawList
            .map(
              (order) =>
                  DeliveryOrderModel.fromJson(order as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Error fetching shipped orders: $e');
    }
  }

  Future<List<DeliveryOrderModel>> getDeliveredOrders() async {
    try {
      final response = await _client.get('$_baseUrl/delivered');
      // print(response.body);
      if (!_client.isSuccess(response)) {
        throw Exception(
          'Failed to fetch shipped orders (${response.statusCode})',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      final ordersData = data is Map<String, dynamic>
          ? data['orders'] ?? data['data']
          : data;
      final rawList = ordersData ?? decoded['orders'] ?? [];

      if (rawList is List) {
        return rawList
            .map(
              (order) =>
                  DeliveryOrderModel.fromJson(order as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Error fetching shipped orders: $e');
    }
  }

  /// Get order by ID
  Future<DeliveryOrderModel> getOrderById(String orderId) async {
    try {
      final response = await _client.get('$_baseUrl/$orderId');
      if (!_client.isSuccess(response)) {
        throw Exception('Failed to fetch order (${response.statusCode})');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final orderData = decoded['data'] ?? decoded['order'];

      return DeliveryOrderModel.fromJson(orderData as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching order: $e');
    }
  }

  /// Mark order as delivered with OTP verification
  Future<void> deliverOrder(String orderId, String otp) async {
    try {
      final response = await _client.patch(
        '$_baseUrl/$orderId/deliver',
        body: {'otp': otp, 'status': 'delivered'},
      );
      print('$_baseUrl/$orderId/deliver');
      print(response.body);
      if (!_client.isSuccess(response)) {
        throw Exception('Failed to deliver order (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error delivering order: $e');
    }
  }

  /// Cancel order by delivery person
  Future<void> cancelOrder(String orderId) async {
    try {
      final response = await _client.patch(
        '$_baseUrl/$orderId/cancel',
        body: {'status': 'cancelled'},
      );

      if (!_client.isSuccess(response)) {
        throw Exception('Failed to cancel order (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error cancelling order: $e');
    }
  }
}
