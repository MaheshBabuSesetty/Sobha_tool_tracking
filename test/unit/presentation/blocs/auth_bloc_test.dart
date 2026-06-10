import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:power_tool_tracking/core/errors/failures.dart';
import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/domain/entities/user_entity.dart';
import 'package:power_tool_tracking/domain/usecases/auth/check_auth_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/auth/login_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/auth/logout_usecase.dart';
import 'package:power_tool_tracking/flavors/app_flavor.dart';
import 'package:power_tool_tracking/flavors/environment_config.dart';
import 'package:power_tool_tracking/presentation/blocs/auth/auth_bloc.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockCheckAuthUseCase extends Mock implements CheckAuthUseCase {}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await EnvironmentConfig.initialize(AppFlavor.dev);
  });

  late AuthBloc sut;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockCheckAuthUseCase mockCheckAuthUseCase;

  const testUser = UserEntity(
    id: 'test-id',
    email: 'test@company.com',
    name: 'Test User',
    role: 'admin',
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockCheckAuthUseCase = MockCheckAuthUseCase();
    registerFallbackValue(const LoginParams(email: '', password: ''));

    sut = AuthBloc(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      checkAuthUseCase: mockCheckAuthUseCase,
    );
  });

  tearDown(() => sut.close());

  test('initial state is AuthInitial', () {
    expect(sut.state, isA<AuthInitial>());
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthCheckingStatus, AuthAuthenticated] when authenticated',
      build: () {
        when(() => mockCheckAuthUseCase()).thenAnswer(
          (_) async => const Success(testUser),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [isA<AuthCheckingStatus>(), isA<AuthAuthenticated>()],
      verify: (bloc) {
        final state = bloc.state as AuthAuthenticated;
        expect(state.user, equals(testUser));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthCheckingStatus, AuthUnauthenticated] when not authenticated',
      build: () {
        when(() => mockCheckAuthUseCase()).thenAnswer(
          (_) async => const Success(null),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [isA<AuthCheckingStatus>(), isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthCheckingStatus, AuthUnauthenticated] on failure',
      build: () {
        when(() => mockCheckAuthUseCase()).thenAnswer(
          (_) async => const ResultFailure(UnexpectedFailure()),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [isA<AuthCheckingStatus>(), isA<AuthUnauthenticated>()],
    );
  });

  group('AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful login',
      build: () {
        when(() => mockLoginUseCase(any())).thenAnswer(
          (_) async => const Success(testUser),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'test@company.com',
        password: 'Password123',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
      verify: (bloc) {
        final state = bloc.state as AuthAuthenticated;
        expect(state.user, equals(testUser));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on login failure',
      build: () {
        when(() => mockLoginUseCase(any())).thenAnswer(
          (_) async => const ResultFailure(UnauthorizedFailure()),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'wrong@company.com',
        password: 'WrongPass',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on logout',
      build: () {
        when(() => mockLogoutUseCase()).thenAnswer(
          (_) async => const Success(true),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );
  });
}
