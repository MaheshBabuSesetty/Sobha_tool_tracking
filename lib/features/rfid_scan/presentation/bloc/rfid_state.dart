/// RFID BLoC state.
///
/// Single immutable state class containing all RFID scan information.
/// Uses computed properties for power conversion.
library;

import 'package:equatable/equatable.dart';

import '../../domain/entities/rfid_tag.dart';

/// Connection state of the RFID hardware.
enum RfidConnectionState {
  /// Initial state, not yet connected
  idle,

  /// Attempting to connect to RFID hardware
  connecting,

  /// Successfully connected and ready
  connected,

  /// Connection attempt failed
  failed,

  /// Previously connected but now disconnected
  disconnected,
}

/// Extension to parse connection state from string.
extension RfidConnectionStateX on RfidConnectionState {
  static RfidConnectionState fromString(String state) {
    return switch (state) {
      'idle' => RfidConnectionState.idle,
      'connecting' => RfidConnectionState.connecting,
      'connected' => RfidConnectionState.connected,
      'failed' => RfidConnectionState.failed,
      'disconnected' => RfidConnectionState.disconnected,
      _ => RfidConnectionState.idle,
    };
  }

  /// Whether the hardware is ready for operations.
  bool get isReady => this == RfidConnectionState.connected;

  /// Whether a connection attempt is in progress.
  bool get isConnecting => this == RfidConnectionState.connecting;

  /// Whether the connection has failed or been lost.
  bool get hasError =>
      this == RfidConnectionState.failed ||
      this == RfidConnectionState.disconnected;
}

/// State for RFID scan feature.
///
/// Contains all information needed for the UI:
/// - Connection state
/// - Scanning status
/// - Power level (raw and computed)
/// - Scanned tags
/// - Error information
class RfidState extends Equatable {
  /// Current connection state of RFID hardware.
  final RfidConnectionState connectionState;

  /// Whether a scan is currently in progress.
  final bool isScanning;

  /// Current power level (raw value 0-3300, unit: 0.01 dBm).
  final int currentPower;

  /// List of unique scanned tags (deduplicated by EPC).
  final List<RfidTag> tags;

  /// Total read count across all tags.
  final int totalTagCount;

  /// Error message if any error occurred.
  final String? errorMessage;

  /// Whether an error is currently active.
  final bool isError;

  const RfidState({
    this.connectionState = RfidConnectionState.idle,
    this.isScanning = false,
    this.currentPower = 2700,
    this.tags = const [],
    this.totalTagCount = 0,
    this.errorMessage,
    this.isError = false,
  });

  /// Power level in dBm (0.00 - 33.00).
  double get powerDbm => currentPower / 100.0;

  /// Power level as percentage (0.0 - 1.0).
  double get powerPercent => currentPower / 3300.0;

  /// Whether the hardware is ready for operations.
  bool get isReady => connectionState.isReady;

  /// Number of unique tags scanned.
  int get uniqueTagCount => tags.length;

  /// Creates a copy with the specified fields replaced.
  RfidState copyWith({
    RfidConnectionState? connectionState,
    bool? isScanning,
    int? currentPower,
    List<RfidTag>? tags,
    int? totalTagCount,
    String? errorMessage,
    bool? isError,
  }) {
    return RfidState(
      connectionState: connectionState ?? this.connectionState,
      isScanning: isScanning ?? this.isScanning,
      currentPower: currentPower ?? this.currentPower,
      tags: tags ?? this.tags,
      totalTagCount: totalTagCount ?? this.totalTagCount,
      errorMessage: errorMessage ?? this.errorMessage,
      isError: isError ?? this.isError,
    );
  }

  /// Creates a copy with error cleared.
  RfidState clearError() {
    return copyWith(
      errorMessage: null,
      isError: false,
    );
  }

  /// Creates a copy with error set.
  RfidState withError(String message) {
    return copyWith(
      errorMessage: message,
      isError: true,
    );
  }

  @override
  List<Object?> get props => [
        connectionState,
        isScanning,
        currentPower,
        tags,
        totalTagCount,
        errorMessage,
        isError,
      ];
}
