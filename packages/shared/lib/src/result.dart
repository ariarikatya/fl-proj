import 'package:shared/src/utils.dart';

sealed class Result<T> {
  factory Result.ok(T data) = ResultSuccess<T>._;
  factory Result.err(Object e, [StackTrace? stackTrace]) = ResultError<T>._;
  Result._();

  bool get isOk;
  bool get isErr;

  /// Returns data on success, logs error and shows snackbar with parsed error message on failure
  T? unpack() => when(ok: (data) => data, err: handleError);

  TResult when<TResult extends Object?>({
    required TResult Function(T data) ok,
    required TResult Function(Object err, StackTrace? st) err,
  });

  TResult? maybeWhen<TResult extends Object?>({
    TResult Function(T data)? ok,
    TResult Function(Object err, StackTrace? st)? err,
  });
}

final class ResultSuccess<T> extends Result<T> {
  ResultSuccess._(this.data) : super._();
  final T data;

  @override
  bool get isErr => false;
  @override
  bool get isOk => true;

  @override
  TResult when<TResult extends Object?>({
    required TResult Function(T data) ok,
    required TResult Function(Object err, StackTrace? st) err,
  }) {
    return ok(data);
  }

  @override
  TResult? maybeWhen<TResult extends Object?>({
    TResult Function(T data)? ok,
    TResult Function(Object err, StackTrace? st)? err,
  }) {
    return ok?.call(data);
  }
}

final class ResultError<T> extends Result<T> {
  ResultError._(this.err, [this.stackTrace]) : super._() {
    // if (kDebugMode) logger.error('Error caught in Result constructor', err, stackTrace);
  }

  final Object err;
  final StackTrace? stackTrace;

  @override
  bool get isErr => true;
  @override
  bool get isOk => false;

  @override
  TResult when<TResult extends Object?>({
    required TResult Function(T data) ok,
    required TResult Function(Object err, StackTrace? st) err,
  }) {
    return err(this.err, stackTrace);
  }

  @override
  TResult? maybeWhen<TResult extends Object?>({
    TResult Function(T data)? ok,
    TResult Function(Object err, StackTrace? st)? err,
  }) {
    return err?.call(this.err, stackTrace);
  }
}
