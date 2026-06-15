part of 'receive_tool_bloc.dart';

abstract class ReceiveToolState extends Equatable {
  const ReceiveToolState();

  @override
  List<Object?> get props => [];
}

class ReceiveToolInitial extends ReceiveToolState {
  const ReceiveToolInitial();
}

class ReceiveToolLoading extends ReceiveToolState {
  const ReceiveToolLoading();
}

class ReceiveToolListLoaded extends ReceiveToolState {
  const ReceiveToolListLoaded(this.items);
  final List<ToolToReceiveEntity> items;

  @override
  List<Object?> get props => [items];
}

class ReceiveToolConfirmSuccess extends ReceiveToolState {
  const ReceiveToolConfirmSuccess(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class ReceiveToolError extends ReceiveToolState {
  const ReceiveToolError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}