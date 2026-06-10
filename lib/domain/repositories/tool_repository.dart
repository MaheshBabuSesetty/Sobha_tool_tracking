import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/domain/entities/tool_entity.dart';

class ToolFilter {
  const ToolFilter({
    this.status,
    this.category,
    this.searchQuery,
    this.workerId,
    this.projectId,
    this.maintenanceDue,
  });

  final ToolStatus? status;
  final String? category;
  final String? searchQuery;
  final String? workerId;
  final String? projectId;
  final bool? maintenanceDue;

  bool get isEmpty =>
      status == null &&
      category == null &&
      (searchQuery == null || searchQuery!.isEmpty) &&
      workerId == null &&
      projectId == null &&
      maintenanceDue == null;
}

class CheckoutParams {
  const CheckoutParams({
    required this.toolId,
    required this.workerId,
    required this.workerName,
    this.projectId,
    this.projectName,
    this.expectedReturnDate,
    this.notes,
  });

  final String toolId;
  final String workerId;
  final String workerName;
  final String? projectId;
  final String? projectName;
  final DateTime? expectedReturnDate;
  final String? notes;
}

class CheckinParams {
  const CheckinParams({
    required this.toolId,
    required this.condition,
    this.notes,
    this.damageReported = false,
  });

  final String toolId;
  final ToolCondition condition;
  final String? notes;
  final bool damageReported;
}

abstract interface class ToolRepository {
  Future<Result<List<ToolEntity>>> getTools({ToolFilter? filter});

  Stream<List<ToolEntity>> watchTools({ToolFilter? filter});

  Future<Result<ToolEntity>> getToolById(String id);

  Future<Result<ToolEntity>> createTool(ToolEntity tool);

  Future<Result<ToolEntity>> updateTool(ToolEntity tool);

  Future<Result<bool>> deleteTool(String id);

  Future<Result<ToolEntity>> checkoutTool(CheckoutParams params);

  Future<Result<ToolEntity>> checkinTool(CheckinParams params);

  Future<Result<int>> syncTools();

  Future<Result<List<ToolEntity>>> getToolsDueForMaintenance();

  Future<Result<List<ToolEntity>>> searchTools(String query);
}
