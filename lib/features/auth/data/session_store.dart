import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple in-memory session holder for the logged-in user.
class UserSession {
  const UserSession({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
    required this.isEmailVerified,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String accessToken;
  final String refreshToken;
  final bool isEmailVerified;

  factory UserSession.fromApi(Map<String, dynamic> json) {
    final user = (json['data'] ?? {})['user'] ?? {};
    return UserSession(
      id: user['_id']?.toString() ?? '',
      name: user['name']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      role: user['role']?.toString() ?? '',
      accessToken: (json['data'] ?? {})['accessToken']?.toString() ?? '',
      refreshToken: (json['data'] ?? {})['refreshToken']?.toString() ?? '',
      isEmailVerified: user['isEmailVerified'] == true,
    );
  }

  factory UserSession.basic({
    required String email,
    required String name,
    String id = '',
    String role = '',
    String accessToken = '',
    String refreshToken = '',
    bool isEmailVerified = false,
  }) {
    return UserSession(
      id: id,
      name: name,
      email: email,
      role: role,
      accessToken: accessToken,
      refreshToken: refreshToken,
      isEmailVerified: isEmailVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'isEmailVerified': isEmailVerified,
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      isEmailVerified: json['isEmailVerified'] == true,
    );
  }
}

class SessionStore {
  static final ValueNotifier<UserSession?> currentUser =
      ValueNotifier<UserSession?>(null);

  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyIsEmailVerified = 'is_email_verified';

  /// Save user session to persistent storage
  static Future<void> setUser(UserSession user) async {
    currentUser.value = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, user.id);
    await prefs.setString(_keyUserName, user.name);
    await prefs.setString(_keyUserEmail, user.email);
    await prefs.setString(_keyUserRole, user.role);
    await prefs.setString(_keyAccessToken, user.accessToken);
    await prefs.setString(_keyRefreshToken, user.refreshToken);
    await prefs.setBool(_keyIsEmailVerified, user.isEmailVerified);
  }

  /// Load user session from persistent storage
  static Future<UserSession?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    final id = prefs.getString(_keyUserId);
    if (id == null || id.isEmpty) {
      return null;
    }

    final session = UserSession(
      id: id,
      name: prefs.getString(_keyUserName) ?? '',
      email: prefs.getString(_keyUserEmail) ?? '',
      role: prefs.getString(_keyUserRole) ?? '',
      accessToken: prefs.getString(_keyAccessToken) ?? '',
      refreshToken: prefs.getString(_keyRefreshToken) ?? '',
      isEmailVerified: prefs.getBool(_keyIsEmailVerified) ?? false,
    );

    currentUser.value = session;
    return session;
  }

  /// Clear user session from both memory and persistent storage
  static Future<void> clear() async {
    currentUser.value = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyIsEmailVerified);
  }

  /// Check if user is logged in
  static bool get isLoggedIn => currentUser.value != null;
}
