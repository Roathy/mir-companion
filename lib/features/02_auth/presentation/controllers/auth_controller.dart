import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/use_cases/use_cases.dart';
import '../states/auth_state.dart';

/// Controller for managing authentication state and operations
/// 
/// This class handles all authentication-related operations and manages
/// the authentication state using Riverpod state management.
class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;

  AuthController({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required RefreshTokenUseCase refreshTokenUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        _refreshTokenUseCase = refreshTokenUseCase,
        super(const AuthState.initial());

  /// Attempts to log in the user with the provided credentials
  Future<void> login(String email, String password) async {
    if (state.isLoading) return; // Prevent multiple concurrent logins

    state = const AuthState.loading();

    final credentials = LoginCredentials(email: email, password: password);
    final result = await _loginUseCase(credentials);

    result.fold(
      (failure) => state = AuthState.error(failure: failure),
      (token) => _handleSuccessfulLogin(),
    );
  }

  /// Logs out the current user
  Future<void> logout() async {
    if (state.isLoading) return; // Prevent multiple concurrent operations

    state = const AuthState.loading();

    final result = await _logoutUseCase();

    result.fold(
      (failure) => state = AuthState.error(failure: failure),
      (_) => state = const AuthState.unauthenticated(),
    );
  }

  /// Checks the current authentication status and updates state accordingly
  Future<void> checkAuthStatus() async {
    if (state.isLoading) return;

    state = const AuthState.loading();

    final result = await _checkAuthStatusUseCase();

    await result.fold(
      (failure) async {
        state = AuthState.error(failure: failure);
      },
      (isAuthenticated) async {
        if (isAuthenticated) {
          await _loadCurrentUser();
        } else {
          state = const AuthState.unauthenticated();
        }
      },
    );
  }

  /// Refreshes the authentication token
  Future<void> refreshToken() async {
    if (state.isLoading) return;

    final result = await _refreshTokenUseCase();

    result.fold(
      (failure) => state = AuthState.error(failure: failure),
      (token) => _handleSuccessfulLogin(),
    );
  }

  /// Handles successful login by loading user information
  Future<void> _handleSuccessfulLogin() async {
    await _loadCurrentUser();
  }

  /// Loads the current user information and updates the state
  Future<void> _loadCurrentUser() async {
    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) => state = AuthState.error(failure: failure),
      (user) {
        if (user != null) {
          state = AuthState.authenticated(user: user);
        } else {
          state = const AuthState.unauthenticated();
        }
      },
    );
  }

  /// Clears any error state and returns to initial state
  void clearError() {
    if (state.hasError) {
      state = const AuthState.initial();
    }
  }

  /// Resets the authentication state to initial
  void resetState() {
    state = const AuthState.initial();
  }

  /// Convenience method to check if token should be refreshed
  Future<bool> shouldRefreshToken() async {
    final result = await _refreshTokenUseCase.shouldRefresh();
    return result.fold(
      (failure) => false,
      (shouldRefresh) => shouldRefresh,
    );
  }
}