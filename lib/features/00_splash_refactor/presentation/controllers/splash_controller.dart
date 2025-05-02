import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../02_auth_refactor/domain/usecases/get_stored_auth_token_usecase.dart';
import '../../../02_auth_refactor/presentation/providers/auth_provider.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../states/splash_state.dart';

final splashControllerProvider =
    StateNotifierProvider<SplashController, SplashState>(
  (ref) => SplashController(ref.watch(checkAuthStatusUseCaseProvider)),
);

final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) =>
    CheckAuthStatusUseCase(ref.watch(getStoredAuthTokenUseCaseProvider)));

final getStoredAuthTokenUseCaseProvider = Provider<GetStoredAuthTokenUseCase>(
    (ref) => GetStoredAuthTokenUseCase(ref.watch(authRepositoryProvider)));

class SplashController extends StateNotifier<SplashState> {
  final CheckAuthStatusUseCase _checkAuthStatus;

  SplashController(this._checkAuthStatus) : super(const SplashState.initial());

  Future<void> checkAuthStatus() async {
    state = const SplashState.loading();

    final result = await _checkAuthStatus();

    state = result.fold((failure) => SplashState.error(failure.toString()),
        (status) {
      switch (status) {
        case AuthStatus.authenticated:
          return const SplashState.authenticated();
        case AuthStatus.unauthenticated:
          return const SplashState.unauthenticated();
      }
    });
  }
}

