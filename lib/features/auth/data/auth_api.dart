import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:store/features/auth/data/session_store.dart';

/// Simple auth API helper for account-related network calls.
///
/// Adjust [baseUrl] and endpoints to match your backend.
class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Base URL for the authentication API.
  static const String _baseUrl = 'http://localhost:8080/api/v1/auth';

  /// Registers a new user with email/phone and password.
  /// Returns true when the call succeeds (status 200–299), otherwise throws.
  Future<void> register({
    required String emailOrPhone,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/register');
    final response = await _client.post(
      uri,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'email': emailOrPhone, // email or mobile number
        'password': password,
        'name': emailOrPhone.split('@').first, // simple name extraction
      }),
    );
    // print(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // You can parse error body here if your API returns message field
      throw Exception('Failed to create account (${response.statusCode})');
    }
  }

  /// Logs in with email/phone + password.
  Future<UserSession> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/login');
    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': emailOrPhone, 'password': password}),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(decoded['message'] ?? 'Login failed');
    }

    return UserSession.fromApi(decoded);
  }

  /// Starts a password reset via email/phone.
  Future<void> requestPasswordReset({required String email}) async {
    final uri = Uri.parse('$_baseUrl/forgot-password');
    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to send reset link / OTP (${response.statusCode})',
      );
    }
  }

  Future<void> resetPasswordWithOtp({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    final uri = Uri.parse('$_baseUrl/reset-password');
    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'email': identifier,
        'otp': otp,
        'password': newPassword,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to reset password (${response.statusCode})');
    }
  }
}
