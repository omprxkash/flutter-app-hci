import 'package:equatable/equatable.dart';

/// Failure represents an error that has been **handled** and converted into
/// a value that flows through `Result<T, Failure>` instead of being thrown.
///
/// This keeps the data and domain layers free of exceptions at their public
/// boundaries — the presentation layer always gets either data or a typed
/// failure it can render.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  List<Object?> get props => <Object?>[runtimeType, message, cause];

  @override
  String toString() => '$runtimeType($message)';
}

/// Network or backend-unreachable failures.
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network unavailable.'])
    : super(message);
}

/// Authentication-related failures (bad OTP, expired session, unknown user).
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.cause, this.code});

  /// Optional vendor code (e.g. Firebase Auth error code) for analytics.
  final String? code;

  @override
  List<Object?> get props => <Object?>[...super.props, code];
}

/// The user does not have permission to perform the requested action.
class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Not allowed.']) : super(message);
}

/// The requested resource was not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Not found.']) : super(message);
}

/// The input failed validation. `fieldErrors` carries per-field messages so
/// the UI can highlight individual form fields.
class ValidationFailure extends Failure {
  const ValidationFailure(
    super.message, {
    this.fieldErrors = const <String, String>{},
    super.cause,
  });

  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => <Object?>[...super.props, fieldErrors];
}

/// Catch-all for unexpected failures. Should be rare in well-typed code.
class UnknownFailure extends Failure {
  const UnknownFailure(String message, {Object? cause})
    : super(message, cause: cause);
}
