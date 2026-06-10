import 'package:drift/drift.dart';

class ToolTable extends Table {
  @override
  String get tableName => 'tools';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get brand => text()();
  TextColumn get model => text()();
  TextColumn get serialNumber => text().unique()();
  TextColumn get category => text()();
  TextColumn get status => text().withDefault(const Constant('available'))();
  TextColumn get condition => text().withDefault(const Constant('good'))();
  TextColumn get assetTag => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get location => text().nullable()();
  RealColumn get purchaseCost => real().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  DateTimeColumn get warrantyExpiry => dateTime().nullable()();
  DateTimeColumn get lastMaintenanceDate => dateTime().nullable()();
  DateTimeColumn get nextMaintenanceDue => dateTime().nullable()();
  TextColumn get assignedWorkerId => text().nullable()();
  TextColumn get assignedWorkerName => text().nullable()();
  TextColumn get assignedProjectId => text().nullable()();
  TextColumn get assignedProjectName => text().nullable()();
  DateTimeColumn get checkedOutAt => dateTime().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get localChangeType => text().nullable()(); // 'create' | 'update' | 'delete'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
