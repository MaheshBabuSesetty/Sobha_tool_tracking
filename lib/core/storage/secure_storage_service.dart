import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:power_tool_tracking/core/constants/storage_keys.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';

class SecureStorageService {
  SecureStorageService() : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

  final FlutterSecureStorage _storage;

  Future<void> saveAccessToken(String token) =>
      _write(StorageKeys.accessToken, token);

  Future<String?> getAccessToken() => _read(StorageKeys.accessToken);

  Future<void> saveRefreshToken(String token) =>
      _write(StorageKeys.refreshToken, token);

  Future<String?> getRefreshToken() => _read(StorageKeys.refreshToken);

  Future<void> saveTokenExpiry(DateTime expiry) =>
      _write(StorageKeys.tokenExpiry, expiry.toIso8601String());

  Future<DateTime?> getTokenExpiry() async {
    final value = await _read(StorageKeys.tokenExpiry);
    return value != null ? DateTime.tryParse(value) : null;
  }

  Future<void> saveUserId(String userId) => _write(StorageKeys.userId, userId);
  Future<String?> getUserId() => _read(StorageKeys.userId);

  Future<void> saveUserEmail(String email) => _write(StorageKeys.userEmail, email);
  Future<String?> getUserEmail() => _read(StorageKeys.userEmail);

  Future<void> saveUserRole(String role) => _write(StorageKeys.userRole, role);
  Future<String?> getUserRole() => _read(StorageKeys.userRole);

  Future<void> saveDeviceId(String deviceId) => _write(StorageKeys.deviceId, deviceId);
  Future<String?> getDeviceId() => _read(StorageKeys.deviceId);

  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    if (token == null) return false;

    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return expiry.isAfter(DateTime.now());
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _delete(StorageKeys.accessToken),
      _delete(StorageKeys.refreshToken),
      _delete(StorageKeys.tokenExpiry),
    ]);
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      AppLogger.error('Failed to clear secure storage', e);
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      AppLogger.error('SecureStorage write error for key: $key', e);
      rethrow;
    }
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      AppLogger.error('SecureStorage read error for key: $key', e);
      return null;
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      AppLogger.error('SecureStorage delete error for key: $key', e);
    }
  }
}
