import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../failures/auth_failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting the current authenticated user.
/// 
/// This class encapsulates the business logic for retrieving
/// the current user information if authenticated.
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  /// Executes the get current user use case.
  /// 
  /// Retrieves the current user information if the user is authenticated.
  /// 
  /// Returns [User] if authenticated and found, null if not authenticated,
  /// or [AuthFailure] on error.
  Future<Either<AuthFailure, User?>> call() async {
    try {
      // First check if user is logged in
      final isLoggedInResult = await repository.isLoggedIn();
      
      return await isLoggedInResult.fold(
        (failure) => Left(failure),
        (isLoggedIn) async {
          if (!isLoggedIn) {
            // User is not authenticated
            return const Right(null);
          }
          
          // User is authenticated, get user info
          return await repository.getCurrentUser();
        },
      );
    } catch (e) {
      return Left(UnknownFailure('Failed to get current user: ${e.toString()}'));
    }
  }
}