import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:power_tool_tracking/core/errors/failures.dart';
import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/domain/entities/tool_entity.dart';
import 'package:power_tool_tracking/domain/repositories/tool_repository.dart';
import 'package:power_tool_tracking/domain/usecases/tool/checkin_tool_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/tool/checkout_tool_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/tool/create_tool_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/tool/delete_tool_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/tool/get_tools_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/tool/sync_tools_usecase.dart';
import 'package:power_tool_tracking/domain/usecases/tool/update_tool_usecase.dart';
import 'package:power_tool_tracking/presentation/blocs/tool/tool_bloc.dart';

class MockGetToolsUseCase extends Mock implements GetToolsUseCase {}
class MockCreateToolUseCase extends Mock implements CreateToolUseCase {}
class MockUpdateToolUseCase extends Mock implements UpdateToolUseCase {}
class MockDeleteToolUseCase extends Mock implements DeleteToolUseCase {}
class MockCheckoutToolUseCase extends Mock implements CheckoutToolUseCase {}
class MockCheckinToolUseCase extends Mock implements CheckinToolUseCase {}
class MockSyncToolsUseCase extends Mock implements SyncToolsUseCase {}

void main() {
  late ToolBloc sut;
  late MockGetToolsUseCase mockGetTools;
  late MockCreateToolUseCase mockCreateTool;
  late MockUpdateToolUseCase mockUpdateTool;
  late MockDeleteToolUseCase mockDeleteTool;
  late MockCheckoutToolUseCase mockCheckoutTool;
  late MockCheckinToolUseCase mockCheckinTool;
  late MockSyncToolsUseCase mockSyncTools;

  final testTool = ToolEntity(
    id: 'tool-1',
    name: 'Fuel Drill',
    brand: 'Milwaukee',
    model: 'M18',
    serialNumber: 'SN-001',
    category: 'Drill',
    status: ToolStatus.available,
    condition: ToolCondition.good,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  setUp(() {
    mockGetTools = MockGetToolsUseCase();
    mockCreateTool = MockCreateToolUseCase();
    mockUpdateTool = MockUpdateToolUseCase();
    mockDeleteTool = MockDeleteToolUseCase();
    mockCheckoutTool = MockCheckoutToolUseCase();
    mockCheckinTool = MockCheckinToolUseCase();
    mockSyncTools = MockSyncToolsUseCase();

    registerFallbackValue(const ToolFilter());
    registerFallbackValue(testTool);
    registerFallbackValue(CheckoutParams(
      toolId: '',
      workerId: '',
      workerName: '',
    ));
    registerFallbackValue(CheckinParams(
      toolId: '',
      condition: ToolCondition.good,
    ));

    sut = ToolBloc(
      getToolsUseCase: mockGetTools,
      createToolUseCase: mockCreateTool,
      updateToolUseCase: mockUpdateTool,
      deleteToolUseCase: mockDeleteTool,
      checkoutToolUseCase: mockCheckoutTool,
      checkinToolUseCase: mockCheckinTool,
      syncToolsUseCase: mockSyncTools,
    );
  });

  tearDown(() => sut.close());

  test('initial state is ToolState with initial status', () {
    expect(sut.state.status, equals(ToolListStatus.initial));
  });

  group('ToolLoadRequested', () {
    blocTest<ToolBloc, ToolState>(
      'emits success state with tools',
      build: () {
        when(() => mockGetTools(any())).thenAnswer(
          (_) async => Success([testTool]),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const ToolLoadRequested()),
      expect: () => [
        predicate<ToolState>((s) => s.isLoading),
        predicate<ToolState>((s) => s.isSuccess && s.tools.length == 1),
      ],
    );

    blocTest<ToolBloc, ToolState>(
      'emits empty status when no tools found',
      build: () {
        when(() => mockGetTools(any())).thenAnswer(
          (_) async => const Success([]),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const ToolLoadRequested()),
      expect: () => [
        predicate<ToolState>((s) => s.isLoading),
        predicate<ToolState>((s) => s.isEmpty),
      ],
    );

    blocTest<ToolBloc, ToolState>(
      'emits failure state on error',
      build: () {
        when(() => mockGetTools(any())).thenAnswer(
          (_) async => const ResultFailure(
            CacheFailure(message: 'Database error'),
          ),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const ToolLoadRequested()),
      expect: () => [
        predicate<ToolState>((s) => s.isLoading),
        predicate<ToolState>((s) => s.hasError),
      ],
    );
  });

  group('ToolSearchChanged', () {
    blocTest<ToolBloc, ToolState>(
      'filters tools by search query',
      build: () {
        when(() => mockGetTools(any())).thenAnswer(
          (_) async => Success([testTool]),
        );
        return sut;
      },
      seed: () => ToolState(
        status: ToolListStatus.success,
        tools: [testTool],
        filteredTools: [testTool],
      ),
      act: (bloc) => bloc.add(const ToolSearchChanged(query: 'Drill')),
      expect: () => [
        predicate<ToolState>((s) => s.filteredTools.length == 1),
      ],
    );

    blocTest<ToolBloc, ToolState>(
      'shows empty state when no search results',
      build: () => sut,
      seed: () => ToolState(
        status: ToolListStatus.success,
        tools: [testTool],
        filteredTools: [testTool],
      ),
      act: (bloc) => bloc.add(const ToolSearchChanged(query: 'Nonexistent Tool XYZ')),
      expect: () => [
        predicate<ToolState>((s) => s.isEmpty && s.filteredTools.isEmpty),
      ],
    );
  });
}
