import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/02_auth/domain/entities/user.dart';
import '../../features/02_auth/domain/entities/auth_token.dart';
import '../../features/02_auth/domain/entities/login_credentials.dart';
import '../../features/02_auth/domain/failures/auth_failures.dart';
import '../../features/02_auth/domain/use_cases/use_cases.dart';
import '../../features/02_auth/presentation/controllers/auth_controller.dart';
import '../../features/02_auth/presentation/states/auth_state.dart';
import '../../features/02_auth/presentation/providers/auth_providers.dart' as auth_providers;
import 'auth_manager.dart';

/// Implementation of AuthManager that bridges the clean architecture
/// auth feature with a global authentication interface
class AuthManagerImpl implements AuthManager {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final ProviderRef _ref;

  final StreamController<AuthStateChangeEvent> _stateController = 
      StreamController<AuthStateChangeEvent>.broadcast();

  AuthManagerImpl({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required RefreshTokenUseCase refreshTokenUseCase,
    required ProviderRef ref,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        _refreshTokenUseCase = refreshTokenUseCase,
        _ref = ref {
    _initializeStateListener();
  }

  /// Initialize listener to the auth controller state changes
  void _initializeStateListener() {
    _ref.listen<AuthState>(
      auth_providers.authControllerProvider,
      (previous, next) {
        final event = _mapAuthStateToEvent(next);
        _stateController.add(event);
      },
    );
  }

  @override
  Future<bool> get isAuthenticated async {
    final result = await _checkAuthStatusUseCase();
    return result.fold(
      (failure) => false,
      (isAuth) => isAuth,
    );
  }

  @override
  Future<User?> get currentUser async {
    final result = await _getCurrentUserUseCase();
    return result.fold(
      (failure) => null,
      (user) => user,
    );
  }

  @override
  Future<AuthToken?> get currentToken async {
    final result = await _refreshTokenUseCase.shouldRefresh();
    return result.fold(
      (failure) => null,
      (shouldRefresh) async {
        if (shouldRefresh) {
          final refreshResult = await refreshToken();
          return refreshResult.fold(
            (failure) => null,
            (token) => token,
          );
        } else {
          // Get current stored token
          final authState = _ref.read(authControllerProvider);
          final authState = _ref.read(auth_providers.authControllerProvider);
          if (authState.isAuthenticated) {
            // Get stored token from repository  
            final repositoryResult = await _refreshTokenUseCase();
            return repositoryResult.fold(
              (failure) => null,
              (token) => token,
            );
          }
          return null;
        }
      },
    );
  }

  @override
  Future<Either<AuthFailure, User>> login(String email, String password) async {
    final credentials = LoginCredentials(email: email, password: password);
    
    // Use the auth controller to handle login
    _ref.read(auth_providers.authControllerProvider.notifier).login(email, password);
    
    // Wait for the result through the use case
    final result = await _loginUseCase(credentials);
    
    return result.fold(
      (failure) => Left(failure),
      (token) async {
        // Get user after successful login
        final userResult = await _getCurrentUserUseCase();
        return userResult.fold(
          (userFailure) => Left(userFailure),
          (user) => user != null 
              ? Right(user) 
              : const Left(UnknownFailure('User not found after login')),
        );
      },
    );
  }

  @override
  Future<Either<AuthFailure, void>> logout() async {
    // Use the auth controller to handle logout
    _ref.read(auth_providers.authControllerProvider.notifier).logout();
    
    // Execute the logout use case
    return await _logoutUseCase();
  }

  @override
  Future<Either<AuthFailure, AuthToken>> refreshToken() async {
    final result = await _refreshTokenUseCase();
    
    // Update controller state if refresh successful
    result.fold(
      (failure) => {}, // Error handling is done by controller
      (token) => _ref.read(auth_providers.authControllerProvider.notifier).refreshToken(),
    );
    
    return result;
  }

  @override
  Future<void> clearAuthData() async {
    _ref.read(auth_providers.authControllerProvider.notifier).resetState();
    await _logoutUseCase();
  }

  @override
  Future<bool> validateCurrentToken() async {
    final result = await _checkAuthStatusUseCase();
    return result.fold(
      (failure) => false,
      (isValid) => isValid,
    );
  }

  @override
  Stream<AuthStateChangeEvent> get authStateStream => _stateController.stream;

  /// Maps AuthState to AuthStateChangeEvent
  AuthStateChangeEvent _mapAuthStateToEvent(AuthState authState) {
    return authState.when(
      initial: () => const AuthStateChangeEvent(state: AuthenticationState.initial),
      loading: () => const AuthStateChangeEvent(state: AuthenticationState.loading),
      authenticated: (user) => AuthStateChangeEvent(
        state: AuthenticationState.authenticated,
        user: user,
      ),
      unauthenticated: () => const AuthStateChangeEvent(
        state: AuthenticationState.unauthenticated,
      ),
      error: (failure) => AuthStateChangeEvent(
        state: AuthenticationState.error,
        error: failure,
      ),
    );
  }

  void dispose() {
    _stateController.close();
  }
}

