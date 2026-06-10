import 'package:power_tool_tracking/core/constants/api_constants.dart';
import 'package:power_tool_tracking/core/network/api_client.dart';
import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/data/models/tool/tool_model.dart';

class ToolRemoteDataSource {
  const ToolRemoteDataSource({required this.apiClient});

  final ApiClient apiClient;

  Future<Result<List<ToolModel>>> getTools({Map<String, dynamic>? queryParams}) =>
      apiClient.get<List<ToolModel>>(
        ApiConstants.tools,
        queryParams: queryParams,
        fromJson: (json) => (json as List<dynamic>)
            .map((e) => ToolModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<Result<ToolModel>> getToolById(String id) =>
      apiClient.get<ToolModel>(
        ApiConstants.toolById(id),
        fromJson: (json) => ToolModel.fromJson(json as Map<String, dynamic>),
      );

  Future<Result<ToolModel>> createTool(Map<String, dynamic> toolData) =>
      apiClient.post<ToolModel>(
        ApiConstants.tools,
        data: toolData,
        fromJson: (json) => ToolModel.fromJson(json as Map<String, dynamic>),
      );

  Future<Result<ToolModel>> updateTool(String id, Map<String, dynamic> toolData) =>
      apiClient.put<ToolModel>(
        ApiConstants.toolById(id),
        data: toolData,
        fromJson: (json) => ToolModel.fromJson(json as Map<String, dynamic>),
      );

  Future<Result<bool>> deleteTool(String id) => apiClient.delete(
        ApiConstants.toolById(id),
      );

  Future<Result<ToolModel>> checkoutTool(String id, Map<String, dynamic> checkoutData) =>
      apiClient.post<ToolModel>(
        ApiConstants.toolCheckout(id),
        data: checkoutData,
        fromJson: (json) => ToolModel.fromJson(json as Map<String, dynamic>),
      );

  Future<Result<ToolModel>> checkinTool(String id, Map<String, dynamic> checkinData) =>
      apiClient.post<ToolModel>(
        ApiConstants.toolCheckin(id),
        data: checkinData,
        fromJson: (json) => ToolModel.fromJson(json as Map<String, dynamic>),
      );

  Future<Result<List<ToolModel>>> syncTools(
    List<Map<String, dynamic>> pendingChanges, {
    String? lastSyncAt,
  }) =>
      apiClient.post<List<ToolModel>>(
        ApiConstants.toolBulkSync,
        data: {
          'changes': pendingChanges,
          'last_sync_at': lastSyncAt,
        },
        fromJson: (json) {
          final data = json as Map<String, dynamic>;
          return (data['tools'] as List<dynamic>)
              .map((e) => ToolModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
}
