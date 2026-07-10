// File: lib/utils/env_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Firebase Configuration
  static String get firebaseApiKey => _get('FIREBASE_API_KEY');
  static String get firebaseAuthDomain => _get('FIREBASE_AUTH_DOMAIN');
  static String get firebaseProjectId => _get('FIREBASE_PROJECT_ID');
  static String get firebaseStorageBucket => _get('FIREBASE_STORAGE_BUCKET');
  static String get firebaseMessagingSenderId => _get('FIREBASE_MESSAGING_SENDER_ID');
  static String get firebaseAppId => _get('FIREBASE_APP_ID');
  static String get firebaseMeasurementId => _get('FIREBASE_MEASUREMENT_ID');
  
  // API Configuration
  static String get apiBaseUrl => _get('API_BASE_URL');
  
  // App Configuration
  static String get appName => _get('APP_NAME');
  static String get appVersion => _get('APP_VERSION');
  
  // Feature Flags
  static bool get enableMockMode => _get('ENABLE_MOCK_MODE') == 'true';
  static bool get enableAnalytics => _get('ENABLE_ANALYTICS') == 'true';
  static bool get enableCrashReporting => _get('ENABLE_CRASH_REPORTING') == 'true';
  static bool get enableLocationServices => _get('ENABLE_LOCATION_SERVICES') == 'true';
  static bool get enableEmergencySos => _get('ENABLE_EMERGENCY_SOS') == 'true';
  
  static String _get(String key) {
    return dotenv.env[key] ?? '';
  }
}