import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';
import 'package:power_tool_tracking/features/pm/domain/entities/pm_request_entity.dart';
import 'package:power_tool_tracking/features/pm/domain/usecases/get_pm_request_detail_usecase.dart';
import 'package:power_tool_tracking/features/pm/domain/usecases/get_pm_requests_usecase.dart';
import 'package:power_tool_tracking/features/pm/domain/usecases/pm_issue_tool_usecase.dart';

part 'pm_event.dart';
part 'pm_state.dart';

class PmBloc extends Bloc<PmEvent, PmState> {
  PmBloc({
    required GetPmRequestsUseCase getRequests,
    required GetPmRequestDetailUseCase getRequestDetail,
    required PmIssueToolUseCase issueTool,
  })  : _getRequests = getRequests,
        _getRequestDetail = getRequestDetail,
        _issueTool = issueTool,
        super(const PmInitial()) {
    on<PmRequestsLoadRequested>(_onRequestsLoad, transformer: droppable());
    on<PmRequestDetailLoadRequested>(_onDetailLoad, transformer: droppable());
    on<PmIssueToolRequested>(_onIssueTool, transformer: droppable());
    on<PmScanAndIssueRequested>(_onScanAndIssue, transformer: sequential());
  }

  final GetPmRequestsUseCase _getRequests;
  final GetPmRequestDetailUseCase _getRequestDetail;
  final PmIssueToolUseCase _issueTool;

  Future<void> _onRequestsLoad(
    PmRequestsLoadRequested event,
    Emitter<PmState> emit,
  ) async {
    emit(const PmLoading());
    final result = await _getRequests();
    result.fold(
      onSuccess: (requests) => emit(PmRequestsLoaded(requests)),
      onFailure: (failure) {
        AppLogger.warning('PM requests load failed: ${failure.message}');
        emit(PmError(failure.message));
      },
    );
  }

  Future<void> _onDetailLoad(
    PmRequestDetailLoadRequested event,
    Emitter<PmState> emit,
  ) async {
    emit(const PmLoading());
    final result = await _getRequestDetail(event.requestId);
    result.fold(
      onSuccess: (detail) => emit(PmRequestDetailLoaded(detail)),
      onFailure: (failure) {
        AppLogger.warning('PM request detail load failed: ${failure.message}');
        emit(PmError(failure.message));
      },
    );
  }

  Future<void> _onIssueTool(
    PmIssueToolRequested event,
    Emitter<PmState> emit,
  ) async {
    emit(const PmLoading());
    final result = await _issueTool(
      requestId: event.requestId,
      toolId: event.toolId,
      remarks: event.remarks,
    );
    result.fold(
      onSuccess: (response) {
        AppLogger.info(
          'Tool issued: ${response.message} (req: ${event.requestId})',
        );
        emit(PmActionSuccess(response: response, requestId: event.requestId));
      },
      onFailure: (failure) {
        AppLogger.warning('PM issue tool failed: ${failure.message}');
        emit(PmError(failure.message));
      },
    );
  }

  Future<void> _onScanAndIssue(
    PmScanAndIssueRequested event,
    Emitter<PmState> emit,
  ) async {
    emit(const PmLoading());

    final match = event.availableStocks.where(
      (s) => s.rfidTag == event.rfidCode,
    ).firstOrNull;

    if (match == null) {
      AppLogger.info('RFID scan: no match for ${event.rfidCode}');
      emit(const PmScanNoMatch());
      return;
    }

    AppLogger.info('RFID scan matched tool ${match.id}, issuing...');
    final issueResult = await _issueTool(
      requestId: event.requestId,
      toolId: match.id,
    );
    issueResult.fold(
      onSuccess: (response) {
        AppLogger.info('Auto-issued via RFID: ${response.message}');
        emit(PmActionSuccess(response: response, requestId: event.requestId));
      },
      onFailure: (failure) {
        AppLogger.warning('Auto-issue failed: ${failure.message}');
        emit(PmError(failure.message));
      },
    );
  }
}
