import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';
import 'package:power_tool_tracking/features/pm/domain/entities/pm_request_entity.dart';
import 'package:power_tool_tracking/features/pm/domain/usecases/confirm_tool_receipt_usecase.dart';
import 'package:power_tool_tracking/features/pm/domain/usecases/get_tools_to_receive_usecase.dart';

part 'receive_tool_event.dart';
part 'receive_tool_state.dart';

class ReceiveToolBloc extends Bloc<ReceiveToolEvent, ReceiveToolState> {
  ReceiveToolBloc({
    required GetToolsToReceiveUseCase getToolsToReceive,
    required ConfirmToolReceiptUseCase confirmReceipt,
  })  : _getToolsToReceive = getToolsToReceive,
        _confirmReceipt = confirmReceipt,
        super(const ReceiveToolInitial()) {
    on<ReceiveToolListLoadRequested>(_onLoad, transformer: droppable());
    on<ReceiveToolConfirmRequested>(_onConfirm, transformer: droppable());
  }

  final GetToolsToReceiveUseCase _getToolsToReceive;
  final ConfirmToolReceiptUseCase _confirmReceipt;

  Future<void> _onLoad(
    ReceiveToolListLoadRequested event,
    Emitter<ReceiveToolState> emit,
  ) async {
    emit(const ReceiveToolLoading());
    final result = await _getToolsToReceive();
    result.fold(
      onSuccess: (items) => emit(ReceiveToolListLoaded(items)),
      onFailure: (f) {
        AppLogger.warning('Tools to receive load failed: ${f.message}');
        emit(ReceiveToolError(f.message));
      },
    );
  }

  Future<void> _onConfirm(
    ReceiveToolConfirmRequested event,
    Emitter<ReceiveToolState> emit,
  ) async {
    emit(const ReceiveToolLoading());
    final result = await _confirmReceipt(event.movementId);
    result.fold(
      onSuccess: (res) {
        AppLogger.info('Tool receipt confirmed: ${res.message}');
        emit(ReceiveToolConfirmSuccess(res.message));
      },
      onFailure: (f) {
        AppLogger.warning('Receipt confirm failed: ${f.message}');
        emit(ReceiveToolError(f.message));
      },
    );
  }
}