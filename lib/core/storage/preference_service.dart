import 'package:flutter/material.dart';
import 'package:power_tool_tracking/core/constants/storage_keys.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  PreferenceService._();

  static late SharedPreferences _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme
  static ThemeMode get themeMode {
    final value = _prefs.getString(StorageKeys.themeMode);
    return switch (value) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(StorageKeys.themeMode, value);
  }

  // First launch
  static bool get isFirstLaunch => _prefs.getBool(StorageKeys.isFirstLaunch) ?? true;

  static Future<void> setFirstLaunchDone() =>
      _prefs.setBool(StorageKeys.isFirstLaunch, false);

  // Last sync
  static DateTime? get lastSyncAt {
    final value = _prefs.getString(StorageKeys.lastSyncAt);
    return value != null ? DateTime.tryParse(value) : null;
  }

  static Future<void> setLastSyncAt(DateTime dateTime) =>
      _prefs.setString(StorageKeys.lastSyncAt, dateTime.toIso8601String());

  // Notifications
  static bool get notificationsEnabled =>
      _prefs.getBool(StorageKeys.notificationsEnabled) ?? true;

  static Future<void> setNotificationsEnabled(bool enabled) =>
      _prefs.setBool(StorageKeys.notificationsEnabled, enabled);

  // FCM Token
  static String? get fcmToken => _prefs.getString(StorageKeys.fcmToken);

  static Future<void> setFcmToken(String token) =>
      _prefs.setString(StorageKeys.fcmToken, token);

  // Selected Project
  static String? get selectedProjectId => _prefs.getString(StorageKeys.selectedProjectId);

  static Future<void> setSelectedProjectId(String? id) async {
    if (id == null) {
      await _prefs.remove(StorageKeys.selectedProjectId);
    } else {
      await _prefs.setString(StorageKeys.selectedProjectId, id);
    }
  }

  // Tool Sort
  static String get toolSortOrder => _prefs.getString(StorageKeys.toolSortOrder) ?? 'name_asc';

  static Future<void> setToolSortOrder(String order) =>
      _prefs.setString(StorageKeys.toolSortOrder, order);

  // Generic helpers
  static Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  static bool? getBool(String key) => _prefs.getBool(key);

  static Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  static String? getString(String key) => _prefs.getString(key);

  static Future<bool> remove(String key) => _prefs.remove(key);

  static Future<void> clearAll() async {
    try {
      await _prefs.clear();
    } catch (e) {
      AppLogger.error('PreferenceService clearAll error', e);
    }
  }
}
