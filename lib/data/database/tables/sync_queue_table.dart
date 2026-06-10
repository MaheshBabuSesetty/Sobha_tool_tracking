import 'package:drift/drift.dart';

class SyncQueueTable extends Table {
  @override
  String get tableName => 'sync_queue';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // 'tool' | 'assignment' | 'maintenance'
  TextColumn get entityId => text()();
  TextColumn get action => text()(); // 'create' | 'update' | 'delete'
  TextColumn get payload => text()(); // JSON string
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
}
