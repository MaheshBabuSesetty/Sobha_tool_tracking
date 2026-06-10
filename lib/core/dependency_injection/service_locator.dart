import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:power_tool_tracking/core/network/api_client.dart';
import 'package:power_tool_tracking/core/network/interceptors/auth_interceptor.dart';
import 'package:power_tool_tracking/core/network/interceptors/logging_interceptor.dart';
import 'package:power_tool_tracking/core/network/interceptors/retry_interceptor.dart';
import 'package:power_tool_tracking/core/services/connectivity_service.dart';
import 'package:power_tool_tracking/core/storage/preference_service.dart';
import 'package:power_tool_tracking/core/storage/secure_storage_service.dart';
import 'package:power_tool_tracking/data/database/app_database.dart';
import 'package:power_tool_tracking/data/datasources/local/auth_local_datasource.dart';
import 'package:power_tool_tracking/data/datasources/local/tool_local_datasource.dart';
import 'package:power_tool_tracking/data/datasources/remote/auth_remote_datasource.dart';
import 'package:power_tool_tracking/data/datasources/remote/tool_remote_datasource.dart';
import 'package:power_tool_tracking/data/repositories/auth_repository_impl.dart';
import 'package:power_tool_tracking/data/repositories/tool_repository_impl.dart';
import 'package:power_tool_tracking/domain/repositories/auth_repository.dart';
import 'package:power_tool_tracking/domain/repositories/tool_repository.dart';
import 'package:power_tool_tracking/domain/usecases/auth/check_auth_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/auth/login_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/auth/logout_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/auth/refresh_token_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/tool/checkin_tool_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/tool/checkout_tool_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/tool/create_tool_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/tool/delete_tool_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/tool/get_tool_by_id_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/tool/get_tools_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/tool/sync_tools_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/tool/update_tool_usecase.dart';
import 'package:power_tool_tracking/presentation/blocs/app/app_bloc.dart';
import 'package:power_tool_tracking/presentation/blocs/auth/auth_bloc.dart';
import 'package:power_tool_tracking/presentation/blocs/theme/theme_bloc.dart';
import 'package:power_tool_tracking/presentation/blocs/tool/tool_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  await PreferenceService.initialize();

  _registerCore();
  _registerNetwork();
  _registerDatabase();
  _registerDataSources();
  _registerRepositories();
  _registerUseCases();
  _registerBlocs();
}

void _registerCore() {
  sl
    ..registerLazySingleton<SecureStorageService>(SecureStorageService.new)
    ..registerLazySingleton<ConnectivityService>(ConnectivityService.new);
}

void _registerNetwork() {
  final secureSorage = sl<SecureStorageService>();

  final dio = Dio();

  sl
    ..registerLazySingleton<LoggingInterceptor>(LoggingInterceptor.new)
    ..registerLazySingleton<RetryInterceptor>(() => RetryInterceptor(dio: dio))
    ..registerLazySingleton<AuthInterceptor>(
      () => AuthInterceptor(secureStorage: secureSorage, dio: dio),
    )
    ..registerLazySingleton<ApiClient>(
      () => ApiClient(
        authInterceptor: sl<AuthInterceptor>(),
        loggingInterceptor: sl<LoggingInterceptor>(),
        retryInterceptor: sl<RetryInterceptor>(),
      ),
    );
}

void _registerDatabase() {
  sl.registerLazySingleton<AppDatabase>(AppDatabase.new);
}

void _registerDataSources() {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(apiClient: sl<ApiClient>()),
    )
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSource(secureStorage: sl<SecureStorageService>()),
    )
    ..registerLazySingleton<ToolRemoteDataSource>(
      () => ToolRemoteDataSource(apiClient: sl<ApiClient>()),
    )
    ..registerLazySingleton<ToolLocalDataSource>(
      () => ToolLocalDataSource(database: sl<AppDatabase>()),
    );
}

void _registerRepositories() {
  sl
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl<AuthRemoteDataSource>(),
        localDataSource: sl<AuthLocalDataSource>(),
        connectivityService: sl<ConnectivityService>(),
      ),
    )
    ..registerLazySingleton<ToolRepository>(
      () => ToolRepositoryImpl(
        remoteDataSource: sl<ToolRemoteDataSource>(),
        localDataSource: sl<ToolLocalDataSource>(),
        connectivityService: sl<ConnectivityService>(),
      ),
    );
}

void _registerUseCases() {
  sl
    // Auth use cases
    ..registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl<AuthRepository>()))
    ..registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl<AuthRepository>()))
    ..registerLazySingleton<CheckAuthUseCase>(() => CheckAuthUseCase(sl<AuthRepository>()))
    ..registerLazySingleton<RefreshTokenUseCase>(() => RefreshTokenUseCase(sl<AuthRepository>()))
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
    ..registerFactory<AuthBloc>(
      () => AuthBloc(
        loginUseCase: sl<LoginUseCase>(),
        logoutUseCase: sl<LogoutUseCase>(),
        checkAuthUseCase: sl<CheckAuthUseCase>(),
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
