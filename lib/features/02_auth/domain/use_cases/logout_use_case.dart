import 'package:dartz/dartz.dart';
import '../failures/auth_failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for handling user logout.
/// 
/// This class encapsulates the business logic for user logout,
/// including clearing stored authentication data.
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  /// Executes the logout use case.
  /// 
  /// Logs out the current user and clears all authentication data.
  /// 
  /// Returns [void] on success or [AuthFailure] on error.
  Future<Either<AuthFailure, void>> call() async {
    try {
      // Attempt to logout and clear authentication data
      final result = await repository.logout();
      
      return result.fold(
        (failure) => Left(failure),
        (_) async {
          // Ensure all auth data is cleared
          final clearResult = await repository.clearAuthData();
          return clearResult;
        },
      );
    } catch (e) {
      return Left(UnknownFailure('Logout failed: ${e.toString()}'));
    }
  }
}