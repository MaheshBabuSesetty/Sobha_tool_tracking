import 'package:flutter/services.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';

class SecurityService {
  SecurityService._();

  static const _securityChannel = MethodChannel('com.company.powertracking/security');

  static Future<bool> isDeviceRooted() async {
    try {
      final result = await _securityChannel.invokeMethod<bool>('isRooted');
      return result ?? false;
    } on PlatformException catch (e) {
      AppLogger.warning('Root detection failed', e);
      return false;
    }
  }

  static Future<bool> isDeviceJailbroken() async {
    try {
      final result = await _securityChannel.invokeMethod<bool>('isJailbroken');
      return result ?? false;
    } on PlatformException catch (e) {
      AppLogger.warning('Jailbreak detection failed', e);
      return false;
    }
  }

  static Future<void> preventScreenshot({required bool prevent}) async {
    try {
      await _securityChannel.invokeMethod<void>(
        'preventScreenshot',
        {'prevent': prevent},
      );
    } on PlatformException catch (e) {
      AppLogger.warning('Screenshot prevention failed', e);
    }
  }

  static Future<bool> isAppIntegrityValid() async {
    try {
      final result = await _securityChannel.invokeMethod<bool>('checkIntegrity');
      return result ?? true;
    } on PlatformException catch (e) {
      AppLogger.warning('App integrity check failed', e);
      return true;
    }
  }

  static Future<void> performSecurityChecks({
    required void Function() onSecurityViolation,
  }) async {
    final isRooted = await isDeviceRooted();
    final isJailbroken = await isDeviceJailbroken();

    if (isRooted || isJailbroken) {
      AppLogger.warning('Security violation: device is rooted/jailbroken');
      onSecurityViolation();
    }
  }
}
