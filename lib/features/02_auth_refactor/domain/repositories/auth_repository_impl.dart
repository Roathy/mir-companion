import 'package:dartz/dartz.dart';

import '../../../../core/infra/error/failure.dart';
import '../../data/datasources/auth_local_datasource.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, String?>> getStoredAuthToken() async {
    try {
      final token = await localDataSource.getStoredAuthToken();
      return Right(token);
    } catch (e) {
      return Left(Failure.cache('Failed to get auth token'));
    }
  }

  @override
  Future<Either<Failure, void>> saveAuthToken(String token) async {
    try {
      await localDataSource.saveAuthToken(token);
      return const Right(null);
    } catch (e) {
      return Left(Failure.cache('Failed to save auth token'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAuthToken() async {
    try {
      await localDataSource.clearAuthToken();
      return const Right(null);
    } catch (e) {
      return Left(Failure.cache('Failed to clear auth token'));
    }
  }
}
