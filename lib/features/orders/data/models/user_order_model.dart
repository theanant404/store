import 'package:intl/intl.dart';

class OrderModel {
  final String id;
  final List<OrderItem> items;
  final Map<String, dynamic>? deliveryAddress;
  final String status;
  final double totalAmount;
  final String? otp;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.items,
    this.deliveryAddress,
    required this.status,
    required this.totalAmount,
    this.otp,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? '',
      status: json['status'] ?? 'pending',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      otp: json['otp']?.toString(),
      createdAt: DateTime.parse(json['createdAt']),
      // Map the nested addressId object from your API
      deliveryAddress: json['addressId'] is Map ? json['addressId'] : null,
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }

  OrderModel copyWith({String? status}) {
    return OrderModel(
      id: id,
      items: items,
      deliveryAddress: deliveryAddress,
      status: status ?? this.status,
      totalAmount: totalAmount,
      otp: otp,
      createdAt: createdAt,
    );
  }
}

class OrderItem {
  final String productTitle;
  final int quantity;
  final double price;
  final String? imageUrl;

  OrderItem({
    required this.productTitle,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productTitle: json['productTitle'] ?? 'Unknown Product',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
    );
  }
}
