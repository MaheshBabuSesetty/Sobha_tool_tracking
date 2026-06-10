part of 'tool_bloc.dart';

enum ToolListStatus { initial, loading, success, failure, empty }

final class ToolState extends Equatable {
  const ToolState({
    this.status = ToolListStatus.initial,
    this.tools = const [],
    this.filteredTools = const [],
    this.searchQuery = '',
    this.filter,
    this.errorMessage,
    this.isSyncing = false,
    this.syncedCount = 0,
    this.actionStatus,
    this.actionErrorMessage,
    this.lastUpdated,
  });

  final ToolListStatus status;
  final List<ToolEntity> tools;
  final List<ToolEntity> filteredTools;
  final String searchQuery;
  final ToolFilter? filter;
  final String? errorMessage;
  final bool isSyncing;
  final int syncedCount;
  final String? actionStatus; // 'success' | 'error' | null
  final String? actionErrorMessage;
  final DateTime? lastUpdated;

  bool get isLoading => status == ToolListStatus.loading;
  bool get isSuccess => status == ToolListStatus.success;
  bool get isEmpty => status == ToolListStatus.empty;
  bool get hasError => status == ToolListStatus.failure;

  int get availableCount => tools.where((t) => t.isAvailable).length;
  int get checkedOutCount => tools.where((t) => t.isCheckedOut).length;
  int get maintenanceCount => tools.where((t) => t.isInMaintenance).length;
  int get maintenanceDueCount => tools.where((t) => t.isMaintenanceDue).length;

  ToolState copyWith({
    ToolListStatus? status,
    List<ToolEntity>? tools,
    List<ToolEntity>? filteredTools,
    String? searchQuery,
    ToolFilter? filter,
    String? errorMessage,
    bool? isSyncing,
    int? syncedCount,
    String? actionStatus,
    String? actionErrorMessage,
    DateTime? lastUpdated,
    bool clearActionStatus = false,
  }) =>
      ToolState(
        status: status ?? this.status,
        tools: tools ?? this.tools,
        filteredTools: filteredTools ?? this.filteredTools,
        searchQuery: searchQuery ?? this.searchQuery,
        filter: filter ?? this.filter,
        errorMessage: errorMessage ?? this.errorMessage,
        isSyncing: isSyncing ?? this.isSyncing,
        syncedCount: syncedCount ?? this.syncedCount,
        actionStatus: clearActionStatus ? null : (actionStatus ?? this.actionStatus),
        actionErrorMessage: clearActionStatus ? null : (actionErrorMessage ?? this.actionErrorMessage),
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );

  @override
  List<Object?> get props => [
        status,
        tools,
        filteredTools,
        searchQuery,
        filter,
        errorMessage,
        isSyncing,
        syncedCount,
        actionStatus,
        actionErrorMessage,
        lastUpdated,
      ];
}
