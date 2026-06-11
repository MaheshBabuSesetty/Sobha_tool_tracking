import 'package:power_tool_tracking/core/utils/result.dart';

abstract class UseCase<T, P> {
  const UseCase();
  Future<Result<T>> call(P params);
}

abstract class NoParamUseCase<T> {
  const NoParamUseCase();
  Future<Result<T>> call();
}

abstract class StreamUseCase<T, P> {
  const StreamUseCase();
  Stream<T> call(P params);
}

class NoParams {
  const NoParams();
  static const instance = NoParams();
}

class IntParams {
  const IntParams(this.value);
  final int value;
}
