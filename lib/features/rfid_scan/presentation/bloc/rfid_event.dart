/// RFID BLoC events.
///
/// These events represent all possible user actions and system events
/// that can occur in the RFID scan feature.
library;

import 'package:equatable/equatable.dart';

import '../../domain/entities/rfid_tag.dart';

/// Base class for all RFID events.
sealed class RfidEvent extends Equatable {
  const RfidEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the RFID hardware.
///
/// Should be dispatched when the RFID screen is first loaded.
final class RfidInitializeEvent extends RfidEvent {
  const RfidInitializeEvent();
}

/// Event to start scanning for RFID tags.
final class RfidStartScanEvent extends RfidEvent {
  const RfidStartScanEvent();
}

/// Event to stop the current scanning operation.
final class RfidStopScanEvent extends RfidEvent {
  const RfidStopScanEvent();
}

/// Event dispatched when a new tag is received from the scanner.
///
/// Internal event - BLoC listens to tag stream and dispatches this.
final class RfidTagReceivedEvent extends RfidEvent {
  final RfidTag tag;

  const RfidTagReceivedEvent(this.tag);

  @override
  List<Object?> get props => [tag];
}

/// Event to set the RFID reader power level.
///
/// [power] is raw value 0-3300 (unit: 0.01 dBm).
/// Example: 2700 = 27.00 dBm
final class RfidSetPowerEvent extends RfidEvent {
  final int power;

  const RfidSetPowerEvent(this.power);

  @override
  List<Object?> get props => [power];
}

/// Event to clear all scanned tags from the list.
final class RfidClearTagsEvent extends RfidEvent {
  const RfidClearTagsEvent();
}

/// Event dispatched when an error occurs.
///
/// Internal event for propagating errors from streams.
final class RfidErrorEvent extends RfidEvent {
  final String message;

  const RfidErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}

/// Event dispatched when connection state changes.
///
/// Internal event - BLoC listens to connection state stream.
/// States: 'idle', 'connecting', 'connected', 'failed', 'disconnected'
final class RfidConnectionStateChangedEvent extends RfidEvent {
  final String state;

  const RfidConnectionStateChangedEvent(this.state);

  @override
  List<Object?> get props => [state];
}

/// Event to flush pending tag updates to UI.
///
/// Internal event used by debounce timer.
final class RfidFlushTagsEvent extends RfidEvent {
  const RfidFlushTagsEvent();
}

/// Event to dispose RFID resources.
///
/// Should be dispatched when leaving the RFID feature.
final class RfidDisposeEvent extends RfidEvent {
  const RfidDisposeEvent();
}
