import 'package:power_tool_tracking/data/database/app_database.dart';
import 'package:power_tool_tracking/features/tools/data/mappers/tool_mapper.dart';
import 'package:power_tool_tracking/features/tools/domain/entities/tool_entity.dart';
import 'package:power_tool_tracking/features/tools/domain/repositories/tool_repository.dart';

class ToolLocalDataSource {
  const ToolLocalDataSource({required this.database});

  final AppDatabase database;

  Future<List<ToolEntity>> getTools({ToolFilter? filter}) async {
    List<ToolTableData> rows;

    if (filter?.searchQuery?.isNotEmpty == true) {
      rows = await database.toolDao.searchTools(filter!.searchQuery!);
    } else if (filter?.status != null) {
      rows = await database.toolDao.getToolsByStatus(filter!.status!.value);
    } else if (filter?.workerId != null) {
      rows = await database.toolDao.getToolsByWorker(filter!.workerId!);
    } else {
      rows = await database.toolDao.getAllTools();
    }

    return rows.map((r) => r.toEntity()).toList();
  }

  Stream<List<ToolEntity>> watchTools({ToolFilter? filter}) {
    if (filter?.status != null) {
      return database.toolDao
          .watchToolsByStatus(filter!.status!.value)
          .map((rows) => rows.map((r) => r.toEntity()).toList());
    }
    return database.toolDao
        .watchAllTools()
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  Future<ToolEntity?> getToolById(String id) async {
    final row = await database.toolDao.getToolById(id);
    return row?.toEntity();
  }

  Future<ToolEntity> saveTool(ToolEntity tool, {String? changeType}) async {
    await database.toolDao.insertTool(tool.toCompanion(changeType: changeType));
    return tool;
  }

  Future<void> saveAllTools(List<ToolEntity> tools) async {
    final companions = tools.map((t) => t.toCompanion()).toList();
    await database.toolDao.insertAll(companions);
  }

  Future<ToolEntity> updateTool(ToolEntity tool, {String? changeType}) async {
    await database.toolDao.updateTool(tool.toCompanion(changeType: changeType));
    return tool;
  }

  Future<void> deleteTool(String id) async {
    await database.toolDao.softDeleteTool(id);
  }

  Future<void> markAsSynced(String id) => database.toolDao.markAsSynced(id);

  Future<List<ToolEntity>> getUnsyncedTools() async {
    final rows = await database.toolDao.getUnsyncedTools();
    return rows.map((r) => r.toEntity()).toList();
  }

  Future<List<ToolEntity>> getToolsDueForMaintenance() async {
    final rows = await database.toolDao.getToolsDueForMaintenance();
    return rows.map((r) => r.toEntity()).toList();
  }
}
