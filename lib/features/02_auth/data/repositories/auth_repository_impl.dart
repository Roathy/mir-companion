import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/failures/auth_failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

/// Implementation of [AuthRepository] that coordinates between
/// remote and local data sources.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<AuthFailure, AuthToken>> login(LoginCredentials credentials) async {
    try {
      // Attempt remote login
      final loginResponse = await remoteDataSource.login(credentials);
      
      if (!loginResponse.success || loginResponse.token == null) {
        final errorMessage = loginResponse.error?['message'] as String? ?? 
                           loginResponse.message ?? 
                           'Login failed';
        return Left(InvalidCredentialsFailure(errorMessage));
      }

      // Convert to domain entities
      final authTokenModel = loginResponse.data!.toAuthToken()!;
      final authToken = authTokenModel.toEntity();

      // Save token locally
      await localDataSource.saveAuthToken(authTokenModel);

      // Save user if available
      if (loginResponse.user != null) {
        await localDataSource.saveUser(loginResponse.user!);
      }

      return Right(authToken);
    } on RemoteDataSourceException catch (e) {
      return Left(_mapRemoteExceptionToFailure(e));
    } on LocalDataSourceException catch (e) {
      return Left(_mapLocalExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure('Login failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, void>> logout() async {
    try {
      // Get current token for remote logout
      final storedToken = await localDataSource.getAuthToken();
      
      if (storedToken != null && storedToken.isValid) {
        // Attempt remote logout (don't fail if this fails)
        try {
          await remoteDataSource.logout(storedToken.accessToken);
        } catch (e) {
          // Log the error but continue with local logout
          print('Remote logout failed: $e');
        }
      }

      // Clear all local auth data
      await localDataSource.clearAllAuthData();

      return const Right(null);
    } on LocalDataSourceException catch (e) {
      return Left(_mapLocalExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure('Logout failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, AuthToken>> refreshToken() async {
    try {
      // Get current token
      final storedToken = await localDataSource.getAuthToken();
      
      if (storedToken == null || storedToken.refreshToken == null) {
        return const Left(TokenExpiredFailure());
      }

      // Attempt to refresh token
      final newTokenModel = await remoteDataSource.refreshToken(storedToken.refreshToken!);
      final newToken = newTokenModel.toEntity();

      // Save the new token
      await localDataSource.saveAuthToken(newTokenModel);

      return Right(newToken);
    } on RemoteDataSourceException catch (e) {
      // If refresh fails, clear stored token
      await localDataSource.deleteAuthToken();
      return Left(_mapRemoteExceptionToFailure(e));
    } on LocalDataSourceException catch (e) {
      return Left(_mapLocalExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure('Token refresh failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, User?>> getCurrentUser() async {
    try {
      // First check if we have a cached user
      final cachedUser = await localDataSource.getUser();
      
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }

      // If no cached user, get current token and fetch from remote
      final storedToken = await localDataSource.getAuthToken();
      
      if (storedToken == null || !storedToken.isValid) {
        return const Right(null);
      }

      // Fetch user from remote
      final userModel = await remoteDataSource.getUserProfile(storedToken.accessToken);
      
      // Cache the user locally
      await localDataSource.saveUser(userModel);
      
      return Right(userModel.toEntity());
    } on RemoteDataSourceException catch (e) {
      return Left(_mapRemoteExceptionToFailure(e));
    } on LocalDataSourceException catch (e) {
      return Left(_mapLocalExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to get current user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> isLoggedIn() async {
    try {
      return Right(await localDataSource.hasValidToken());
    } on LocalDataSourceException catch (e) {
      return Left(_mapLocalExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to check login status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, void>> clearAuthData() async {
    try {
      await localDataSource.clearAllAuthData();
      return const Right(null);
    } on LocalDataSourceException catch (e) {
      return Left(_mapLocalExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to clear auth data: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, AuthToken?>> getStoredToken() async {
    try {
      final storedToken = await localDataSource.getAuthToken();
      return Right(storedToken?.toEntity());
    } on LocalDataSourceException catch (e) {
      return Left(_mapLocalExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to get stored token: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> validateToken() async {
    try {
      final storedToken = await localDataSource.getAuthToken();
      
      if (storedToken == null) {
        return const Right(false);
      }

      // Check if token is expired
      if (storedToken.isExpired) {
        // Token is expired, try to refresh it
        final refreshResult = await refreshToken();
        return refreshResult.fold(
          (failure) => const Right(false),
          (newToken) => const Right(true),
        );
      }

      return Right(storedToken.isValid);
    } on LocalDataSourceException catch (e) {
      return Left(_mapLocalExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to validate token: ${e.toString()}'));
    }
  }

  /// Maps [RemoteDataSourceException] to [AuthFailure]
  AuthFailure _mapRemoteExceptionToFailure(RemoteDataSourceException e) {
    if (e.statusCode != null) {
      switch (e.statusCode) {
        case 401:
          return const UnauthorizedFailure();
        case 403:
          return const UnauthorizedFailure();
        case 422:
          return InvalidCredentialsFailure(e.message);
        case 429:
          return const TooManyAttemptsFailure();
        case 500:
        case 502:
        case 503:
        case 504:
          return ServerFailure(e.message, e.statusCode);
        default:
          return ServerFailure(e.message, e.statusCode);
      }
    }

    // Network-related errors
    if (e.message.toLowerCase().contains('timeout') ||
        e.message.toLowerCase().contains('connection')) {
      return NetworkFailure(e.message);
    }

    return ServerFailure(e.message);
  }

  /// Maps [LocalDataSourceException] to [AuthFailure]
  AuthFailure _mapLocalExceptionToFailure(LocalDataSourceException e) {
    return UnknownFailure('Local storage error: ${e.message}');
  }
}