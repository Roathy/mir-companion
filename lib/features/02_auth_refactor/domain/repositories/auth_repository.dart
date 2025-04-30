import 'package:dartz/dartz.dart';

import '../../../../core/infra/error/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, String?>> getStoredAuthToken();
  Future<Either<Failure, void>> saveAuthToken(String token);
  Future<Either<Failure, void>> clearAuthToken();
}
