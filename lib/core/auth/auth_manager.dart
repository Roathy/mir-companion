import 'package:dartz/dartz.dart';
import '../../features/02_auth/domain/entities/user.dart';
import '../../features/02_auth/domain/entities/auth_token.dart';
import '../../features/02_auth/domain/failures/auth_failures.dart';

/// Global authentication manager interface
/// 
/// This interface provides a unified way for all features in the app
/// to interact with authentication functionality without being coupled
/// to specific implementation details.
abstract class AuthManager {
  /// Check if user is currently authenticated
  Future<bool> get isAuthenticated;

  /// Get current user if authenticated
  Future<User?> get currentUser;

  /// Get current authentication token
  Future<AuthToken?> get currentToken;

  /// Login with email and password
  Future<Either<AuthFailure, User>> login(String email, String password);

  /// Logout current user
  Future<Either<AuthFailure, void>> logout();

  /// Refresh authentication token
  Future<Either<AuthFailure, AuthToken>> refreshToken();

  /// Clear all authentication data
  Future<void> clearAuthData();

  /// Check if token is valid and not expired
  Future<bool> validateCurrentToken();

  /// Stream of authentication state changes
  Stream<AuthenticationState> get authStateStream;
}

/// Authentication state for the entire application
enum AuthenticationState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Authentication state change event
class AuthStateChangeEvent {
  final AuthenticationState state;
  final User? user;
  final AuthFailure? error;

  const AuthStateChangeEvent({
    required this.state,
    this.user,
    this.error,
  });
}