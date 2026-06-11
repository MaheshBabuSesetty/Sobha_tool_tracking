import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';
import 'package:power_tool_tracking/features/tools/domain/entities/tool_entity.dart';
import 'package:power_tool_tracking/features/tools/domain/repositories/tool_repository.dart';
import 'package:power_tool_tracking/features/tools/domain/usecases/checkin_tool_usecase.dart';
import 'package:power_tool_tracking/features/tools/domain/usecases/checkout_tool_usecase.dart';
import 'package:power_tool_tracking/features/tools/domain/usecases/create_tool_usecase.dart';
import 'package:power_tool_tracking/features/tools/domain/usecases/delete_tool_usecase.dart';
import 'package:power_tool_tracking/features/tools/domain/usecases/get_tools_usecase.dart';
import 'package:power_tool_tracking/features/tools/domain/usecases/sync_tools_usecase.dart';
import 'package:power_tool_tracking/features/tools/domain/usecases/update_tool_usecase.dart';

part 'tool_event.dart';
part 'tool_state.dart';

class ToolBloc extends Bloc<ToolEvent, ToolState> {
  ToolBloc({
    required GetToolsUseCase getToolsUseCase,
    required CreateToolUseCase createToolUseCase,
    required UpdateToolUseCase updateToolUseCase,
    required DeleteToolUseCase deleteToolUseCase,
    required CheckoutToolUseCase checkoutToolUseCase,
    required CheckinToolUseCase checkinToolUseCase,
    required SyncToolsUseCase syncToolsUseCase,
  })  : _getToolsUseCase = getToolsUseCase,
        _createToolUseCase = createToolUseCase,
        _updateToolUseCase = updateToolUseCase,
        _deleteToolUseCase = deleteToolUseCase,
        _checkoutToolUseCase = checkoutToolUseCase,
        _checkinToolUseCase = checkinToolUseCase,
        _syncToolsUseCase = syncToolsUseCase,
        super(const ToolState()) {
    on<ToolLoadRequested>(_onLoadRequested, transformer: droppable());
    on<ToolRefreshRequested>(_onRefreshRequested, transformer: droppable());
    on<ToolSearchChanged>(_onSearchChanged, transformer: restartable());
    on<ToolFilterChanged>(_onFilterChanged);
    on<ToolCreateRequested>(_onCreateRequested, transformer: sequential());
    on<ToolUpdateRequested>(_onUpdateRequested, transformer: sequential());
    on<ToolDeleteRequested>(_onDeleteRequested, transformer: sequential());
    on<ToolCheckoutRequested>(_onCheckoutRequested, transformer: sequential());
    on<ToolCheckinRequested>(_onCheckinRequested, transformer: sequential());
    on<ToolSyncRequested>(_onSyncRequested, transformer: droppable());
  }

  final GetToolsUseCase _getToolsUseCase;
  final CreateToolUseCase _createToolUseCase;
  final UpdateToolUseCase _updateToolUseCase;
  final DeleteToolUseCase _deleteToolUseCase;
  final CheckoutToolUseCase _checkoutToolUseCase;
  final CheckinToolUseCase _checkinToolUseCase;
  final SyncToolsUseCase _syncToolsUseCase;

