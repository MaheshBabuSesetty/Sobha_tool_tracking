import 'dart:async';

import 'package:flutter/services.dart';

import 'package:power_tool_tracking/core/errors/app_exception.dart';
import 'package:power_tool_tracking/features/scan/data/models/rfid_tag_model.dart';

/// Abstract interface for RFID local data source.
abstract class RfidLocalDatasource {
  /// Initializes the RFID hardware.
  Future<bool> initialize();

  /// Starts scanning for RFID tags.
  Future<bool> startScan();

  /// Stops the current scan operation.
  Future<bool> stopScan();

  /// Sets the RFID reader power level.
  /// [power] is raw value 0–3300 (unit: 0.01 dBm).
  Future<bool> setPower(int power);

  /// Gets the current power level.
  /// Returns raw value 0–3300.
  Future<int> getPower();

  /// Stream of scanned RFID tags (type == 'tag' events).
  Stream<RfidTagModel> watchTags();

  /// Stream of connection state changes (type == 'connection_state' events).
  /// Values: 'idle', 'connecting', 'connected', 'failed', 'disconnected'
  Stream<String> watchConnectionState();

  /// Disposes RFID resources.
  Future<bool> dispose();
}

/// Implementation using Flutter platform channels to communicate with the
/// native Newland UHF RFID SDK on Android.
class RfidLocalDatasourceImpl implements RfidLocalDatasource {
  static const MethodChannel _methodChannel = MethodChannel(
    'com.sobha.rfid.tool.tracking/rfid_method',
  );

  static const EventChannel _eventChannel = EventChannel(
    'com.sobha.rfid.tool.tracking/rfid_event',
  );

  Stream<dynamic>? _broadcastStream;

  Stream<dynamic> get _eventStream {
    _broadcastStream ??=
        _eventChannel.receiveBroadcastStream().asBroadcastStream();
    return _broadcastStream!;
  }

  @override
  Future<bool> initialize() async {
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
        message: 'Power must be between 0 and 3300 (0–33.00 dBm)',
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
      return result ?? 2700; // Default: 27.00 dBm
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
