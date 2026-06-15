library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:power_tool_tracking/core/errors/app_exception.dart';
import 'package:power_tool_tracking/features/rfid_scan/data/models/rfid_tag_model.dart';

abstract class RfidLocalDatasource {
  Future<bool> initialize();
  Future<bool> startScan();
  Future<bool> stopScan();
  Future<bool> setPower(int power);
  Future<int> getPower();
  Stream<RfidTagModel> watchTags();
  Stream<String> watchConnectionState();
  Future<bool> dispose();
}

class RfidLocalDatasourceImpl implements RfidLocalDatasource {
  static const MethodChannel _methodChannel = MethodChannel(
    'com.sobha.rfid.tool.tracking/rfid_method',
  );

  static const EventChannel _eventChannel = EventChannel(
    'com.sobha.rfid.tool.tracking/rfid_event',
  );

  Stream<dynamic>? _broadcastStream;

  Stream<dynamic> get _eventStream {
    if (!Platform.isAndroid) return const Stream.empty();
    _broadcastStream ??=
        _eventChannel.receiveBroadcastStream().asBroadcastStream();
    return _broadcastStream!;
  }

  @override
  Future<bool> initialize() async {
    if (!Platform.isAndroid) {
      throw const RfidInitializationException(
        message: 'RFID hardware is only supported on Android',
      );
    }
    try {
      final result = await _methodChannel.invokeMethod<bool>('initialize');
      return result ?? false;
    } on PlatformException catch (e) {
      throw RfidInitializationException(
        message: e.message ?? 'Failed to initialize RFID hardware',
        code: e.code,
      );
    } catch (e) {
      throw RfidInitializationException(
        message: 'Unexpected error during RFID initialization: $e',
      );
    }
  }

  @override
  Future<bool> startScan() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('startScan');
      return result ?? false;
    } on PlatformException catch (e) {
      throw RfidScanException(
        message: e.message ?? 'Failed to start RFID scan',
        code: e.code,
      );
    } catch (e) {
      throw RfidScanException(
        message: 'Unexpected error starting RFID scan: $e',
      );
    }
  }

  @override
  Future<bool> stopScan() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('stopScan');
      return result ?? false;
    } on PlatformException catch (e) {
      throw RfidScanException(
        message: e.message ?? 'Failed to stop RFID scan',
        code: e.code,
      );
    } catch (e) {
      throw RfidScanException(
        message: 'Unexpected error stopping RFID scan: $e',
      );
    }
  }

  @override
  Future<bool> setPower(int power) async {
    if (power < 0 || power > 3300) {
      throw const RfidPowerException(
        message: 'Power must be between 0 and 3300 (0-33.00 dBm)',
      );
    }
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'setPower',
        {'power': power},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw RfidPowerException(
        message: e.message ?? 'Failed to set RFID power',
        code: e.code,
      );
    } catch (e) {
      throw RfidPowerException(
        message: 'Unexpected error setting RFID power: $e',
      );
    }
  }

  @override
  Future<int> getPower() async {
    try {
      final result = await _methodChannel.invokeMethod<int>('getPower');
      return result ?? 2700;
    } on PlatformException catch (e) {
      throw RfidPowerException(
        message: e.message ?? 'Failed to get RFID power',
        code: e.code,
      );
    } catch (e) {
      throw RfidPowerException(
        message: 'Unexpected error getting RFID power: $e',
      );
    }
  }

  @override
  Stream<RfidTagModel> watchTags() => _eventStream
      .where((data) => data is Map && data['type'] == 'tag')
      .map((data) {
        try {
          return RfidTagModel.fromMap(Map<dynamic, dynamic>.from(data as Map));
        } catch (e) {
          throw RfidScanException(message: 'Failed to parse tag data: $e');
        }
      });

  @override
  Stream<String> watchConnectionState() => _eventStream
      .where((data) => data is Map && data['type'] == 'connection_state')
      .map((data) => (data as Map)['state'] as String? ?? 'idle');

  @override
  Future<bool> dispose() async {
    try {
      _broadcastStream = null;
      final result = await _methodChannel.invokeMethod<bool>('dispose');
      return result ?? true;
    } on PlatformException catch (e) {
      throw RfidException(
        message: e.message ?? 'Failed to dispose RFID resources',
        code: e.code,
      );
    } catch (e) {
      throw RfidException(
        message: 'Unexpected error disposing RFID resources: $e',
      );
    }
  }
}
