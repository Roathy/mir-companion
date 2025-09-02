import 'package:flutter_riverpod/flutter_riverpod.dart';

// Re-export the auth providers from the feature module
export '../../features/02_auth/presentation/providers/auth_providers.dart';

// Import all necessary providers
import '../../features/02_auth/presentation/providers/auth_providers.dart' as auth_providers;
import '../../features/02_auth/domain/use_cases/use_cases.dart';
import '../../core/auth/auth_manager.dart';
import '../../core/auth/auth_manager_impl.dart';

/// Global authentication manager provider
/// 
/// This provider gives access to the unified authentication manager
/// that can be used throughout the entire application.
final authManagerProvider = Provider<AuthManager>((ref) {
  return AuthManagerImpl(
    loginUseCase: ref.read(auth_providers.loginUseCaseProvider),
    logoutUseCase: ref.read(auth_providers.logoutUseCaseProvider),
    getCurrentUserUseCase: ref.read(auth_providers.getCurrentUserUseCaseProvider),
    checkAuthStatusUseCase: ref.read(auth_providers.checkAuthStatusUseCaseProvider),
    refreshTokenUseCase: ref.read(auth_providers.refreshTokenUseCaseProvider),
    ref: ref,
  );
});

/// Convenience providers for common authentication operations

/// Provider to check if user is authenticated
final globalIsAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final authManager = ref.read(authManagerProvider);
  return await authManager.isAuthenticated;
});

/// Provider to get current authenticated user
final globalCurrentUserProvider = FutureProvider((ref) async {
  final authManager = ref.read(authManagerProvider);
  return await authManager.currentUser;
});

/// Provider for auth state stream
final authStateStreamProvider = StreamProvider<AuthStateChangeEvent>((ref) {
  final authManager = ref.read(authManagerProvider);
  return authManager.authStateStream;
});

/// Provider for auth token access
final globalAuthTokenProvider = FutureProvider((ref) async {
  final authManager = ref.read(authManagerProvider);
  return await authManager.currentToken;
});

/// Simple logout function provider
final logoutProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final authManager = ref.read(authManagerProvider);
    await authManager.logout();
  };
});