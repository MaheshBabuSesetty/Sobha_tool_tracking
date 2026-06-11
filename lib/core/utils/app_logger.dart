// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';
import 'package:power_tool_tracking/flavors/environment_config.dart';

class AppLogger {
  AppLogger._();

  static late Logger _logger;
  static bool _initialized = false;

  static void initialize({bool enableDebugLogs = false}) {
    _logger = Logger(
      level: enableDebugLogs ? Level.debug : Level.warning,
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        // if (EnvironmentConfig.isProduction) _CrashlyticsOutput(),
      ]),
    );
    _initialized = true;
  }

  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.e(message, error: error, stackTrace: stackTrace);
    // if (EnvironmentConfig.enableCrashlytics && error != null) {
    //   FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: message.toString());
    // }
  }

  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.f(message, error: error, stackTrace: stackTrace);
    // if (EnvironmentConfig.enableCrashlytics) {
    //   FirebaseCrashlytics.instance.recordError(
    //     error ?? message,
    //     stackTrace,
    //     reason: message.toString(),
    //     fatal: true,
    //   );
    // }
  }

  static void apiRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    if (EnvironmentConfig.isProduction) return;
    _logger.d('→ $method $url\nHeaders: $headers\nBody: $body');
  }

  static void apiResponse({
    required String url,
    required int statusCode,
    dynamic body,
    int? durationMs,
  }) {
    if (EnvironmentConfig.isProduction) return;
    _logger.d('← $statusCode $url (${durationMs}ms)\nBody: $body');
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      initialize(enableDebugLogs: !EnvironmentConfig.isProduction);
    }
  }
}

// class _CrashlyticsOutput extends LogOutput {
//   @override
//   void output(OutputEvent event) {
//     if (event.level.index >= Level.error.index) {
//       FirebaseCrashlytics.instance.log(event.lines.join('\n'));
//     }
//   }
// }
