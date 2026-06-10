import 'package:power_tool_tracking/flavors/environment_config.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl => EnvironmentConfig.apiBaseUrl;
  static int get timeoutMs => EnvironmentConfig.apiTimeout;

  // Auth Endpoints
  static const String login = '/api/v1/auth/login';
  static const String logout = '/api/v1/auth/logout';
  static const String refreshToken = '/api/v1/auth/refresh';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String resetPassword = '/api/v1/auth/reset-password';
  static const String changePassword = '/api/v1/auth/change-password';
  static const String profile = '/api/v1/auth/profile';

  // Tool Endpoints
  static const String tools = '/api/v1/tools';
  static String toolById(String id) => '/api/v1/tools/$id';
  static String toolCheckout(String id) => '/api/v1/tools/$id/checkout';
  static String toolCheckin(String id) => '/api/v1/tools/$id/checkin';
  static String toolMaintenance(String id) => '/api/v1/tools/$id/maintenance';
  static const String toolSync = '/api/v1/tools/sync';
  static const String toolBulkSync = '/api/v1/tools/bulk-sync';

  // Worker Endpoints
  static const String workers = '/api/v1/workers';
  static String workerById(String id) => '/api/v1/workers/$id';
  static String workerTools(String id) => '/api/v1/workers/$id/tools';

  // Project Endpoints
  static const String projects = '/api/v1/projects';
  static String projectById(String id) => '/api/v1/projects/$id';
  static String projectTools(String id) => '/api/v1/projects/$id/tools';

  // Assignment Endpoints
  static const String assignments = '/api/v1/assignments';
  static String assignmentById(String id) => '/api/v1/assignments/$id';

  // Maintenance Endpoints
  static const String maintenanceRecords = '/api/v1/maintenance';
  static String maintenanceById(String id) => '/api/v1/maintenance/$id';

  // Reports
  static const String reports = '/api/v1/reports';
  static const String reportToolUsage = '/api/v1/reports/tool-usage';
  static const String reportMaintenanceDue = '/api/v1/reports/maintenance-due';

  // File Upload
  static const String uploadFile = '/api/v1/files/upload';
  static String downloadFile(String fileId) => '/api/v1/files/$fileId';

  // Headers
  static const String authorizationHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String acceptHeader = 'Accept';
  static const String xApiVersionHeader = 'X-API-Version';
  static const String xDeviceIdHeader = 'X-Device-ID';
  static const String xFlavorHeader = 'X-Flavor';

  static const String bearerPrefix = 'Bearer ';
  static const String applicationJson = 'application/json';
  static const String apiVersion = '1.0';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const String pageKey = 'page';
  static const String pageSizeKey = 'page_size';

  // Retry
  static const int maxRetryAttempts = 3;
  static const int retryDelayMs = 1000;
}
