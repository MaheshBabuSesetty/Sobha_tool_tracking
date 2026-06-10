import 'package:power_tool_tracking/app.dart';
import 'package:power_tool_tracking/core/dependency_injection/service_locator.dart';
// import 'package:power_tool_tracking/core/services/firebase_service.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';
import 'package:power_tool_tracking/flavors/app_flavor.dart';
import 'package:power_tool_tracking/flavors/environment_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvironmentConfig.initialize(AppFlavor.dev);

  AppLogger.initialize(enableDebugLogs: true);
  AppLogger.info('Starting Power Tool Tracking [DEV]');

  // await FirebaseService.initialize();
  await configureDependencies();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const PowerToolTrackingApp());
}
