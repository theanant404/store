import 'package:flutter/foundation.dart';

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
}

class SessionStore {
  static final ValueNotifier<UserSession?> currentUser =
      ValueNotifier<UserSession?>(null);

  static void setUser(UserSession user) {
    currentUser.value = user;
  }

  static void clear() {
    currentUser.value = null;
  }
}
