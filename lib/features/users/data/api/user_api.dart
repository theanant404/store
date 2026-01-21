import 'dart:convert';
import 'package:store/config/app_config.dart';
import 'package:store/core/network/api_client.dart';
import 'package:store/features/users/data/models/user_model.dart';

class UserApi {
  UserApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  String get _baseUrl => '${AppConfig.apiBaseUrl}/admin/users';

  /// Fetch all users (admin)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _client.get(_baseUrl);
      if (!_client.isSuccess(response)) {
        throw Exception('Failed to fetch users (${response.statusCode})');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      final usersData = data is Map<String, dynamic>
          ? data['users'] ?? data['data']
          : data;
      final rawList = usersData ?? decoded['users'] ?? [];

      if (rawList is List) {
        return rawList
            .map((user) => UserModel.fromJson(user as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  /// Update user role
  Future<String> updateUserRole(String userId, String role) async {
    try {
      final response = await _client.patch(
        '$_baseUrl/$userId/role',
        body: {'role': role},
      );
      print(response.body);
      if (!_client.isSuccess(response)) {
        throw Exception('Failed to update user role (${response.statusCode})');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];

      if (data is String && data.isNotEmpty) {
        return data;
      }
      return role;
    } catch (e) {
      throw Exception('Error updating user role: $e');
    }
  }

  /// Block user
  Future<void> blockUser(String userId) async {
    try {
      final response = await _client.patch(
        '$_baseUrl/$userId/block',
        body: {'blocked': true},
      );

      if (!_client.isSuccess(response)) {
        throw Exception('Failed to block user (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error blocking user: $e');
    }
  }

  /// Unblock user
  Future<void> unblockUser(String userId) async {
    try {
      final response = await _client.patch(
        '$_baseUrl/$userId/unblock',
        body: {'isBlocked': false},
      );
      // print(response.body);

      if (!_client.isSuccess(response)) {
        throw Exception('Failed to unblock user (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error unblocking user: $e');
    }
  }
}
