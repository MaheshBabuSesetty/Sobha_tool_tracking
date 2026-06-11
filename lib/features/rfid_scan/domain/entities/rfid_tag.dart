/// RFID Tag entity representing a scanned UHF RFID tag.
///
/// Pure domain entity — zero Flutter imports.
/// Contains core business data for an RFID tag.
library;

import 'package:equatable/equatable.dart';

/// Represents a single RFID tag scanned by the UHF reader.
///
/// The [epc] (Electronic Product Code) is the unique identifier for the tag.
/// [rssi] indicates signal strength in dBm (typically -80 to -20).
/// [scannedAt] records when the tag was first scanned.
/// [lastSeenMs] is the epoch ms of the most recent read.
class RfidTag extends Equatable {
  /// Electronic Product Code — unique hex identifier for the tag.
  /// Example: "E200341280020A1F"
  final String epc;

  /// Received Signal Strength Indicator in dBm.
  /// Typical range: -80 (weak) to -20 (strong).
  final int rssi;

  /// Antenna ID that read the tag.
  final int antennaId;

  /// Cumulative read count for this tag in the current session.
  final int readCount;

  /// Timestamp when the tag was first scanned in this session.
  final DateTime scannedAt;

  /// Epoch milliseconds of the most recent read.
  final int lastSeenMs;

  const RfidTag({
    required this.epc,
    required this.rssi,
    required this.antennaId,
    required this.readCount,
    required this.scannedAt,
    required this.lastSeenMs,
  });

  /// Returns signal strength category based on RSSI value.
  ///
  /// - Excellent: rssi >= -50
  /// - Good: rssi >= -65
  /// - Fair: rssi >= -80
  /// - Weak: rssi < -80
  SignalStrength get signalStrength {
    if (rssi >= -50) return SignalStrength.excellent;
    if (rssi >= -65) return SignalStrength.good;
    if (rssi >= -80) return SignalStrength.fair;
    return SignalStrength.weak;
  }

  /// Creates a copy with updated fields.
  RfidTag copyWith({
    String? epc,
    int? rssi,
    int? antennaId,
    int? readCount,
    DateTime? scannedAt,
    int? lastSeenMs,
  }) {
    return RfidTag(
      epc: epc ?? this.epc,
      rssi: rssi ?? this.rssi,
      antennaId: antennaId ?? this.antennaId,
      readCount: readCount ?? this.readCount,
      scannedAt: scannedAt ?? this.scannedAt,
      lastSeenMs: lastSeenMs ?? this.lastSeenMs,
    );
  }

  @override
  List<Object?> get props => [
        epc,
        rssi,
        antennaId,
        readCount,
        scannedAt,
        lastSeenMs,
      ];

  @override
  String toString() =>
      'RfidTag(epc: $epc, rssi: $rssi, readCount: $readCount)';
}

/// Signal strength categories for RFID tags.
enum SignalStrength {
  /// RSSI >= -50 dBm
  excellent,

  /// RSSI >= -65 dBm
  good,

  /// RSSI >= -80 dBm
  fair,

  /// RSSI < -80 dBm
  weak,
}
