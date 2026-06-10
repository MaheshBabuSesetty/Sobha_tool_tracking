class StorageKeys {
  StorageKeys._();

  // Secure Storage Keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenExpiry = 'token_expiry';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userRole = 'user_role';
  static const String deviceId = 'device_id';
  static const String biometricEnabled = 'biometric_enabled';

  // SharedPreferences Keys
  static const String isFirstLaunch = 'is_first_launch';
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
  static const String lastSyncAt = 'last_sync_at';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String fcmToken = 'fcm_token';
  static const String lastAppVersion = 'last_app_version';
  static const String selectedProjectId = 'selected_project_id';
  static const String dashboardLayout = 'dashboard_layout';
  static const String toolSortOrder = 'tool_sort_order';
  static const String toolFilterState = 'tool_filter_state';
}
