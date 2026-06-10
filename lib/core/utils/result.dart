import 'package:power_tool_tracking/core/errors/failures.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultFailure<T>;

  T? get data => switch (this) {
        Success<T> s => s.value,
        _ => null,
      };

  Failure? get error => switch (this) {
        ResultFailure<T> f => f.failure,
        _ => null,
      };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success<T> s => onSuccess(s.value),
      ResultFailure<T> f => onFailure(f.failure),
    };
  }

  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success<T> s => Success(transform(s.value)),
      ResultFailure<T> f => ResultFailure(f.failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);
  final Failure failure;
}
