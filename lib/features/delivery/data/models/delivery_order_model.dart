class DeliveryOrderModel {
  final String id;
  final String orderId;
  final String userName;
  final String userEmail;
  final String? phoneNumber;
  final String deliveryAddress;
  final List<DeliveryItem> items;
  final double totalAmount;
  final String status; // shipped, delivered, cancelled
  final String? otp;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DeliveryOrderModel({
    required this.id,
    required this.orderId,
    required this.userName,
    required this.userEmail,
    this.phoneNumber,
    required this.deliveryAddress,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.otp,
    required this.createdAt,
    this.updatedAt,
  });

  factory DeliveryOrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List? ?? [];
    final addressJson = json['addressId'] as Map<String, dynamic>?;
    final addressString = addressJson != null
        ? [
                addressJson['fullName'],
                addressJson['address'],
                addressJson['landmarks'],
                addressJson['village'],
                addressJson['pincode'],
              ]
              .where(
                (part) => part != null && part.toString().trim().isNotEmpty,
              )
              .map((part) => part.toString())
              .join(', ')
        : json['deliveryAddress'] as String? ?? '';

    return DeliveryOrderModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      orderId: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userName:
          json['userName'] as String? ??
          json['user']?['name'] as String? ??
          'Unknown',
      userEmail:
          json['userEmail'] as String? ??
          json['user']?['email'] as String? ??
          '',
      phoneNumber:
          json['phoneNumber'] as String? ??
          addressJson?['phoneNumber'] as String?,
      deliveryAddress: addressString,
      items: itemsJson
          .map((item) => DeliveryItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'shipped',
      otp: json['otp'] as String?,
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
      'orderId': orderId,
      'userName': userName,
      'userEmail': userEmail,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      'deliveryAddress': deliveryAddress,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      if (otp != null) 'otp': otp,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  DeliveryOrderModel copyWith({
    String? id,
    String? orderId,
    String? userName,
    String? userEmail,
    String? phoneNumber,
    String? deliveryAddress,
    List<DeliveryItem>? items,
    double? totalAmount,
    String? status,
    String? otp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryOrderModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      otp: otp ?? this.otp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DeliveryItem {
  final String productId;
  final String productTitle;
  final String varietyId;
  final int quantity;
  final double price;
  final String? imageUrl;

  const DeliveryItem({
    required this.productId,
    required this.productTitle,
    required this.varietyId,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
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
