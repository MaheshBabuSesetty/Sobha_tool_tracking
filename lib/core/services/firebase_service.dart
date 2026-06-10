import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';
import 'package:power_tool_tracking/flavors/environment_config.dart';

class FirebaseService {
  FirebaseService._();

  static Future<void> initialize() async {
    await Firebase.initializeApp();

    await _initializeCrashlytics();
    await _initializeAnalytics();
    await _initializeRemoteConfig();
    await _initializeMessaging();
  }

  static Future<void> _initializeCrashlytics() async {
    if (!EnvironmentConfig.enableCrashlytics) return;

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static Future<void> _initializeAnalytics() async {
    if (!EnvironmentConfig.enableAnalytics) return;

    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);
  }

  static Future<void> _initializeRemoteConfig() async {
    if (!EnvironmentConfig.enableRemoteConfig) return;

    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: EnvironmentConfig.isDev
            ? const Duration(minutes: 5)
            : const Duration(hours: 12),
      ),
    );

    await remoteConfig.setDefaults({
      'maintenance_mode': false,
      'min_app_version': '1.0.0',
      'sync_interval_minutes': EnvironmentConfig.syncIntervalMinutes,
      'enable_qr_scanning': true,
      'enable_location_tracking': true,
    });

    try {
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      AppLogger.warning('Remote config fetch failed, using cached values', e);
    }
  }

  static Future<void> _initializeMessaging() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    AppLogger.info('Firebase messaging permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  static Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (!EnvironmentConfig.enableAnalytics) return;
    await FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
  }

  static Future<void> setUserId(String userId) async {
    if (!EnvironmentConfig.enableAnalytics) return;
    await FirebaseAnalytics.instance.setUserId(id: userId);
  }

  static Future<void> setUserProperty(String name, String value) async {
    if (!EnvironmentConfig.enableAnalytics) return;
    await FirebaseAnalytics.instance.setUserProperty(name: name, value: value);
  }

  static Future<void> logScreenView(String screenName) async {
    if (!EnvironmentConfig.enableAnalytics) return;
    await FirebaseAnalytics.instance.logScreenView(screenName: screenName);
  }
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.info('Background FCM message: ${message.messageId}');
}
