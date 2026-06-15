class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String dashboard = '/home/dashboard';
  static const String scan = '/home/scan';
  static const String issueTool = '/home/issue-tool';
  static const String issueToolDetail = '/home/issue-tool/:id';
  static const String tools = '/home/tools';
  static const String toolDetail = '/home/tools/:id';
  static const String addTool = '/home/tools/add';
  static const String editTool = '/home/tools/:id/edit';
  static const String toolCheckout = '/home/tools/:id/checkout';
  static const String toolCheckin = '/home/tools/:id/checkin';
  static const String assignments = '/home/assignments';
  static const String maintenance = '/home/maintenance';
  static const String workers = '/home/workers';
  static const String projects = '/home/projects';
  static const String reports = '/home/reports';
  static const String settings = '/home/settings';
  static const String profile = '/home/profile';
  static const String changePassword = '/home/settings/change-password';
  static const String storeDashboard = '/home/store';
  static const String toolsToReceive = '/home/store/receive';
  static const String toolReceiveDetail = '/home/store/receive/:id';
}
