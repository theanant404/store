class UserAddress {
  final String? id;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String landmarks;
  final String village;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  UserAddress({
    this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.landmarks,
    required this.village,
    required this.pincode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['_id'],
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      landmarks: json['landmarks'] ?? '',
      village: json['village'] ?? '',
      pincode: json['pincode'] ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'landmarks': landmarks,
      'village': village,
      'pincode': pincode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'isDefault': isDefault,
    };
  }

  UserAddress copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? landmarks,
    String? village,
    String? pincode,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return UserAddress(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      landmarks: landmarks ?? this.landmarks,
      village: village ?? this.village,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
