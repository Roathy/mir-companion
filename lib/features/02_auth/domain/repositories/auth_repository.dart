import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../entities/auth_token.dart';
import '../entities/login_credentials.dart';
import '../failures/auth_failures.dart';

/// Repository interface for authentication operations.
/// 
/// This abstract class defines the contract for authentication-related
/// data operations. It follows the Repository pattern and uses Either
/// for functional error handling.
abstract class AuthRepository {
  /// Authenticates a user with the provided credentials.
  /// 
  /// Returns [AuthToken] on successful login or [AuthFailure] on error.
  Future<Either<AuthFailure, AuthToken>> login(LoginCredentials credentials);

  /// Logs out the current user and clears authentication data.
  /// 
  /// Returns [void] on success or [AuthFailure] on error.
  Future<Either<AuthFailure, void>> logout();

  /// Refreshes the current authentication token.
  /// 
  /// Returns new [AuthToken] on success or [AuthFailure] on error.
  Future<Either<AuthFailure, AuthToken>> refreshToken();

  /// Gets the current authenticated user information.
  /// 
  /// Returns [User] if authenticated, null if not, or [AuthFailure] on error.
  Future<Either<AuthFailure, User?>> getCurrentUser();

  /// Checks if the user is currently logged in with a valid token.
  /// 
  /// Returns true if logged in and token is valid, false otherwise.
  Future<Either<AuthFailure, bool>> isLoggedIn();

  /// Clears all stored authentication data.
  /// 
  /// Returns [void] on success or [AuthFailure] on error.
  Future<Either<AuthFailure, void>> clearAuthData();

  /// Gets the current authentication token if available.
  /// 
  /// Returns [AuthToken] if available or [AuthFailure] if not found or invalid.
  Future<Either<AuthFailure, AuthToken?>> getStoredToken();

  /// Validates if the current token is still valid.
  /// 
  /// Returns true if token exists and is not expired, false otherwise.
  Future<Either<AuthFailure, bool>> validateToken();
}