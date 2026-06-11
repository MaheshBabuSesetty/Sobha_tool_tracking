import 'package:json_annotation/json_annotation.dart';

part 'tool_model.g.dart';

@JsonSerializable()
class ToolModel {
  const ToolModel({
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
  });

  final String id;
  final String name;
  final String brand;
  final String model;
  @JsonKey(name: 'serial_number')
  final String serialNumber;
  final String category;
  final String status;
  final String condition;
  @JsonKey(name: 'asset_tag')
  final String? assetTag;
  final String? description;
  final String? location;
  @JsonKey(name: 'purchase_cost')
  final double? purchaseCost;
  @JsonKey(name: 'purchase_date')
  final DateTime? purchaseDate;
  @JsonKey(name: 'warranty_expiry')
  final DateTime? warrantyExpiry;
  @JsonKey(name: 'last_maintenance_date')
  final DateTime? lastMaintenanceDate;
  @JsonKey(name: 'next_maintenance_due')
  final DateTime? nextMaintenanceDue;
  @JsonKey(name: 'assigned_worker_id')
  final String? assignedWorkerId;
  @JsonKey(name: 'assigned_worker_name')
  final String? assignedWorkerName;
  @JsonKey(name: 'assigned_project_id')
  final String? assignedProjectId;
  @JsonKey(name: 'assigned_project_name')
  final String? assignedProjectName;
  @JsonKey(name: 'checked_out_at')
  final DateTime? checkedOutAt;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  factory ToolModel.fromJson(Map<String, dynamic> json) =>
      _$ToolModelFromJson(json);

  Map<String, dynamic> toJson() => _$ToolModelToJson(this);

  ToolModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? model,
    String? serialNumber,
    String? category,
    String? status,
    String? condition,
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
  }) =>
      ToolModel(
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
      );
}
