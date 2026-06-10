import 'package:drift/drift.dart';
import 'package:power_tool_tracking/data/database/app_database.dart';
import 'package:power_tool_tracking/data/database/tables/tool_table.dart';

part 'tool_dao.g.dart';

@DriftAccessor(tables: [ToolTable])
class ToolDao extends DatabaseAccessor<AppDatabase> with _$ToolDaoMixin {
  ToolDao(super.db);

  // Watch all non-deleted tools
  Stream<List<ToolTableData>> watchAllTools() => (select(toolTable)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  Future<List<ToolTableData>> getAllTools() => (select(toolTable)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .get();

  Future<ToolTableData?> getToolById(String id) =>
      (select(toolTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<ToolTableData>> getToolsByStatus(String status) =>
      (select(toolTable)
            ..where((t) => t.status.equals(status) & t.isDeleted.equals(false)))
          .get();

  Stream<List<ToolTableData>> watchToolsByStatus(String status) =>
      (select(toolTable)
            ..where((t) => t.status.equals(status) & t.isDeleted.equals(false)))
          .watch();

  Future<List<ToolTableData>> getToolsByWorker(String workerId) =>
      (select(toolTable)
            ..where((t) => t.assignedWorkerId.equals(workerId) & t.isDeleted.equals(false)))
          .get();

  Future<List<ToolTableData>> getUnsyncedTools() =>
      (select(toolTable)..where((t) => t.isSynced.equals(false))).get();

  Future<List<ToolTableData>> searchTools(String query) =>
      (select(toolTable)
            ..where((t) =>
                t.isDeleted.equals(false) &
                (t.name.like('%$query%') |
                    t.brand.like('%$query%') |
                    t.serialNumber.like('%$query%') |
                    t.assetTag.like('%$query%'))))
          .get();

  Future<List<ToolTableData>> getToolsDueForMaintenance() {
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7));
    return (select(toolTable)
          ..where((t) =>
              t.isDeleted.equals(false) &
              t.nextMaintenanceDue.isSmallerOrEqualValue(sevenDaysLater)))
        .get();
  }

  Future<int> insertTool(ToolTableCompanion tool) =>
      into(toolTable).insertOnConflictUpdate(tool);

  Future<void> insertAll(List<ToolTableCompanion> tools) async {
    await batch((b) => b.insertAllOnConflictUpdate(toolTable, tools));
  }

  Future<bool> updateTool(ToolTableCompanion tool) =>
      update(toolTable).replace(tool);

  Future<int> deleteTool(String id) =>
      (delete(toolTable)..where((t) => t.id.equals(id))).go();

  Future<int> softDeleteTool(String id) => (update(toolTable)
        ..where((t) => t.id.equals(id)))
      .write(const ToolTableCompanion(isDeleted: Value(true)));

  Future<int> markAsSynced(String id) => (update(toolTable)
        ..where((t) => t.id.equals(id)))
      .write(ToolTableCompanion(
        isSynced: const Value(true),
        syncedAt: Value(DateTime.now()),
        localChangeType: const Value(null),
      ));

  Future<int> getToolCount() =>
      (select(toolTable)..where((t) => t.isDeleted.equals(false)))
          .get()
          .then((list) => list.length);

  Future<int> getAvailableToolCount() =>
      (select(toolTable)
            ..where((t) => t.status.equals('available') & t.isDeleted.equals(false)))
          .get()
          .then((list) => list.length);
}
