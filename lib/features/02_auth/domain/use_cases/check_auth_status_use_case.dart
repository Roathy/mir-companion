import 'package:dartz/dartz.dart';
import '../failures/auth_failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for checking authentication status.
/// 
/// This class encapsulates the business logic for determining
/// if a user is currently authenticated with valid credentials.
class CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  /// Executes the check authentication status use case.
  /// 
  /// Validates if the user is currently authenticated and has a valid token.
  /// 
  /// Returns true if authenticated with valid token, false otherwise,
  /// or [AuthFailure] on error.
  Future<Either<AuthFailure, bool>> call() async {
    try {
      // Check if user is logged in
      final isLoggedInResult = await repository.isLoggedIn();
      
      return await isLoggedInResult.fold(
        (failure) => Left(failure),
        (isLoggedIn) async {
          if (!isLoggedIn) {
            return const Right(false);
          }
          
          // User is logged in, validate the token
          final validateTokenResult = await repository.validateToken();
          
          return validateTokenResult.fold(
            (failure) => Left(failure),
            (isValid) => Right(isValid),
          );
        },
      );
    } catch (e) {
      return Left(UnknownFailure('Auth status check failed: ${e.toString()}'));
    }
  }
}