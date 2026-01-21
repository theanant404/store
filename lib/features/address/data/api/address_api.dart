import 'package:store/config/app_config.dart';
import 'package:store/core/network/api_client.dart';
import 'package:store/features/address/data/models/address_model.dart';

/// Address API helper for fetching and managing addresses from the backend.
class AddressApi {
  AddressApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Base URL for the address API.
  String get _baseUrl => '${AppConfig.apiBaseUrl}/addresses';

  /// Fetch all addresses for current user.
  Future<List<UserAddress>> fetchAddresses() async {
    try {
      final response = await _client.get(_baseUrl);

      if (!_client.isSuccess(response)) {
        throw Exception('Failed to fetch addresses (${response.statusCode})');
      }

      final decoded = _client.decodeResponse(response);
      final addressesJson = decoded['data'] ?? [];

      return (addressesJson as List)
          .map((a) => UserAddress.fromJson(a as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching addresses: $e');
    }
  }

  /// Create new address.
  Future<UserAddress> createAddress(UserAddress address) async {
    try {
      final response = await _client.post(_baseUrl, body: address.toJson());

      if (!_client.isSuccess(response)) {
        final errorMsg = _client.getErrorMessage(response);
        throw Exception(errorMsg);
      }

      final decoded = _client.decodeResponse(response);
      return UserAddress.fromJson(decoded['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error creating address: $e');
    }
  }

  /// Update existing address.
  Future<UserAddress> updateAddress(String id, UserAddress address) async {
    try {
      final response = await _client.put(
        '$_baseUrl/$id',
        body: address.toJson(),
      );

      if (!_client.isSuccess(response)) {
        final errorMsg = _client.getErrorMessage(response);
        throw Exception(errorMsg);
      }

      final decoded = _client.decodeResponse(response);
      return UserAddress.fromJson(decoded['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error updating address: $e');
    }
  }

  /// Delete address.
  Future<void> deleteAddress(String id) async {
    try {
      final response = await _client.delete('$_baseUrl/$id');

      if (!_client.isSuccess(response)) {
        final errorMsg = _client.getErrorMessage(response);
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Error deleting address: $e');
    }
  }
}

/// In-memory repository for addresses that syncs with the backend.
class AddressRepository {
  // Holds addresses fetched from the backend. Starts empty; populated via fetchAllAddresses.
  static final List<UserAddress> _addresses = [];

  static List<UserAddress> all() => List.unmodifiable(_addresses);

  static final _api = AddressApi();

  /// Fetch all addresses from the API
  static Future<List<UserAddress>> fetchAllAddresses() async {
    try {
      final addresses = await _api.fetchAddresses();
      _addresses.clear();
      _addresses.addAll(addresses);
      return addresses;
    } catch (e) {
      // Fallback to in-memory data if API fails
      return List.unmodifiable(_addresses);
    }
  }

  /// Add a new address via API
  static Future<UserAddress> addAddress(UserAddress address) async {
    final newAddress = await _api.createAddress(address);
    _addresses.add(newAddress);
    return newAddress;
  }

  /// Update an address via API
  static Future<UserAddress> updateAddress(UserAddress updated) async {
    final updatedAddress = await _api.updateAddress(updated.id!, updated);
    final idx = _addresses.indexWhere((a) => a.id == updated.id);
    if (idx != -1) {
      _addresses[idx] = updatedAddress;
    }
    return updatedAddress;
  }

  /// Delete an address via API
  static Future<void> deleteAddress(String id) async {
    await _api.deleteAddress(id);
    _addresses.removeWhere((a) => a.id == id);
  }
}
