part of 'pm_bloc.dart';

abstract class PmState extends Equatable {
  const PmState();

  @override
  List<Object?> get props => [];
}

class PmInitial extends PmState {
  const PmInitial();
}

class PmLoading extends PmState {
  const PmLoading();
}

class PmRequestsLoaded extends PmState {
  const PmRequestsLoaded(this.requests);
  final List<PmRequestEntity> requests;

  @override
  List<Object?> get props => [requests];
}

class PmRequestDetailLoaded extends PmState {
  const PmRequestDetailLoaded(this.detail);
  final PmRequestDetailEntity detail;

  @override
  List<Object?> get props => [detail];
}

class PmActionSuccess extends PmState {
  const PmActionSuccess({required this.response, required this.requestId});
  final ActionResponseEntity response;
  final int requestId;

  @override
  List<Object?> get props => [response, requestId];
}

class PmError extends PmState {
  const PmError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
