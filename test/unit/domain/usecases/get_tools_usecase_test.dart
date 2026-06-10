import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:power_tool_tracking/core/errors/failures.dart';
import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/domain/entities/tool_entity.dart';
import 'package:power_tool_tracking/domain/repositories/tool_repository.dart';
import 'package:power_tool_tracking/domain/usecases/tool/get_tools_usecase.dart';

class MockToolRepository extends Mock implements ToolRepository {}

void main() {
  late GetToolsUseCase sut;
  late MockToolRepository mockRepository;

  final testTools = [
    ToolEntity(
      id: 'tool-1',
      name: 'Fuel Drill',
      brand: 'Milwaukee',
      model: 'M18',
      serialNumber: 'SN-001',
      category: 'Drill',
      status: ToolStatus.available,
      condition: ToolCondition.excellent,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    ),
    ToolEntity(
      id: 'tool-2',
      name: 'Circular Saw',
      brand: 'DeWalt',
      model: 'DCS575',
      serialNumber: 'SN-002',
      category: 'Circular Saw',
      status: ToolStatus.checkedOut,
      condition: ToolCondition.good,
      assignedWorkerName: 'John Doe',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    ),
  ];

  setUp(() {
    mockRepository = MockToolRepository();
    sut = GetToolsUseCase(mockRepository);
    registerFallbackValue(const ToolFilter());
  });

  group('GetToolsUseCase', () {
    test('returns list of tools with no filter', () async {
      when(() => mockRepository.getTools(filter: any(named: 'filter')))
          .thenAnswer((_) async => Success(testTools));

      final result = await sut(null);

      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(2));
    });

    test('returns empty list when no tools exist', () async {
      when(() => mockRepository.getTools(filter: any(named: 'filter')))
          .thenAnswer((_) async => const Success([]));

      final result = await sut(null);

      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });

    test('passes filter to repository', () async {
      const filter = ToolFilter(status: ToolStatus.available);
      when(() => mockRepository.getTools(filter: any(named: 'filter')))
          .thenAnswer((_) async => Success([testTools[0]]));

      final result = await sut(filter);

      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(1));
    });

    test('returns CacheFailure on local storage error', () async {
      when(() => mockRepository.getTools(filter: any(named: 'filter')))
          .thenAnswer(
              (_) async => const ResultFailure(CacheFailure(message: 'DB error')));

      final result = await sut(null);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<CacheFailure>());
    });

    test('returns NoInternetFailure when offline with no cache', () async {
      when(() => mockRepository.getTools(filter: any(named: 'filter')))
          .thenAnswer((_) async => const ResultFailure(NoInternetFailure()));

      final result = await sut(null);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<NoInternetFailure>());
    });
  });
}
