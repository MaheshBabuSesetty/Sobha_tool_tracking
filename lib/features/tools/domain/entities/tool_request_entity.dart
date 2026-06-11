enum ToolRequestStatus { pendingIssue, issued, rejected, completed }

extension ToolRequestStatusX on ToolRequestStatus {
  String get label => switch (this) {
        ToolRequestStatus.pendingIssue => 'Pending Issue',
        ToolRequestStatus.issued => 'Issued',
        ToolRequestStatus.rejected => 'Rejected',
        ToolRequestStatus.completed => 'Completed',
      };
}

class RequestedDevice {
  const RequestedDevice({
    required this.name,
    required this.quantity,
  });

  final String name;
  final int quantity;
}

class ToolRequestEntity {
  const ToolRequestEntity({
    required this.id,
    required this.requestNumber,
    required this.requesterName,
    required this.site,
    required this.sou,
    required this.module,
    required this.toolName,
    required this.category,
    required this.quantity,
    required this.fromDate,
    required this.toDate,
    required this.status,
    required this.devices,
  });

  final String id;
  final String requestNumber;
  final String requesterName;
  final String site;
  final String sou;
  final String module;
  final String toolName;
  final String category;
  final int quantity;
  final DateTime fromDate;
  final DateTime toDate;
  final ToolRequestStatus status;
  final List<RequestedDevice> devices;
}
