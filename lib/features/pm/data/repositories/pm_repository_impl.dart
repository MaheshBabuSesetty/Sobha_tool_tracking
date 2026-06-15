import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/features/pm/data/datasources/mobile_datasource.dart';
import 'package:power_tool_tracking/features/pm/domain/entities/pm_request_entity.dart';
import 'package:power_tool_tracking/features/pm/domain/repositories/pm_repository.dart';

class PmRepositoryImpl implements PmRepository {
  const PmRepositoryImpl({required this.dataSource});

  final MobileDataSource dataSource;

  @override
  Future<Result<List<PmRequestEntity>>> getRequests() =>
      dataSource.getPmRequests();

  @override
  Future<Result<PmRequestDetailEntity>> getRequestDetail(int id) =>
      dataSource.getPmRequestDetail(id);

  @override
  Future<Result<RfidScanResultEntity>> scanRfid({
    required String code,
    required int requestId,
  }) =>
      dataSource.scanRfid(code: code, requestId: requestId);

  @override
  Future<Result<ActionResponseEntity>> issueTool({
    required int requestId,
    required int toolId,
    String? remarks,
  }) =>
      dataSource.issueTool(
        requestId: requestId,
        toolId: toolId,
        remarks: remarks,
      );

  @override
  Future<Result<List<ToolToReceiveEntity>>> getToolsToReceive() =>
      dataSource.getToolsToReceive();

  @override
  Future<Result<ReceiptConfirmEntity>> confirmToolReceipt(int movementId) =>
      dataSource.confirmToolReceipt(movementId);
}
