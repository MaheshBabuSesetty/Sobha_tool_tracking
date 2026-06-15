import 'package:get_it/get_it.dart';
import 'package:power_tool_tracking/features/rfid_scan/di/rfid_module.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dio/dio.dart';
// import 'package:power_tool_tracking/core/network/api_client.dart';
// import 'package:power_tool_tracking/core/network/interceptors/auth_interceptor.dart';
// import 'package:power_tool_tracking/core/network/interceptors/logging_interceptor.dart';
// import 'package:power_tool_tracking/core/network/interceptors/retry_interceptor.dart';
// import 'package:power_tool_tracking/core/services/connectivity_service.dart';
import 'package:power_tool_tracking/core/network/mobile_api_client.dart';
import 'package:power_tool_tracking/core/storage/preference_service.dart';
import 'package:power_tool_tracking/core/storage/secure_storage_service.dart';
import 'package:power_tool_tracking/data/database/app_database.dart';
import 'package:power_tool_tracking/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:power_tool_tracking/features/tools/data/datasources/tool_local_datasource.dart';
import 'package:power_tool_tracking/features/pm/data/datasources/mobile_datasource.dart';
// import 'package:power_tool_tracking/features/auth/data/datasources/auth_remote_datasource.dart';
// import 'package:power_tool_tracking/features/tools/data/datasources/tool_remote_datasource.dart';
import 'package:power_tool_tracking/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:power_tool_tracking/features/pm/data/repositories/pm_repository_impl.dart';
import 'package:power_tool_tracking/features/tools/data/repositories/tool_repository_impl.dart';
import 'package:power_tool_tracking/features/auth/domain/repositories/auth_repository.dart';
import 'package:power_tool_tracking/features/pm/domain/repositories/pm_repository.dart';
import 'package:power_tool_tracking/features/tools/domain/repositories/tool_repository.dart';
import 'package:power_tool_tracking/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:power_tool_tracking/features/auth/domain/usecases/login_usecase.dart';
import 'package:power_tool_tracking/features/auth/domain/usecases/logout_usecase.dart';
import 'package:power_tool_tracking/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:power_tool_tracking/features/pm/domain/usecases/confirm_tool_receipt_usecase.dart';
import 'package:power_tool_tracking/features/pm/domain/usecases/get_pm_request_detail_usecase.dart';
import 'package:power_tool_tracking/features/pm/domain/usecases/get_pm_requests_usecase.dart';
import 'package:power_tool_tracking/features/pm/domain/usecases/get_tools_to_receive_usecase.dart';
import 'package:power_tool_tracking/features/pm/domain/usecases/pm_issue_tool_usecase.dart';
import 'package:power_tool_tracking/features/tools/domain/usecases/checkin_tool_usecase.dart';
import 'package:power_tool_tracking/features/tools/domain/usecases/checkout_tool_usecase.dart';
import 'package:power_tool_tracking/features/tools/domain/usecases/create_tool_usecase.dart';
import 'package:power_tool_tracking/features/tools/domain/usecases/delete_tool_usecase.dart';
import 'package:power_tool_tracking/features/tools/domain/usecases/get_tool_by_id_usecase.dart';
import 'package:power_tool_tracking/features/tools/domain/usecases/get_tools_usecase.dart';
import 'package:power_tool_tracking/features/tools/domain/usecases/sync_tools_usecase.dart';
import 'package:power_tool_tracking/features/tools/domain/usecases/update_tool_usecase.dart';
import 'package:power_tool_tracking/presentation/blocs/app/app_bloc.dart';
import 'package:power_tool_tracking/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:power_tool_tracking/features/pm/presentation/blocs/pm_bloc.dart';
import 'package:power_tool_tracking/features/pm/presentation/blocs/receive_tool_bloc.dart';
import 'package:power_tool_tracking/presentation/blocs/theme/theme_bloc.dart';
import 'package:power_tool_tracking/features/tools/presentation/blocs/tool_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  await PreferenceService.initialize();

  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  _registerCore();
  // _registerNetwork();   // commented out — static data mode
  _registerDatabase();
  _registerDataSources();
  _registerRepositories();
  _registerUseCases();
  _registerBlocs();
  RfidModule.register(sl);
}

void _registerCore() {
  sl.registerLazySingleton<SecureStorageService>(SecureStorageService.new);
  // sl.registerLazySingleton<ConnectivityService>(ConnectivityService.new);
}

// void _registerNetwork() {
//   final secureStorage = sl<SecureStorageService>();
//   final dio = Dio();
//   sl
//     ..registerLazySingleton<LoggingInterceptor>(LoggingInterceptor.new)
//     ..registerLazySingleton<RetryInterceptor>(() => RetryInterceptor(dio: dio))
//     ..registerLazySingleton<AuthInterceptor>(
//       () => AuthInterceptor(secureStorage: secureStorage, dio: dio),
//     )
//     ..registerLazySingleton<ApiClient>(
//       () => ApiClient(
//         authInterceptor: sl<AuthInterceptor>(),
//         loggingInterceptor: sl<LoggingInterceptor>(),
//         retryInterceptor: sl<RetryInterceptor>(),
//       ),
//     );
// }

