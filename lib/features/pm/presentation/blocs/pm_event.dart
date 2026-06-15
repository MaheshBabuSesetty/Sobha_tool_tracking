part of 'pm_bloc.dart';

abstract class PmEvent extends Equatable {
  const PmEvent();

  @override
  List<Object?> get props => [];
}

class PmRequestsLoadRequested extends PmEvent {
  const PmRequestsLoadRequested();
}

class PmRequestDetailLoadRequested extends PmEvent {
  const PmRequestDetailLoadRequested(this.requestId);
  final int requestId;

  @override
  List<Object?> get props => [requestId];
}

class PmIssueToolRequested extends PmEvent {
  const PmIssueToolRequested({
    required this.requestId,
    required this.toolId,
    this.remarks,
  });
  final int requestId;
  final int toolId;
  final String? remarks;

  @override
  List<Object?> get props => [requestId, toolId, remarks];
}

class PmScanAndIssueRequested extends PmEvent {
  const PmScanAndIssueRequested({
    required this.rfidCode,
    required this.requestId,
    required this.availableStocks,
  });
  final String rfidCode;
  final int requestId;
  final List<AvailableStockEntity> availableStocks;

  @override
  List<Object?> get props => [rfidCode, requestId, availableStocks];
}
