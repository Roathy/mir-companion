import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures/auth_failures.dart';

part 'auth_state.freezed.dart';

/// Represents the different states of authentication in the app
@freezed
class AuthState with _$AuthState {
  /// Initial state when the app starts
  const factory AuthState.initial() = _Initial;

  /// Loading state during authentication operations
  const factory AuthState.loading() = _Loading;

  /// User is successfully authenticated
  const factory AuthState.authenticated({
    required User user,
  }) = _Authenticated;

  /// User is not authenticated
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// An error occurred during authentication
  const factory AuthState.error({
    required AuthFailure failure,
  }) = _Error;
}

/// Extension to add convenience methods to AuthState
extension AuthStateX on AuthState {
  /// Returns true if the user is authenticated
  bool get isAuthenticated => maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );

  /// Returns true if an operation is in progress
  bool get isLoading => maybeWhen(
        loading: () => true,
        orElse: () => false,
      );

  /// Returns true if there's an error
  bool get hasError => maybeWhen(
        error: (_) => true,
        orElse: () => false,
      );

  /// Returns the current user if authenticated, null otherwise
  User? get currentUser => maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );

  /// Returns the current error if present, null otherwise
  AuthFailure? get currentError => maybeWhen(
        error: (failure) => failure,
        orElse: () => null,
      );
}