void _registerDatabase() {
  sl.registerLazySingleton<AppDatabase>(AppDatabase.new);
}

void _registerDataSources() {
  sl
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSource(secureStorage: sl<SecureStorageService>()),
    )
    ..registerLazySingleton<ToolLocalDataSource>(
      () => ToolLocalDataSource(database: sl<AppDatabase>()),
    )
    ..registerLazySingleton<MobileApiClient>(
      () => MobileApiClient(localDataSource: sl<AuthLocalDataSource>()),
    )
    ..registerLazySingleton<MobileDataSource>(
      () => MobileDataSource(apiClient: sl<MobileApiClient>()),
    );
}

void _registerRepositories() {
  sl
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        localDataSource: sl<AuthLocalDataSource>(),
      ),
    )
    ..registerLazySingleton<ToolRepository>(
      () => ToolRepositoryImpl(
        localDataSource: sl<ToolLocalDataSource>(),
      ),
    )
    ..registerLazySingleton<PmRepository>(
      () => PmRepositoryImpl(dataSource: sl<MobileDataSource>()),
    );
}

void _registerUseCases() {
  sl
    // Auth use cases
    ..registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl<AuthRepository>()))
    ..registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl<AuthRepository>()))
    ..registerLazySingleton<CheckAuthUseCase>(() => CheckAuthUseCase(sl<AuthRepository>()))
    ..registerLazySingleton<RefreshTokenUseCase>(() => RefreshTokenUseCase(sl<AuthRepository>()))
    // PM store use cases
    ..registerLazySingleton<GetPmRequestsUseCase>(
        () => GetPmRequestsUseCase(sl<PmRepository>()))
    ..registerLazySingleton<GetPmRequestDetailUseCase>(
        () => GetPmRequestDetailUseCase(sl<PmRepository>()))
    ..registerLazySingleton<PmIssueToolUseCase>(
        () => PmIssueToolUseCase(sl<PmRepository>()))
    ..registerLazySingleton<GetToolsToReceiveUseCase>(
        () => GetToolsToReceiveUseCase(sl<PmRepository>()))
    ..registerLazySingleton<ConfirmToolReceiptUseCase>(
        () => ConfirmToolReceiptUseCase(sl<PmRepository>()))
    // Tool use cases
    ..registerLazySingleton<GetToolsUseCase>(() => GetToolsUseCase(sl<ToolRepository>()))
    ..registerLazySingleton<GetToolByIdUseCase>(() => GetToolByIdUseCase(sl<ToolRepository>()))
    ..registerLazySingleton<CreateToolUseCase>(() => CreateToolUseCase(sl<ToolRepository>()))
    ..registerLazySingleton<UpdateToolUseCase>(() => UpdateToolUseCase(sl<ToolRepository>()))
    ..registerLazySingleton<DeleteToolUseCase>(() => DeleteToolUseCase(sl<ToolRepository>()))
    ..registerLazySingleton<CheckoutToolUseCase>(() => CheckoutToolUseCase(sl<ToolRepository>()))
    ..registerLazySingleton<CheckinToolUseCase>(() => CheckinToolUseCase(sl<ToolRepository>()))
    ..registerLazySingleton<SyncToolsUseCase>(() => SyncToolsUseCase(sl<ToolRepository>()));
}

void _registerBlocs() {
  sl
    ..registerFactory<AppBloc>(AppBloc.new)
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        loginUseCase: sl<LoginUseCase>(),
        logoutUseCase: sl<LogoutUseCase>(),
        checkAuthUseCase: sl<CheckAuthUseCase>(),
      ),
    )
    ..registerLazySingleton<PmBloc>(
      () => PmBloc(
        getRequests: sl<GetPmRequestsUseCase>(),
        getRequestDetail: sl<GetPmRequestDetailUseCase>(),
        issueTool: sl<PmIssueToolUseCase>(),
      ),
    )
    ..registerFactory<ReceiveToolBloc>(
      () => ReceiveToolBloc(
        getToolsToReceive: sl<GetToolsToReceiveUseCase>(),
        confirmReceipt: sl<ConfirmToolReceiptUseCase>(),
      ),
    )
    ..registerFactory<ThemeBloc>(ThemeBloc.new)
    ..registerFactory<ToolBloc>(
      () => ToolBloc(
        getToolsUseCase: sl<GetToolsUseCase>(),
        createToolUseCase: sl<CreateToolUseCase>(),
        updateToolUseCase: sl<UpdateToolUseCase>(),
        deleteToolUseCase: sl<DeleteToolUseCase>(),
        checkoutToolUseCase: sl<CheckoutToolUseCase>(),
        checkinToolUseCase: sl<CheckinToolUseCase>(),
        syncToolsUseCase: sl<SyncToolsUseCase>(),
      ),
    );
}