  Future<void> _onLoadRequested(
    ToolLoadRequested event,
    Emitter<ToolState> emit,
  ) async {
    emit(state.copyWith(status: ToolListStatus.loading));

    final result = await _getToolsUseCase(event.filter);

    result.fold(
      onSuccess: (tools) => emit(
        state.copyWith(
          status: tools.isEmpty ? ToolListStatus.empty : ToolListStatus.success,
          tools: tools,
          filteredTools: tools,
          lastUpdated: DateTime.now(),
        ),
      ),
      onFailure: (failure) => emit(
        state.copyWith(
          status: ToolListStatus.failure,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> _onRefreshRequested(
    ToolRefreshRequested event,
    Emitter<ToolState> emit,
  ) async {
    final result = await _getToolsUseCase(state.filter);
    result.fold(
      onSuccess: (tools) => emit(
        state.copyWith(
          status: tools.isEmpty ? ToolListStatus.empty : ToolListStatus.success,
          tools: tools,
          filteredTools: _applyFilter(tools, state.searchQuery, state.filter),
          lastUpdated: DateTime.now(),
        ),
      ),
      onFailure: (_) {},
    );
  }

  Future<void> _onSearchChanged(
    ToolSearchChanged event,
    Emitter<ToolState> emit,
  ) async {
    final filtered = _applyFilter(state.tools, event.query, state.filter);
    emit(state.copyWith(
      searchQuery: event.query,
      filteredTools: filtered,
      status: filtered.isEmpty ? ToolListStatus.empty : ToolListStatus.success,
    ));
  }

  void _onFilterChanged(ToolFilterChanged event, Emitter<ToolState> emit) {
    final filtered = _applyFilter(state.tools, state.searchQuery, event.filter);
    emit(state.copyWith(
      filter: event.filter,
      filteredTools: filtered,
      status: filtered.isEmpty ? ToolListStatus.empty : ToolListStatus.success,
    ));
  }

  Future<void> _onCreateRequested(
    ToolCreateRequested event,
    Emitter<ToolState> emit,
  ) async {
    final result = await _createToolUseCase(event.tool);
    result.fold(
      onSuccess: (tool) {
        final updatedTools = [tool, ...state.tools];
        emit(state.copyWith(
          tools: updatedTools,
          filteredTools: _applyFilter(updatedTools, state.searchQuery, state.filter),
          status: ToolListStatus.success,
          actionStatus: 'success',
        ));
      },
      onFailure: (failure) => emit(state.copyWith(
        actionStatus: 'error',
        actionErrorMessage: failure.message,
      )),
    );
  }

  Future<void> _onUpdateRequested(
    ToolUpdateRequested event,
    Emitter<ToolState> emit,
  ) async {
    final result = await _updateToolUseCase(event.tool);
    result.fold(
      onSuccess: (updatedTool) {
        final updatedTools = state.tools
            .map((t) => t.id == updatedTool.id ? updatedTool : t)
            .toList();
        emit(state.copyWith(
          tools: updatedTools,
          filteredTools: _applyFilter(updatedTools, state.searchQuery, state.filter),
          actionStatus: 'success',
        ));
      },
      onFailure: (failure) => emit(state.copyWith(
        actionStatus: 'error',
        actionErrorMessage: failure.message,
      )),
    );
  }

  Future<void> _onDeleteRequested(
    ToolDeleteRequested event,
    Emitter<ToolState> emit,
  ) async {
    final result = await _deleteToolUseCase(event.toolId);
    result.fold(
      onSuccess: (_) {
        final updatedTools = state.tools.where((t) => t.id != event.toolId).toList();
        emit(state.copyWith(
          tools: updatedTools,
          filteredTools: _applyFilter(updatedTools, state.searchQuery, state.filter),
          status: updatedTools.isEmpty ? ToolListStatus.empty : ToolListStatus.success,
          actionStatus: 'success',
        ));
      },
      onFailure: (failure) => emit(state.copyWith(
        actionStatus: 'error',
        actionErrorMessage: failure.message,
      )),
    );
  }

  Future<void> _onCheckoutRequested(
    ToolCheckoutRequested event,
    Emitter<ToolState> emit,
  ) async {
    final result = await _checkoutToolUseCase(event.params);
    result.fold(
      onSuccess: (updatedTool) {
        final updatedTools = state.tools
            .map((t) => t.id == updatedTool.id ? updatedTool : t)
            .toList();
        emit(state.copyWith(
          tools: updatedTools,
          filteredTools: _applyFilter(updatedTools, state.searchQuery, state.filter),
          actionStatus: 'success',
        ));
      },
      onFailure: (failure) => emit(state.copyWith(
        actionStatus: 'error',
        actionErrorMessage: failure.message,
      )),
    );
  }

  Future<void> _onCheckinRequested(
    ToolCheckinRequested event,
    Emitter<ToolState> emit,
  ) async {
    final result = await _checkinToolUseCase(event.params);
    result.fold(
      onSuccess: (updatedTool) {
        final updatedTools = state.tools
            .map((t) => t.id == updatedTool.id ? updatedTool : t)
            .toList();
        emit(state.copyWith(
          tools: updatedTools,
          filteredTools: _applyFilter(updatedTools, state.searchQuery, state.filter),
          actionStatus: 'success',
        ));
      },
      onFailure: (failure) => emit(state.copyWith(
        actionStatus: 'error',
        actionErrorMessage: failure.message,
      )),
    );
  }

  Future<void> _onSyncRequested(
    ToolSyncRequested event,
    Emitter<ToolState> emit,
  ) async {
    emit(state.copyWith(isSyncing: true));
    final result = await _syncToolsUseCase();
    result.fold(
      onSuccess: (count) {
        emit(state.copyWith(isSyncing: false, syncedCount: count));
        if (count > 0) add(const ToolRefreshRequested());
      },
      onFailure: (failure) {
        AppLogger.warning('Sync failed: ${failure.message}');
        emit(state.copyWith(isSyncing: false));
      },
    );
  }

  List<ToolEntity> _applyFilter(
    List<ToolEntity> tools,
    String query,
    ToolFilter? filter,
  ) {
    var result = tools;

    if (query.isNotEmpty) {
      final lower = query.toLowerCase();
      result = result
          .where((t) =>
              t.name.toLowerCase().contains(lower) ||
              t.brand.toLowerCase().contains(lower) ||
              t.serialNumber.toLowerCase().contains(lower) ||
              (t.assetTag?.toLowerCase().contains(lower) ?? false))
          .toList();
    }

    if (filter?.status != null) {
      result = result.where((t) => t.status == filter!.status).toList();
    }
    if (filter?.category != null) {
      result = result.where((t) => t.category == filter!.category).toList();
    }
    if (filter?.workerId != null) {
      result = result.where((t) => t.assignedWorkerId == filter!.workerId).toList();
    }
    if (filter?.maintenanceDue == true) {
      result = result.where((t) => t.isMaintenanceDue).toList();
    }

    return result;
  }
}
