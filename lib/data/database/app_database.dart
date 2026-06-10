import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:power_tool_tracking/core/constants/app_constants.dart';
import 'package:power_tool_tracking/data/database/dao/sync_queue_dao.dart';
import 'package:power_tool_tracking/data/database/dao/tool_dao.dart';
import 'package:power_tool_tracking/data/database/tables/assignment_table.dart';
import 'package:power_tool_tracking/data/database/tables/sync_queue_table.dart';
import 'package:power_tool_tracking/data/database/tables/tool_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    ToolTable,
    AssignmentTable,
    SyncQueueTable,
  ],
  daos: [
    ToolDao,
    SyncQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => AppConstants.dbVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Add migration steps here as the schema evolves
          if (from < 2) {
            // Example: await m.addColumn(toolTable, toolTable.someNewColumn);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
        },
      );

  static QueryExecutor _openConnection() => driftDatabase(
        name: AppConstants.dbName,
        native: DriftNativeOptions(
          databaseDirectory: getApplicationDocumentsDirectory,
        ),
      );

  Future<void> clearAllData() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }
}
