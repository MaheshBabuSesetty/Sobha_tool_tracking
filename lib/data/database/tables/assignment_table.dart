import 'package:drift/drift.dart';

class AssignmentTable extends Table {
  @override
  String get tableName => 'assignments';

  TextColumn get id => text()();
  TextColumn get toolId => text()();
  TextColumn get workerId => text()();
  TextColumn get workerName => text()();
  TextColumn get projectId => text().nullable()();
  TextColumn get projectName => text().nullable()();
  TextColumn get conditionAtCheckout => text()();
  TextColumn get conditionAtCheckin => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get expectedReturnDate => dateTime().nullable()();
  DateTimeColumn get checkedOutAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get checkedInAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
