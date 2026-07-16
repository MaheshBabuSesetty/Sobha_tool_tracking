class FirebaseService {
  FirebaseService._();

  static Future<void> initialize() async {}

  static Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}

  static Future<void> setUserId(String userId) async {}

  static Future<void> setUserProperty(String name, String value) async {}

  static Future<void> logScreenView(String screenName) async {}
}
