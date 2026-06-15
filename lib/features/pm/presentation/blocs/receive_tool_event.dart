part of 'receive_tool_bloc.dart';

abstract class ReceiveToolEvent extends Equatable {
  const ReceiveToolEvent();

  @override
  List<Object?> get props => [];
}

class ReceiveToolListLoadRequested extends ReceiveToolEvent {
  const ReceiveToolListLoadRequested();
}

class ReceiveToolConfirmRequested extends ReceiveToolEvent {
  const ReceiveToolConfirmRequested(this.movementId);
  final int movementId;

  @override
  List<Object?> get props => [movementId];
}