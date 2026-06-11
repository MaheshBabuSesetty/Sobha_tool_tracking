library;

import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/entities/rfid_tag.dart';

abstract class RfidRepository {
  Future<Result<bool>> initialize();
  Future<Result<bool>> startScan();
  Future<Result<bool>> stopScan();
  Future<Result<bool>> setPower(int power);
  Future<Result<int>> getPower();
  Stream<Result<RfidTag>> watchTags();
  Stream<String> watchConnectionState();
  Future<Result<bool>> dispose();
}
