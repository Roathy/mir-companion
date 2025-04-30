import 'package:dartz/dartz.dart';

import '../../../../core/infra/error/failure.dart';
import '../repositories/auth_repository.dart';

class GetStoredAuthTokenUseCase {
  final AuthRepository repository;

  GetStoredAuthTokenUseCase(this.repository);

  Future<Either<Failure, String?>> call() async {
    return await repository.getStoredAuthToken();
  }
}

