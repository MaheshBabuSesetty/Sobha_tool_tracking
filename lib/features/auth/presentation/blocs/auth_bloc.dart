import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:power_tool_tracking/core/services/firebase_service.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';
import 'package:power_tool_tracking/features/auth/domain/entities/user_entity.dart';
import 'package:power_tool_tracking/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:power_tool_tracking/features/auth/domain/usecases/login_usecase.dart';
import 'package:power_tool_tracking/features/auth/domain/usecases/logout_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthUseCase checkAuthUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _checkAuthUseCase = checkAuthUseCase,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested, transformer: droppable());
    on<AuthLoginRequested>(_onLoginRequested, transformer: droppable());
    on<AuthLogoutRequested>(_onLogoutRequested, transformer: droppable());
  }

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthUseCase _checkAuthUseCase;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthCheckingStatus());
    final result = await _checkAuthUseCase();
    result.fold(
      onSuccess: (user) => user != null
          ? emit(AuthAuthenticated(user: user))
          : emit(const AuthUnauthenticated()),
      onFailure: (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    result.fold(
      onSuccess: (user) {
        AppLogger.info('Login successful for: ${user.email}');
        // FirebaseService.setUserId(user.id);
        // FirebaseService.logEvent('login', parameters: {'role': user.role});
        emit(AuthAuthenticated(user: user));
      },
      onFailure: (failure) {
        AppLogger.warning('Login failed: ${failure.message}');
        emit(AuthError(message: failure.message));
      },
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _logoutUseCase();
    // FirebaseService.logEvent('logout');
    emit(const AuthUnauthenticated());
  }
}
