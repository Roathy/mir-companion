import 'package:dartz/dartz.dart';
import '../entities/auth_token.dart';
import '../entities/login_credentials.dart';
import '../failures/auth_failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for handling user login.
/// 
/// This class encapsulates the business logic for user authentication.
/// It validates credentials and delegates the actual login to the repository.
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Executes the login use case.
  /// 
  /// Validates the provided credentials and attempts to authenticate
  /// the user through the repository.
  /// 
  /// Returns [AuthToken] on successful login or [AuthFailure] on error.
  Future<Either<AuthFailure, AuthToken>> call(LoginCredentials credentials) async {
    // Validate credentials format and content
    final validationResult = _validateCredentials(credentials);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Attempt login through repository
    return await repository.login(credentials);
  }

  /// Validates the provided login credentials.
  /// 
  /// Returns [AuthFailure] if validation fails, null if valid.
  AuthFailure? _validateCredentials(LoginCredentials credentials) {
    if (credentials.email.isEmpty || credentials.password.isEmpty) {
      return const EmptyCredentialsFailure();
    }

    if (!credentials.isValid) {
      return const InvalidEmailFormatFailure();
    }

    // Additional business rules can be added here
    if (credentials.password.length < 6) {
      return const InvalidCredentialsFailure('Password must be at least 6 characters long');
    }

    return null;
  }
}