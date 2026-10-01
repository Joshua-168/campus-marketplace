import '../errors/failures.dart';

/// Clean Architecture Result Wrapper
/// Encapsulates either a Success value of type [T] or a [Failure].
class Result<T> {
  final T? _data;
  final Failure? _failure;

  const Result.success(T data)
      : _data = data,
        _failure = null;

  const Result.failure(Failure failure)
      : _data = null,
        _failure = failure;

  bool get isSuccess => _failure == null;
  bool get isFailure => _failure != null;

  T get data {
    if (_failure != null) {
      throw StateError('Cannot read data from a failed Result: $_failure');
    }
    return _data as T;
  }

  Failure get failure {
    if (_failure == null) {
      throw StateError('Cannot read failure from a successful Result');
    }
    return _failure;
  }


  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess(data);
    } else {
      return onFailure(failure);
    }
  }
}
