// import 'package:power_tool_tracking/core/services/connectivity_service.dart';
// import 'package:power_tool_tracking/core/storage/preference_service.dart';
import 'package:power_tool_tracking/core/errors/failures.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';
import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/features/tools/data/datasources/tool_local_datasource.dart';
// import 'package:power_tool_tracking/features/tools/data/datasources/tool_remote_datasource.dart';
// import 'package:power_tool_tracking/features/tools/data/mappers/tool_mapper.dart';
import 'package:power_tool_tracking/data/static/static_data.dart';
import 'package:power_tool_tracking/features/tools/domain/entities/tool_entity.dart';
import 'package:power_tool_tracking/features/tools/domain/repositories/tool_repository.dart';
import 'package:uuid/uuid.dart';

class ToolRepositoryImpl implements ToolRepository {
  const ToolRepositoryImpl({
    // required this.remoteDataSource,
    required this.localDataSource,
    // required this.connectivityService,
  });

  // final ToolRemoteDataSource remoteDataSource;
  final ToolLocalDataSource localDataSource;
  // final ConnectivityService connectivityService;

  static const _uuid = Uuid();

  @override
  Future<Result<List<ToolEntity>>> getTools({ToolFilter? filter}) async {
    try {
      // ── STATIC DATA (API call commented out) ──────────────────────────
      // if (connectivityService.isOnline) {
      //   final result = await remoteDataSource.getTools();
      //   if (result.isSuccess) {
      //     final tools = result.data!.map((m) => m.toEntity()).toList();
      //     await localDataSource.saveAllTools(tools);
      //     return Success(tools);
      //   }
      // }
      // ─────────────────────────────────────────────────────────────────

      // Seed local DB with static data on first load, then read from DB
      final localTools = await localDataSource.getTools(filter: filter);
      if (localTools.isEmpty) {
        await localDataSource.saveAllTools(StaticData.tools);
        return Success(await localDataSource.getTools(filter: filter));
      }
      return Success(localTools);
    } catch (e, st) {
      AppLogger.error('GetTools failed', e, st);
      return Success(StaticData.tools);
    }
  }

  @override
  Stream<List<ToolEntity>> watchTools({ToolFilter? filter}) =>
      localDataSource.watchTools(filter: filter);

