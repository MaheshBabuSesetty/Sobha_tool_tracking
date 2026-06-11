class PmRequestEntity {
  const PmRequestEntity({
    required this.id,
    required this.requestNumber,
    required this.status,
    required this.siteId,
    required this.siteName,
    required this.priority,
    required this.requestedBy,
    required this.createdAt,
    required this.itemsTotal,
    required this.itemsRemaining,
  });

  final int id;
  final String requestNumber;
  final String status; // "PM Approved" | "Partially Fulfilled"
  final int siteId;
  final String siteName;
  final String priority;
  final String requestedBy;
  final DateTime createdAt;
  final int itemsTotal;
  final int itemsRemaining;

  bool get isActionable =>
      status == 'PM Approved' || status == 'Partially Fulfilled';
}

class PmRequestDetailEntity {
  const PmRequestDetailEntity({
    required this.id,
    required this.requestNumber,
    required this.status,
    required this.siteId,
    required this.siteName,
    required this.priority,
    required this.items,
  });

  final int id;
  final String requestNumber;
  final String status;
  final int siteId;
  final String siteName;
  final String priority;
  final List<PmRequestItemEntity> items;

  bool get isActionable =>
      status == 'PM Approved' || status == 'Partially Fulfilled';
}

class PmRequestItemEntity {
  const PmRequestItemEntity({
    required this.itemId,
    required this.descriptionId,
    required this.description,
    required this.quantity,
    required this.issued,
    required this.remaining,
    required this.availableStock,
  });

  final int itemId;
  final int descriptionId;
  final String description;
  final int quantity;
  final int issued;
  final int remaining;
  final List<AvailableStockEntity> availableStock;
}

class AvailableStockEntity {
  const AvailableStockEntity({
    required this.id,
    required this.rfidTag,
    required this.serialNumber,
    required this.condition,
  });

  final int id;
  final String rfidTag;
  final String serialNumber;
  final String condition;
}

class ActionResponseEntity {
  const ActionResponseEntity({
    required this.message,
    required this.movementId,
    required this.toolId,
    required this.newStatus,
    this.requestStatus,
    this.gatePassNumber,
  });

  final String message;
  final int movementId;
  final int toolId;
  final String newStatus;
  final String? requestStatus;
  final String? gatePassNumber;
}
