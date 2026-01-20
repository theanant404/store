import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:store/features/auth/data/session_store.dart';

/// Common API client for making authenticated HTTP requests
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Get headers with authorization token and content type
  Map<String, String> _getHeaders({Map<String, String>? additionalHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add authorization token if user is logged in
    final user = SessionStore.currentUser.value;
    if (user != null && user.accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${user.accessToken}';
    }

    // Add any additional headers
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Make a GET request
  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse(url);
      return await _client.get(
        uri,
        headers: _getHeaders(additionalHeaders: headers),
      );
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  /// Make a POST request
  Future<http.Response> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(url);
      return await _client.post(
        uri,
        headers: _getHeaders(additionalHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  /// Make a PUT request
  Future<http.Response> put(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(url);
      return await _client.put(
        uri,
        headers: _getHeaders(additionalHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  /// Make a PATCH request
  Future<http.Response> patch(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(url);
      return await _client.patch(
        uri,
        headers: _getHeaders(additionalHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );
    } catch (e) {
      throw Exception('PATCH request failed: $e');
    }
  }

  /// Make a DELETE request
  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(url);
      return await _client.delete(
        uri,
        headers: _getHeaders(additionalHeaders: headers),
      );
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  /// Helper method to check if response is successful
  bool isSuccess(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// Helper method to decode JSON response
  Map<String, dynamic> decodeResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to decode response: $e');
    }
  }

  /// Helper method to handle API errors
  String getErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return decoded['message'] ?? decoded['error'] ?? 'Request failed';
    } catch (e) {
      return 'Request failed with status ${response.statusCode}';
    }
  }
}