  @override
  Future<Result<ToolEntity>> getToolById(String id) async {
    try {
      // ── STATIC DATA (API call commented out) ──────────────────────────
      // if (connectivityService.isOnline) {
      //   final result = await remoteDataSource.getToolById(id);
      //   if (result.isSuccess) {
      //     final tool = result.data!.toEntity();
      //     await localDataSource.saveTool(tool);
      //     return Success(tool);
      //   }
      // }
      // ─────────────────────────────────────────────────────────────────

      final localTool = await localDataSource.getToolById(id);
      if (localTool != null) return Success(localTool);

      final staticTool = StaticData.tools.where((t) => t.id == id).firstOrNull;
      if (staticTool != null) return Success(staticTool);

      return const ResultFailure(NotFoundFailure(message: 'Tool not found'));
    } catch (e, st) {
      AppLogger.error('GetToolById failed', e, st);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<ToolEntity>> createTool(ToolEntity tool) async {
    try {
      final newTool = tool.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await localDataSource.saveTool(newTool, changeType: 'create');

      // ── STATIC DATA (API call commented out) ──────────────────────────
      // if (connectivityService.isOnline) {
      //   final result = await remoteDataSource.createTool(newTool.toModel().toJson());
      //   if (result.isSuccess) {
      //     final serverTool = result.data!.toEntity();
      //     await localDataSource.saveTool(serverTool.copyWith(isSynced: true));
      //     return Success(serverTool);
      //   }
      // }
      // ─────────────────────────────────────────────────────────────────

      return Success(newTool);
    } catch (e, st) {
      AppLogger.error('CreateTool failed', e, st);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<ToolEntity>> updateTool(ToolEntity tool) async {
    try {
      final updatedTool = tool.copyWith(
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await localDataSource.updateTool(updatedTool, changeType: 'update');

      // ── STATIC DATA (API call commented out) ──────────────────────────
      // if (connectivityService.isOnline) {
      //   final result = await remoteDataSource.updateTool(
      //     tool.id,
      //     updatedTool.toModel().toJson(),
      //   );
      //   if (result.isSuccess) {
      //     final serverTool = result.data!.toEntity();
      //     await localDataSource.saveTool(serverTool.copyWith(isSynced: true));
      //     return Success(serverTool);
      //   }
      // }
      // ─────────────────────────────────────────────────────────────────

      return Success(updatedTool);
    } catch (e, st) {
      AppLogger.error('UpdateTool failed', e, st);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> deleteTool(String id) async {
    try {
      await localDataSource.deleteTool(id);

      // ── STATIC DATA (API call commented out) ──────────────────────────
      // if (connectivityService.isOnline) {
      //   final result = await remoteDataSource.deleteTool(id);
      //   if (!result.isSuccess) {
      //     AppLogger.warning('Remote delete failed for tool $id, will retry in sync');
      //   }
      // }
      // ─────────────────────────────────────────────────────────────────

      return const Success(true);
    } catch (e, st) {
      AppLogger.error('DeleteTool failed', e, st);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<ToolEntity>> checkoutTool(CheckoutParams params) async {
    try {
      final existingTool = await localDataSource.getToolById(params.toolId);
      if (existingTool == null) {
        return const ResultFailure(NotFoundFailure(message: 'Tool not found'));
      }

      final updatedTool = existingTool.copyWith(
        status: ToolStatus.checkedOut,
        assignedWorkerId: params.workerId,
        assignedWorkerName: params.workerName,
        assignedProjectId: params.projectId,
        assignedProjectName: params.projectName,
        checkedOutAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await localDataSource.updateTool(updatedTool, changeType: 'update');

      // ── STATIC DATA (API call commented out) ──────────────────────────
      // if (connectivityService.isOnline) {
      //   final result = await remoteDataSource.checkoutTool(
      //     params.toolId,
      //     {
      //       'worker_id': params.workerId,
      //       'worker_name': params.workerName,
      //       if (params.projectId != null) 'project_id': params.projectId,
      //       if (params.projectName != null) 'project_name': params.projectName,
      //       if (params.expectedReturnDate != null)
      //         'expected_return_date': params.expectedReturnDate!.toIso8601String(),
      //       if (params.notes != null) 'notes': params.notes,
      //     },
      //   );
      //   if (result.isSuccess) {
      //     final serverTool = result.data!.toEntity();
      //     await localDataSource.saveTool(serverTool.copyWith(isSynced: true));
      //     return Success(serverTool);
      //   }
      // }
      // ─────────────────────────────────────────────────────────────────

      return Success(updatedTool);
    } catch (e, st) {
      AppLogger.error('CheckoutTool failed', e, st);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<ToolEntity>> checkinTool(CheckinParams params) async {
    try {
      final existingTool = await localDataSource.getToolById(params.toolId);
      if (existingTool == null) {
        return const ResultFailure(NotFoundFailure(message: 'Tool not found'));
      }

      final updatedTool = existingTool.copyWith(
        status: ToolStatus.available,
        condition: params.condition,
        assignedWorkerId: null,
        assignedWorkerName: null,
        assignedProjectId: null,
        assignedProjectName: null,
        checkedOutAt: null,
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await localDataSource.updateTool(updatedTool, changeType: 'update');

      // ── STATIC DATA (API call commented out) ──────────────────────────
      // if (connectivityService.isOnline) {
      //   final result = await remoteDataSource.checkinTool(
      //     params.toolId,
      //     {
      //       'condition': params.condition.displayName.toLowerCase(),
      //       if (params.notes != null) 'notes': params.notes,
      //       'damage_reported': params.damageReported,
      //     },
      //   );
      //   if (result.isSuccess) {
      //     final serverTool = result.data!.toEntity();
      //     await localDataSource.saveTool(serverTool.copyWith(isSynced: true));
      //     return Success(serverTool);
      //   }
      // }
      // ─────────────────────────────────────────────────────────────────

      return Success(updatedTool);
    } catch (e, st) {
      AppLogger.error('CheckinTool failed', e, st);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<int>> syncTools() async {
    // ── STATIC DATA (sync disabled) ───────────────────────────────────
    // if (connectivityService.isOffline) {
    //   return const ResultFailure(NoInternetFailure());
    // }
    // try {
    //   final unsyncedTools = await localDataSource.getUnsyncedTools();
    //   if (unsyncedTools.isEmpty) return const Success(0);
    //   final changes = unsyncedTools.map((t) => {
    //         'id': t.id,
    //         'action': 'update',
    //         'data': t.toModel().toJson(),
    //       }).toList();
    //   final lastSyncAt = PreferenceService.lastSyncAt?.toIso8601String();
    //   final result = await remoteDataSource.syncTools(changes, lastSyncAt: lastSyncAt);
    //   return await result.fold(
    //     onSuccess: (serverTools) async {
    //       await localDataSource.saveAllTools(
    //         serverTools.map((m) => m.toEntity()).toList(),
    //       );
    //       for (final tool in unsyncedTools) {
    //         await localDataSource.markAsSynced(tool.id);
    //       }
    //       await PreferenceService.setLastSyncAt(DateTime.now());
    //       return Success(serverTools.length);
    //     },
    //     onFailure: (failure) => ResultFailure<int>(failure),
    //   );
    // } catch (e, st) {
    //   AppLogger.error('SyncTools failed', e, st);
    //   return ResultFailure(UnexpectedFailure(message: e.toString()));
    // }
    // ─────────────────────────────────────────────────────────────────
    return const Success(0);
  }

  @override
  Future<Result<List<ToolEntity>>> getToolsDueForMaintenance() async {
    try {
      final tools = await localDataSource.getToolsDueForMaintenance();
      return Success(tools);
    } catch (e, st) {
      AppLogger.error('GetToolsDueForMaintenance failed', e, st);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<ToolEntity>>> searchTools(String query) async {
    try {
      final filter = ToolFilter(searchQuery: query);
      return getTools(filter: filter);
    } catch (e, st) {
      AppLogger.error('SearchTools failed', e, st);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }
}
