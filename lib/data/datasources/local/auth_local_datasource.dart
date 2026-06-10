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

  Future<void> saveUserRole(String role) => secureStorage.saveUserRole(role);
  Future<String?> getUserRole() => secureStorage.getUserRole();

  Future<void> clearAll() => secureStorage.clearAll();
}
