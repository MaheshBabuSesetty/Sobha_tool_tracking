class AppConstants {
  AppConstants._();

  static const String appName = 'Power Tool Tracking';
  static const String companyName = 'Your Company';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  // Storage Keys
  static const String dbName = 'power_tool_tracking.db';
  static const int dbVersion = 1;

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // UI Constants
  static const double borderRadius = 12.0;
  static const double borderRadiusLarge = 20.0;
  static const double cardElevation = 2.0;
  static const double pageHorizontalPadding = 16.0;
  static const double pageVerticalPadding = 24.0;

  // Tool Categories
  static const List<String> toolCategories = [
    'Drill',
    'Circular Saw',
    'Jigsaw',
    'Grinder',
    'Sanders',
    'Router',
    'Nail Gun',
    'Heat Gun',
    'Multimeter',
    'Welding Equipment',
    'Compressor',
    'Generator',
    'Laser Level',
    'Measuring Tool',
    'Other',
  ];

  // Tool Status
  static const String statusAvailable = 'available';
  static const String statusCheckedOut = 'checked_out';
  static const String statusMaintenance = 'in_maintenance';
  static const String statusRetired = 'retired';
  static const String statusLost = 'lost';

  // Tool Condition
  static const String conditionExcellent = 'excellent';
  static const String conditionGood = 'good';
  static const String conditionFair = 'fair';
  static const String conditionPoor = 'poor';

  // Maintenance Types
  static const List<String> maintenanceTypes = [
    'Routine Service',
    'Repair',
    'Calibration',
    'Safety Inspection',
    'Cleaning',
    'Battery Replacement',
    'Blade Replacement',
    'Other',
  ];

  // Sync Status
  static const String syncPending = 'pending';
  static const String syncInProgress = 'in_progress';
  static const String syncCompleted = 'completed';
  static const String syncFailed = 'failed';

  // Cache
  static const Duration cacheExpiry = Duration(hours: 24);
  static const int maxCacheSize = 100;

  // Notification Channels
  static const String channelToolAssignment = 'tool_assignment';
  static const String channelMaintenance = 'maintenance_due';
  static const String channelSync = 'background_sync';
  static const String channelGeneral = 'general';

  // Asset Paths
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderToolPath = 'assets/images/placeholder_tool.png';
  static const String emptyStatePath = 'assets/animations/empty_state.json';
  static const String loadingPath = 'assets/animations/loading.json';
  static const String successPath = 'assets/animations/success.json';
}
