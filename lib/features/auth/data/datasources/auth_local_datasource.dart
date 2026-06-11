import 'package:power_tool_tracking/core/storage/secure_storage_service.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource({required this.secureStorage});

  final SecureStorageService secureStorage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    final expiry = DateTime.now().add(Duration(seconds: expiresIn));
    await Future.wait([
      secureStorage.saveAccessToken(accessToken),
      secureStorage.saveRefreshToken(refreshToken),
      secureStorage.saveTokenExpiry(expiry),
    ]);
  }

  Future<String?> getAccessToken() => secureStorage.getAccessToken();
  Future<String?> getRefreshToken() => secureStorage.getRefreshToken();
  Future<DateTime?> getTokenExpiry() => secureStorage.getTokenExpiry();

  Future<bool> isAuthenticated() => secureStorage.isAuthenticated();

  Future<void> saveUserId(String userId) => secureStorage.saveUserId(userId);
  Future<String?> getUserId() => secureStorage.getUserId();

  Future<void> saveUserEmail(String email) => secureStorage.saveUserEmail(email);
  Future<String?> getUserEmail() => secureStorage.getUserEmail();

  Future<void> saveUserName(String name) => secureStorage.saveUserName(name);
  Future<String?> getUserName() => secureStorage.getUserName();

  Future<void> saveUserRole(String role) => secureStorage.saveUserRole(role);
  Future<String?> getUserRole() => secureStorage.getUserRole();

  Future<void> saveUserPhone(String phone) => secureStorage.saveUserPhone(phone);
  Future<String?> getUserPhone() => secureStorage.getUserPhone();

  Future<void> saveUserDesignation(String designation) =>
      secureStorage.saveUserDesignation(designation);
  Future<String?> getUserDesignation() => secureStorage.getUserDesignation();

  Future<void> saveUserSiteName(String siteName) =>
      secureStorage.saveUserSiteName(siteName);
  Future<String?> getUserSiteName() => secureStorage.getUserSiteName();

  Future<void> clearAll() => secureStorage.clearAll();
}
