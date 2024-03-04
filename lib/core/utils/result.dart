import '../errors/failures.dart';

/// A lightweight `Result` type. Carries either a success value `T` or a
/// `Failure`. Cleaner than try/catch at every layer boundary and forces the
/// caller to acknowledge the error path at compile time via pattern matching.
///
/// Usage:
/// ```dart
/// final Result<User, Failure> r = await authRepo.signIn(...);
/// switch (r) {
///   case Success<User, Failure>(:final User data):
///     // happy path
///   case Err<User, Failure>(:final Failure failure):
///     // render failure.message
/// }
/// ```
sealed class Result<T, F extends Failure> {
  const Result();

  /// Map the success value. Failures pass through unchanged.
  Result<R, F> map<R>(R Function(T value) f) => switch (this) {
    Success<T, F>(:final T data) => Success<R, F>(f(data)),
    Err<T, F>(:final F failure) => Err<R, F>(failure),
  };

  /// Chain another `Result`-returning operation.
  Result<R, F> flatMap<R>(Result<R, F> Function(T value) f) => switch (this) {
    Success<T, F>(:final T data) => f(data),
    Err<T, F>(:final F failure) => Err<R, F>(failure),
  };

  bool get isOk => this is Success<T, F>;
  bool get isErr => this is Err<T, F>;

  T? get dataOrNull => switch (this) {
    Success<T, F>(:final T data) => data,
    Err<T, F>() => null,
  };

  F? get failureOrNull => switch (this) {
    Success<T, F>() => null,
    Err<T, F>(:final F failure) => failure,
  };
}

final class Success<T, F extends Failure> extends Result<T, F> {
  const Success(this.data);
  final T data;
}

final class Err<T, F extends Failure> extends Result<T, F> {
  const Err(this.failure);
  final F failure;
}

/// Convenience constructors so call sites read naturally.
Result<T, Failure> ok<T>(T data) => Success<T, Failure>(data);
Result<T, Failure> err<T>(Failure failure) => Err<T, Failure>(failure);
