class OrderItem {
  final String productId;
  final String productTitle;
  final String varietyId;
  final int quantity;
  final double price;
  final String? imageUrl;

  const OrderItem({
    required this.productId,
    required this.productTitle,
    required this.varietyId,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId:
          json['productId']?.toString() ?? json['product']?.toString() ?? '',
      productTitle:
          json['productTitle'] as String? ?? json['title'] as String? ?? '',
      varietyId:
          json['varietyId']?.toString() ?? json['variety']?.toString() ?? '',
      quantity: json['quantity'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productTitle': productTitle,
      'varietyId': varietyId,
      'quantity': quantity,
      'price': price,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final List<OrderItem> items;
  final double totalAmount;
  final String
  status; // pending, accepted, preparing, shipped, delivered, cancelled
  final String? deliveryAddress;
  final String? phoneNumber;
  final String? otp;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.deliveryAddress,
    this.phoneNumber,
    this.otp,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List? ?? [];
    // addressId is a string or object in your backend response
    final addressString =
        json['addressId']?.toString() ?? json['deliveryAddress'] as String?;

    return OrderModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user']?.toString() ?? '',
      userName: json['userName'] as String? ?? 'Unknown',
      userEmail: json['userEmail'] as String? ?? '',
      items: itemsJson
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      deliveryAddress: addressString,
      phoneNumber: json['phoneNumber'] as String?,
      otp: json['otp']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (otp != null) 'otp': otp,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    List<OrderItem>? items,
    double? totalAmount,
    String? status,
    String? deliveryAddress,
    String? phoneNumber,
    String? otp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otp: otp ?? this.otp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
