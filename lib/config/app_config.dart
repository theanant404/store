import 'package:flutter/foundation.dart';

class AppConfig {
  // Get API base URL from environment or use default
  static String get apiBaseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) {
      if (kDebugMode) {
        print('✅ API Base URL loaded: $envUrl');
      }
      return envUrl;
    }

    // Default based on environment
    if (kDebugMode) {
      print('⚠️ Using default API URL for development');
      return 'http://localhost:8080/api/v1';
    }

    return 'https://api.example.com/api/v1'; // Production URL
  }

  // Get Google Client ID from environment
  static String get googleClientId {
    const clientId = String.fromEnvironment(
      'GOOGLE_CLIENT_ID',
      defaultValue: '',
    );
    if (clientId.isEmpty) {
      if (kDebugMode) {
        print('⚠️ GOOGLE_CLIENT_ID not set');
      }
    }
    return clientId;
  }

  // Check if all required configs are set
  static bool get isConfigValid {
    return apiBaseUrl.isNotEmpty && googleClientId.isNotEmpty;
  }

  // Debug: Print all config values
  static void debugPrintConfig() {
    if (kDebugMode) {
      print('=== App Config ===');
      print('API Base URL: $apiBaseUrl');
      print(
        'Google Client ID: ${googleClientId.isNotEmpty ? '***' : 'NOT SET'}',
      );
      print('Config Valid: $isConfigValid');
    }
  }
}
