import 'package:dartz/dartz.dart';
import '../entities/auth_token.dart';
import '../failures/auth_failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for refreshing authentication token.
/// 
/// This class encapsulates the business logic for refreshing
/// expired or soon-to-expire authentication tokens.
class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  /// Executes the refresh token use case.
  /// 
  /// Attempts to refresh the current authentication token.
  /// 
  /// Returns new [AuthToken] on success or [AuthFailure] on error.
  Future<Either<AuthFailure, AuthToken>> call() async {
    try {
      // First check if there's a stored token
      final storedTokenResult = await repository.getStoredToken();
      
      return await storedTokenResult.fold(
        (failure) => Left(failure),
        (storedToken) async {
          if (storedToken == null) {
            return const Left(TokenExpiredFailure());
          }

          // Check if token needs refreshing
          if (!storedToken.isExpired && storedToken.isValid) {
            // Token is still valid, return it
            return Right(storedToken);
          }

          // Token is expired or invalid, attempt refresh
          return await repository.refreshToken();
        },
      );
    } catch (e) {
      return Left(UnknownFailure('Token refresh failed: ${e.toString()}'));
    }
  }

  /// Checks if the current token needs refreshing.
  /// 
  /// Returns true if token should be refreshed (expired or expiring soon),
  /// false if still valid for a reasonable time.
  Future<Either<AuthFailure, bool>> shouldRefresh() async {
    final storedTokenResult = await repository.getStoredToken();
    
    return storedTokenResult.fold(
      (failure) => Left(failure),
      (storedToken) {
        if (storedToken == null) {
          return const Right(true); // No token, needs refresh
        }

        // Check if token expires within the next 5 minutes
        final expiresWithin5Minutes = storedToken.expiresAt
            .isBefore(DateTime.now().add(const Duration(minutes: 5)));

        return Right(expiresWithin5Minutes);
      },
    );
  }
}