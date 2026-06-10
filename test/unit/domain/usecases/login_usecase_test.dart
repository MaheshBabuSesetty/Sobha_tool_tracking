import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:power_tool_tracking/core/errors/failures.dart';
import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/domain/entities/user_entity.dart';
import 'package:power_tool_tracking/domain/repositories/auth_repository.dart';
import 'package:power_tool_tracking/domain/usecases/auth/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase sut;
  late MockAuthRepository mockRepository;

  const testUser = UserEntity(
    id: 'test-user-id',
    email: 'test@company.com',
    name: 'Test User',
    role: 'technician',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    sut = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    const validParams = LoginParams(
      email: 'test@company.com',
      password: 'Password123',
    );

    test('returns UserEntity on successful login', () async {
      when(() => mockRepository.login(
                email: any(named: 'email'),
                password: any(named: 'password'),
              ))
          .thenAnswer((_) async => const Success(testUser));

      final result = await sut(validParams);

      expect(result.isSuccess, isTrue);
      expect(result.data, equals(testUser));
      verify(() => mockRepository.login(
                email: validParams.email,
                password: validParams.password,
              ))
          .called(1);
    });

    test('returns UnauthorizedFailure on invalid credentials', () async {
      when(() => mockRepository.login(
                email: any(named: 'email'),
                password: any(named: 'password'),
              ))
          .thenAnswer(
              (_) async => const ResultFailure(UnauthorizedFailure()));

      final result = await sut(validParams);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<UnauthorizedFailure>());
    });

    test('returns NetworkFailure when offline', () async {
      when(() => mockRepository.login(
                email: any(named: 'email'),
                password: any(named: 'password'),
              ))
          .thenAnswer(
              (_) async => const ResultFailure(NoInternetFailure()));

      final result = await sut(validParams);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<NoInternetFailure>());
    });

    test('propagates email and password to repository exactly', () async {
      const params = LoginParams(
        email: 'user@example.com',
        password: 'StrongP@ss1',
      );

      when(() => mockRepository.login(
                email: params.email,
                password: params.password,
              ))
          .thenAnswer((_) async => const Success(testUser));

      await sut(params);

      verify(() => mockRepository.login(
                email: 'user@example.com',
                password: 'StrongP@ss1',
              ))
          .called(1);
    });
  });
}
