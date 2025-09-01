import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../network/api_endpoints.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/use_cases/use_cases.dart';
import '../../data/datasources/datasources.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../controllers/auth_controller.dart';
import '../states/auth_state.dart';

// =============================================================================
// CORE DEPENDENCIES
// =============================================================================

/// Provider for Dio HTTP client
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  
  // Add interceptors for logging, authentication, etc.
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (object) => print(object), // Use proper logging in production
  ));
  
  // Set default timeouts
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);
  dio.options.sendTimeout = const Duration(seconds: 30);
  
  return dio;
});

/// Provider for Flutter Secure Storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
});

// =============================================================================
// DATA SOURCES
// =============================================================================

/// Provider for remote authentication data source
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    dio: ref.read(dioProvider),
    baseUrl: ApiEndpoints.baseURL, // Use the existing API endpoints
  );
});

/// Provider for local authentication data source
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(
    secureStorage: ref.read(secureStorageProvider),
  );
});

// =============================================================================
// REPOSITORY
// =============================================================================

/// Provider for authentication repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    localDataSource: ref.read(authLocalDataSourceProvider),
  );
});

// =============================================================================
// USE CASES
// =============================================================================

/// Provider for login use case
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

/// Provider for logout use case
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

/// Provider for get current user use case
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.read(authRepositoryProvider));
});

/// Provider for check auth status use case
final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
  return CheckAuthStatusUseCase(ref.read(authRepositoryProvider));
});

/// Provider for refresh token use case
final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  return RefreshTokenUseCase(ref.read(authRepositoryProvider));
});

// =============================================================================
// CONTROLLER
// =============================================================================

/// Provider for authentication controller
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    loginUseCase: ref.read(loginUseCaseProvider),
    logoutUseCase: ref.read(logoutUseCaseProvider),
    getCurrentUserUseCase: ref.read(getCurrentUserUseCaseProvider),
    checkAuthStatusUseCase: ref.read(checkAuthStatusUseCaseProvider),
    refreshTokenUseCase: ref.read(refreshTokenUseCaseProvider),
  );
});

// =============================================================================
// CONVENIENCE PROVIDERS
// =============================================================================

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState.isAuthenticated;
});

/// Provider to get current user
final currentUserProvider = Provider((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState.currentUser;
});

/// Provider to check if auth operation is in progress
final isAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState.isLoading;
});

/// Provider to get current auth error
final authErrorProvider = Provider((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState.currentError;
});

// =============================================================================
// INITIALIZATION PROVIDER
// =============================================================================

/// Provider to initialize authentication state on app startup
final authInitializationProvider = FutureProvider<void>((ref) async {
  final controller = ref.read(authControllerProvider.notifier);
  await controller.checkAuthStatus();
});