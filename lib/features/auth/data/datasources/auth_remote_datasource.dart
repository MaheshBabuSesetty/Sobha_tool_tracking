import 'package:power_tool_tracking/core/constants/api_constants.dart';
import 'package:power_tool_tracking/core/network/api_client.dart';
import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/features/auth/data/models/login_request_model.dart';
import 'package:power_tool_tracking/features/auth/data/models/login_response_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource({required this.apiClient});

  final ApiClient apiClient;

  Future<Result<LoginResponseModel>> login(LoginRequestModel request) =>
      apiClient.post<LoginResponseModel>(
        ApiConstants.login,
        data: request.toJson(),
        fromJson: (json) => LoginResponseModel.fromJson(json as Map<String, dynamic>),
      );

  Future<Result<bool>> logout() => apiClient.post<bool>(
        ApiConstants.logout,
        fromJson: (_) => true,
      );

  Future<Result<LoginResponseModel>> refreshToken(String refreshToken) =>
      apiClient.post<LoginResponseModel>(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
        fromJson: (json) => LoginResponseModel.fromJson(json as Map<String, dynamic>),
      );

  Future<Result<bool>> forgotPassword(String email) => apiClient.post<bool>(
        ApiConstants.forgotPassword,
        data: {'email': email},
        fromJson: (_) => true,
      );

  Future<Result<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      apiClient.post<bool>(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
        fromJson: (_) => true,
      );
}
