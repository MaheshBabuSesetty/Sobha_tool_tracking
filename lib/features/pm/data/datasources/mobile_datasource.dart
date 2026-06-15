import 'package:power_tool_tracking/core/constants/api_constants.dart';
import 'package:power_tool_tracking/core/network/mobile_api_client.dart';
import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/features/pm/domain/entities/pm_request_entity.dart';

class MobileDataSource {
  const MobileDataSource({required this.apiClient});

  final MobileApiClient apiClient;

  Future<Result<List<PmRequestEntity>>> getPmRequests() =>
      apiClient.get<List<PmRequestEntity>>(
        ApiConstants.mobilePmRequests,
        fromJson: (json) {
          final items = (json as Map<String, dynamic>)['items'] as List;
          return items
              .map((e) => _parsePmRequest(e as Map<String, dynamic>))
              .toList();
        },
      );

  Future<Result<PmRequestDetailEntity>> getPmRequestDetail(int id) =>
      apiClient.get<PmRequestDetailEntity>(
        ApiConstants.mobilePmRequestById(id),
        fromJson: (json) =>
            _parsePmRequestDetail(json as Map<String, dynamic>),
      );

  Future<Result<RfidScanResultEntity>> scanRfid({
    required String code,
    required int requestId,
  }) =>
      apiClient.get<RfidScanResultEntity>(
        ApiConstants.mobileScan,
        queryParams: {'code': code, 'request_id': requestId},
        fromJson: (json) => _parseScanResult(json as Map<String, dynamic>),
      );

  Future<Result<List<ToolToReceiveEntity>>> getToolsToReceive() =>
      apiClient.get<List<ToolToReceiveEntity>>(
        ApiConstants.mobilePmToReceive,
        fromJson: (json) {
          final items = (json as Map<String, dynamic>)['items'] as List;
          return items
              .map((e) => _parseToolToReceive(e as Map<String, dynamic>))
              .toList();
        },
      );

  Future<Result<ReceiptConfirmEntity>> confirmToolReceipt(int movementId) =>
      apiClient.post<ReceiptConfirmEntity>(
        ApiConstants.mobilePmReceive,
        data: {'movement_id': movementId},
        fromJson: (json) => ReceiptConfirmEntity(
          message: (json as Map<String, dynamic>)['message'] as String,
        ),
      );

  Future<Result<ActionResponseEntity>> issueTool({
    required int requestId,
    required int toolId,
    String? remarks,
  }) =>
      apiClient.post<ActionResponseEntity>(
        ApiConstants.mobilePmIssue,
        data: {
          'request_id': requestId,
          'tool_id': toolId,
          if (remarks != null) 'remarks': remarks,
        },
        fromJson: (json) =>
            _parseActionResponse(json as Map<String, dynamic>),
      );

  PmRequestEntity _parsePmRequest(Map<String, dynamic> j) => PmRequestEntity(
        id: j['id'] as int,
        requestNumber: j['request_number'] as String,
        status: j['status'] as String,
        siteId: j['site_id'] as int,
        siteName: j['site_name'] as String,
        priority: j['priority'] as String,
        requestedBy: j['requested_by'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
        itemsTotal: j['items_total'] as int,
        itemsRemaining: j['items_remaining'] as int,
      );

  PmRequestDetailEntity _parsePmRequestDetail(Map<String, dynamic> j) =>
      PmRequestDetailEntity(
        id: j['id'] as int,
        requestNumber: j['request_number'] as String,
        status: j['status'] as String,
        siteId: j['site_id'] as int,
        siteName: j['site_name'] as String,
        priority: j['priority'] as String,
        items: (j['items'] as List)
            .map((e) => _parsePmRequestItem(e as Map<String, dynamic>))
            .toList(),
      );

  PmRequestItemEntity _parsePmRequestItem(Map<String, dynamic> j) =>
      PmRequestItemEntity(
        itemId: j['item_id'] as int,
        descriptionId: j['description_id'] as int,
        description: j['description'] as String,
        quantity: j['quantity'] as int,
        issued: j['issued'] as int,
        remaining: j['remaining'] as int,
        availableStock: (j['available_stock'] as List)
            .map((e) => _parseStock(e as Map<String, dynamic>))
            .toList(),
      );

  AvailableStockEntity _parseStock(Map<String, dynamic> j) =>
      AvailableStockEntity(
        id: j['id'] as int,
        rfidTag: j['rfid_tag'] as String,
        serialNumber: j['serial_number'] as String,
        condition: j['condition'] as String,
      );

  RfidScanResultEntity _parseScanResult(Map<String, dynamic> j) {
    final match = j['matches_request_item'];
    return RfidScanResultEntity(
      matchesRequestItem: match == null
          ? null
          : _parseScanMatch(match as Map<String, dynamic>),
    );
  }

  RfidScanMatchEntity _parseScanMatch(Map<String, dynamic> j) =>
      RfidScanMatchEntity(
        id: j['id'] as int,
        rfidTag: j['rfid_tag'] as String,
        serialNumber: j['serial_number'] as String,
        condition: j['condition'] as String,
      );

  ToolToReceiveEntity _parseToolToReceive(Map<String, dynamic> j) =>
      ToolToReceiveEntity(
        toolId: j['tool_id'] as int,
        rfidTag: j['rfid_tag'] as String,
        toolName: j['tool_name'] as String,
        returnedFrom: j['returned_from'] as String,
        returnedBy: j['returned_by'] as String,
        returnedAt: DateTime.parse(j['returned_at'] as String),
        movementId: j['movement_id'] as int,
      );

  ActionResponseEntity _parseActionResponse(Map<String, dynamic> j) =>
      ActionResponseEntity(
        message: j['message'] as String,
        movementId: j['movement_id'] as int,
        toolId: j['tool_id'] as int,
        newStatus: j['new_status'] as String,
        requestStatus: j['request_status'] as String?,
        gatePassNumber: j['gate_pass_number'] as String?,
      );
}
