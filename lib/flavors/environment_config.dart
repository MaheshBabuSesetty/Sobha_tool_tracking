import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:power_tool_tracking/flavors/app_flavor.dart';

class EnvironmentConfig {
  EnvironmentConfig._();

  static late AppFlavor _flavor;

  static AppFlavor get flavor => _flavor;

  static Future<void> initialize(AppFlavor flavor) async {
    _flavor = flavor;
    await dotenv.load(fileName: flavor.envFile);
  }

  static String get apiBaseUrl => _get('API_BASE_URL');
  static int get apiTimeout => int.parse(_get('API_TIMEOUT', fallback: '30000'));
  static String get appName => _get('APP_NAME', fallback: 'Power Tool Tracking');
  static String get flavorName => _get('FLAVOR', fallback: 'PROD');
  static String get googleMapKey => _get('GOOGLE_MAP_KEY', fallback: '');
  static String get firebaseApiKey => _get('FIREBASE_API_KEY', fallback: '');
  static String get firebaseAppId => _get('FIREBASE_APP_ID', fallback: '');
  static String get firebaseProjectId => _get('FIREBASE_PROJECT_ID', fallback: '');
  static String get firebaseMessagingSenderId => _get('FIREBASE_MESSAGING_SENDER_ID', fallback: '');
  static String get firebaseStorageBucket => _get('FIREBASE_STORAGE_BUCKET', fallback: '');
  static List<String> get sslPins {
    final pins = _get('SSL_PINS', fallback: '');
    return pins.isEmpty ? [] : pins.split(',').map((e) => e.trim()).toList();
  }

  static bool get enableAnalytics => _getBool('ENABLE_ANALYTICS', fallback: true);
  static bool get enableCrashlytics => _getBool('ENABLE_CRASHLYTICS', fallback: true);
  static bool get enableRemoteConfig => _getBool('ENABLE_REMOTE_CONFIG', fallback: true);
  static int get syncIntervalMinutes => int.parse(_get('SYNC_INTERVAL_MINUTES', fallback: '15'));
  static int get offlineCacheDays => int.parse(_get('OFFLINE_CACHE_DAYS', fallback: '30'));

  static bool get isProduction => _flavor.isProduction;
  static bool get isDev => _flavor.isDev;

  static String _get(String key, {String fallback = ''}) {
    return dotenv.env[key] ?? fallback;
  }

  static bool _getBool(String key, {bool fallback = false}) {
    final value = dotenv.env[key]?.toLowerCase();
    if (value == null) return fallback;
    return value == 'true' || value == '1';
  }
}
