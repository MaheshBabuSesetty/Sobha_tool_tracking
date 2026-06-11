library;

import 'dart:async';

import 'package:power_tool_tracking/core/errors/app_exception.dart';
import 'package:power_tool_tracking/core/errors/failures.dart';
import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/features/rfid_scan/data/datasources/rfid_local_datasource.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/entities/rfid_tag.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/repositories/rfid_repository.dart';

class RfidRepositoryImpl implements RfidRepository {
  RfidRepositoryImpl({required this.datasource});

  final RfidLocalDatasource datasource;

  @override
  Future<Result<bool>> initialize() async {
    try {
      return Success(await datasource.initialize());
    } on RfidInitializationException catch (e) {
      return ResultFailure(RfidInitializationFailure(message: e.message, code: e.code));
    } on RfidException catch (e) {
      return ResultFailure(UnexpectedFailure(message: e.message, code: e.code));
    } catch (e) {
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> startScan() async {
    try {
      return Success(await datasource.startScan());
    } on RfidConnectionException catch (e) {
      return ResultFailure(RfidConnectionFailure(message: e.message, code: e.code));
    } on RfidScanException catch (e) {
      return ResultFailure(RfidScanFailure(message: e.message, code: e.code));
    } on RfidException catch (e) {
      return ResultFailure(UnexpectedFailure(message: e.message, code: e.code));
    } catch (e) {
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> stopScan() async {
    try {
      return Success(await datasource.stopScan());
    } on RfidConnectionException catch (e) {
      return ResultFailure(RfidConnectionFailure(message: e.message, code: e.code));
    } on RfidScanException catch (e) {
      return ResultFailure(RfidScanFailure(message: e.message, code: e.code));
    } on RfidException catch (e) {
      return ResultFailure(UnexpectedFailure(message: e.message, code: e.code));
    } catch (e) {
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> setPower(int power) async {
    try {
      return Success(await datasource.setPower(power));
    } on RfidConnectionException catch (e) {
      return ResultFailure(RfidConnectionFailure(message: e.message, code: e.code));
    } on RfidPowerException catch (e) {
      return ResultFailure(RfidPowerFailure(message: e.message, code: e.code));
    } on RfidException catch (e) {
      return ResultFailure(UnexpectedFailure(message: e.message, code: e.code));
    } catch (e) {
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<int>> getPower() async {
    try {
      return Success(await datasource.getPower());
    } on RfidPowerException catch (e) {
      return ResultFailure(RfidPowerFailure(message: e.message, code: e.code));
    } on RfidException catch (e) {
      return ResultFailure(UnexpectedFailure(message: e.message, code: e.code));
    } catch (e) {
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Stream<Result<RfidTag>> watchTags() {
    return datasource
        .watchTags()
        .map<Result<RfidTag>>((tag) => Success(tag))
        .transform(
          StreamTransformer.fromHandlers(
            handleError: (error, _, sink) {
              if (error is RfidConnectionException) {
                sink.add(ResultFailure(
                    RfidConnectionFailure(message: error.message, code: error.code)));
              } else if (error is RfidScanException) {
                sink.add(ResultFailure(
                    RfidScanFailure(message: error.message, code: error.code)));
              } else {
                sink.add(ResultFailure(UnexpectedFailure(message: error.toString())));
              }
            },
          ),
        );
  }

  @override
  Stream<String> watchConnectionState() => datasource.watchConnectionState();

  @override
  Future<Result<bool>> dispose() async {
    try {
      return Success(await datasource.dispose());
    } on RfidException catch (e) {
      return ResultFailure(UnexpectedFailure(message: e.message, code: e.code));
    } catch (e) {
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }
}
