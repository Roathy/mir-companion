import 'package:dartz/dartz.dart';

import '../../../../core/infra/error/failure.dart';
import '../../../02_auth_refactor/domain/usecases/get_stored_auth_token_usecase.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
}

class CheckAuthStatusUseCase {
  final GetStoredAuthTokenUseCase getStoredAuthToken;

  CheckAuthStatusUseCase(this.getStoredAuthToken);

  Future<Either<Failure, AuthStatus>> call() async {
    final tokenResult = await getStoredAuthToken();

    return tokenResult.fold((failure) => Left(failure), (token) {
      if (token != null && token.isNotEmpty) {
        return const Right(AuthStatus.authenticated);
      } else {
        return const Right(AuthStatus.unauthenticated);
      }
    });
  }
}
