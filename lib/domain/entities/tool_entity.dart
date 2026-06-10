import 'package:equatable/equatable.dart';
import 'package:power_tool_tracking/core/constants/app_constants.dart';

enum ToolStatus {
  available,
  checkedOut,
  inMaintenance,
  retired,
  lost;

  String get displayName => switch (this) {
        ToolStatus.available => 'Available',
        ToolStatus.checkedOut => 'Checked Out',
        ToolStatus.inMaintenance => 'In Maintenance',
        ToolStatus.retired => 'Retired',
        ToolStatus.lost => 'Lost',
      };

  String get value => switch (this) {
        ToolStatus.available => AppConstants.statusAvailable,
        ToolStatus.checkedOut => AppConstants.statusCheckedOut,
        ToolStatus.inMaintenance => AppConstants.statusMaintenance,
        ToolStatus.retired => AppConstants.statusRetired,
        ToolStatus.lost => AppConstants.statusLost,
      };

  static ToolStatus fromString(String value) => switch (value) {
        'available' => ToolStatus.available,
        'checked_out' => ToolStatus.checkedOut,
        'in_maintenance' => ToolStatus.inMaintenance,
        'retired' => ToolStatus.retired,
        'lost' => ToolStatus.lost,
        _ => ToolStatus.available,
      };
}

enum ToolCondition {
  excellent,
  good,
  fair,
  poor;

  String get displayName => switch (this) {
        ToolCondition.excellent => 'Excellent',
        ToolCondition.good => 'Good',
        ToolCondition.fair => 'Fair',
        ToolCondition.poor => 'Poor',
      };

  static ToolCondition fromString(String value) => switch (value) {
        'excellent' => ToolCondition.excellent,
        'good' => ToolCondition.good,
        'fair' => ToolCondition.fair,
        'poor' => ToolCondition.poor,
        _ => ToolCondition.good,
      };
}

class ToolEntity extends Equatable {
  const ToolEntity({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.serialNumber,
    required this.category,
    required this.status,
    required this.condition,
    this.assetTag,
    this.description,
    this.location,
    this.purchaseCost,
    this.purchaseDate,
    this.warrantyExpiry,
    this.lastMaintenanceDate,
    this.nextMaintenanceDue,
    this.assignedWorkerId,
    this.assignedWorkerName,
    this.assignedProjectId,
    this.assignedProjectName,
    this.checkedOutAt,
    this.imageUrl,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = true,
  });

  final String id;
  final String name;
  final String brand;
  final String model;
  final String serialNumber;
  final String category;
  final ToolStatus status;
  final ToolCondition condition;
  final String? assetTag;
  final String? description;
  final String? location;
  final double? purchaseCost;
  final DateTime? purchaseDate;
  final DateTime? warrantyExpiry;
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDue;
  final String? assignedWorkerId;
  final String? assignedWorkerName;
  final String? assignedProjectId;
  final String? assignedProjectName;
  final DateTime? checkedOutAt;
  final String? imageUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  bool get isAvailable => status == ToolStatus.available;
  bool get isCheckedOut => status == ToolStatus.checkedOut;
  bool get isInMaintenance => status == ToolStatus.inMaintenance;

  bool get isMaintenanceDue {
    if (nextMaintenanceDue == null) return false;
    return nextMaintenanceDue!.isBefore(DateTime.now().add(const Duration(days: 7)));
  }

  bool get isMaintenanceOverdue {
    if (nextMaintenanceDue == null) return false;
    return nextMaintenanceDue!.isBefore(DateTime.now());
  }

  bool get isWarrantyExpired {
    if (warrantyExpiry == null) return false;
    return warrantyExpiry!.isBefore(DateTime.now());
  }

  String get displayTitle => '$brand $name';

  ToolEntity copyWith({
    String? id,
    String? name,
    String? brand,
    String? model,
    String? serialNumber,
    String? category,
    ToolStatus? status,
    ToolCondition? condition,
    String? assetTag,
    String? description,
    String? location,
    double? purchaseCost,
    DateTime? purchaseDate,
    DateTime? warrantyExpiry,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDue,
    String? assignedWorkerId,
    String? assignedWorkerName,
    String? assignedProjectId,
    String? assignedProjectName,
    DateTime? checkedOutAt,
    String? imageUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) =>
      ToolEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        brand: brand ?? this.brand,
        model: model ?? this.model,
        serialNumber: serialNumber ?? this.serialNumber,
        category: category ?? this.category,
        status: status ?? this.status,
        condition: condition ?? this.condition,
        assetTag: assetTag ?? this.assetTag,
        description: description ?? this.description,
        location: location ?? this.location,
        purchaseCost: purchaseCost ?? this.purchaseCost,
        purchaseDate: purchaseDate ?? this.purchaseDate,
        warrantyExpiry: warrantyExpiry ?? this.warrantyExpiry,
        lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
        nextMaintenanceDue: nextMaintenanceDue ?? this.nextMaintenanceDue,
        assignedWorkerId: assignedWorkerId ?? this.assignedWorkerId,
        assignedWorkerName: assignedWorkerName ?? this.assignedWorkerName,
        assignedProjectId: assignedProjectId ?? this.assignedProjectId,
        assignedProjectName: assignedProjectName ?? this.assignedProjectName,
        checkedOutAt: checkedOutAt ?? this.checkedOutAt,
        imageUrl: imageUrl ?? this.imageUrl,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        brand,
        model,
        serialNumber,
        category,
        status,
        condition,
        assetTag,
        location,
        assignedWorkerId,
        assignedProjectId,
        isSynced,
        updatedAt,
      ];
}
