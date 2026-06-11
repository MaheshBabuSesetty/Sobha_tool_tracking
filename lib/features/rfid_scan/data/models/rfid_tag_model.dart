library;

import 'package:power_tool_tracking/features/rfid_scan/domain/entities/rfid_tag.dart';

class RfidTagModel extends RfidTag {
  const RfidTagModel({
    required super.epc,
    required super.rssi,
    required super.antennaId,
    required super.readCount,
    required super.scannedAt,
    required super.lastSeenMs,
  });

  factory RfidTagModel.fromMap(Map<dynamic, dynamic> map) => RfidTagModel(
        epc: ((map['epc'] as String?) ?? '').toUpperCase(),
        rssi: (map['rssi'] as int?) ?? 0,
        antennaId: (map['antennaId'] as int?) ?? 1,
        readCount: (map['readCount'] as int?) ?? 1,
        scannedAt: DateTime.now(),
        lastSeenMs: (map['timestamp'] as int?) ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'epc': epc,
        'rssi': rssi,
        'antennaId': antennaId,
        'readCount': readCount,
        'scannedAt': scannedAt.toIso8601String(),
        'lastSeenMs': lastSeenMs,
      };

  factory RfidTagModel.fromEntity(RfidTag entity) => RfidTagModel(
        epc: entity.epc,
        rssi: entity.rssi,
        antennaId: entity.antennaId,
        readCount: entity.readCount,
        scannedAt: entity.scannedAt,
        lastSeenMs: entity.lastSeenMs,
      );
}
