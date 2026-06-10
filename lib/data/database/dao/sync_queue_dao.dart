import 'package:drift/drift.dart';
import 'package:power_tool_tracking/data/database/app_database.dart';
import 'package:power_tool_tracking/data/database/tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueueTable])
class SyncQueueDao extends DatabaseAccessor<AppDatabase> with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<List<SyncQueueTableData>> getPendingItems({int limit = 50}) =>
      (select(syncQueueTable)
            ..where((t) =>
                t.status.equals('pending') |
                (t.status.equals('failed') &
                    t.retryCount.isSmallerThanValue(3)))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..limit(limit))
          .get();

  Stream<int> watchPendingCount() => (selectOnly(syncQueueTable)
        ..addColumns([syncQueueTable.id.count()])
        ..where(syncQueueTable.status.equals('pending')))
      .map((r) => r.read(syncQueueTable.id.count()) ?? 0)
      .watchSingle();

  Future<int> enqueue(SyncQueueTableCompanion item) =>
      into(syncQueueTable).insert(item);

  Future<void> markAsCompleted(int id) => (update(syncQueueTable)
        ..where((t) => t.id.equals(id)))
      .write(const SyncQueueTableCompanion(status: Value('completed')));

  Future<void> markAsFailed(int id, String error) => (update(syncQueueTable)
        ..where((t) => t.id.equals(id)))
      .write(SyncQueueTableCompanion(
        status: const Value('failed'),
        errorMessage: Value(error),
        lastAttemptAt: Value(DateTime.now()),
        nextRetryAt: Value(DateTime.now().add(const Duration(minutes: 5))),
      ));

  Future<void> incrementRetryCount(int id) async {
    final item = await (select(syncQueueTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (item != null) {
      await (update(syncQueueTable)..where((t) => t.id.equals(id))).write(
        SyncQueueTableCompanion(retryCount: Value(item.retryCount + 1)),
      );
    }
  }

  Future<int> deleteCompleted() =>
      (delete(syncQueueTable)..where((t) => t.status.equals('completed'))).go();

  Future<int> deleteAll() => delete(syncQueueTable).go();
}
