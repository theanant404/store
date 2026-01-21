class Order {
  final String? id;
  final String userId;
  final List<OrderItem> items;
  final String addressId;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  Order({
    this.id,
    required this.userId,
    required this.items,
    required this.addressId,
    required this.totalAmount,
    required this.paymentMethod,
    this.status = 'pending',
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id']?.toString(),
      userId: json['userId']?.toString() ?? '',
      items:
          (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      addressId: json['addressId']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod']?.toString() ?? 'cod',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'addressId': addressId,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'status': status,
    };
  }
}

class OrderItem {
  final String productId;
  final String varietyId;
  final String productTitle;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.varietyId,
    required this.productTitle,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId']?.toString() ?? '',
      varietyId: json['varietyId']?.toString() ?? '',
      productTitle: json['productTitle']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'varietyId': varietyId,
      'productTitle': productTitle,
      'price': price,
      'quantity': quantity,
    };
  }

  double get subtotal => price * quantity;
}
