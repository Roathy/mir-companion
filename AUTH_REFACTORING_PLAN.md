# Authentication Feature - Clean Architecture Refactoring Plan

## Overview

This document outlines the comprehensive refactoring plan to transform the authentication feature (`02_auth`) from a single-file, tightly-coupled implementation into a clean architecture pattern that follows SOLID principles and proper separation of concerns.

## Current State Analysis

### Current Implementation Issues

The current authentication implementation in `lib/features/02_auth/presentation/screens/auth_screen.dart` violates several clean architecture principles:

#### 1. **Single Responsibility Principle (SRP) Violations**
- The `auth_screen.dart` file handles multiple responsibilities:
  - UI presentation logic
  - Business logic (login validation)
  - Network API calls
  - Data persistence (token storage)
  - Navigation logic
  - State management

#### 2. **Dependency Inversion Principle (DIP) Violations**
- Direct dependency on concrete implementations:
  - `Dio` HTTP client directly instantiated
  - `FlutterSecureStorage` directly used
  - Hard-coded API endpoints and request formatting

#### 3. **Open/Closed Principle (OCP) Violations**
- Tightly coupled to specific implementations
- Difficult to extend or modify without changing existing code
- No abstractions for switching authentication methods

#### 4. **Interface Segregation Principle (ISP) Violations**
- Mixed concerns in a single interface
- UI components directly accessing business logic

#### 5. **Liskov Substitution Principle (LSP) Violations**
- No proper abstractions to allow substitutable implementations

### Current Architecture Problems

```
Current Structure:
📁 02_auth/
└── 📁 presentation/
    ├── 📁 screens/
    │   └── auth_screen.dart (❌ Contains everything)
    └── 📁 widgets/
        ├── google_login_button.dart
        ├── login_button.dart
        ├── login_text_field.dart
        ├── or_divider.dart
        └── widgets.dart
```

**Problems Identified:**
1. **Monolithic Implementation**: All logic in a single 200+ line file
2. **No Domain Layer**: Business rules mixed with UI logic
3. **No Data Layer**: Direct API calls from presentation layer
4. **No Error Handling Strategy**: Basic try-catch without proper error types
5. **No Testability**: Tightly coupled code is hard to unit test
6. **No Scalability**: Adding new auth methods requires modifying existing code
7. **State Management Issues**: Mixed state management patterns

## Proposed Clean Architecture Solution

### Target Architecture

```
📁 02_auth/
├── 📁 domain/
│   ├── 📁 entities/
│   │   ├── user.dart
│   │   ├── auth_token.dart
│   │   └── login_credentials.dart
│   ├── 📁 repositories/
│   │   └── auth_repository.dart
│   ├── 📁 use_cases/
│   │   ├── login_use_case.dart
│   │   ├── logout_use_case.dart
│   │   ├── get_current_user_use_case.dart
│   │   └── refresh_token_use_case.dart
│   └── 📁 failures/
│       └── auth_failures.dart
├── 📁 data/
│   ├── 📁 repositories/
│   │   └── auth_repository_impl.dart
│   ├── 📁 datasources/
│   │   ├── auth_remote_data_source.dart
│   │   └── auth_local_data_source.dart
│   ├── 📁 models/
│   │   ├── user_model.dart
│   │   ├── auth_token_model.dart
│   │   └── login_response_model.dart
│   └── 📁 mappers/
│       └── auth_mappers.dart
└── 📁 presentation/
    ├── 📁 controllers/
    │   └── auth_controller.dart
    ├── 📁 screens/
    │   └── auth_screen.dart
    ├── 📁 widgets/
    │   ├── google_login_button.dart
    │   ├── login_button.dart
    │   ├── login_text_field.dart
    │   ├── or_divider.dart
    │   └── widgets.dart
    └── 📁 states/
        └── auth_state.dart
```

## Detailed Refactoring Plan

### Phase 1: Domain Layer Implementation

#### 1.1 Create Domain Entities

**File: `lib/features/02_auth/domain/entities/user.dart`**
```dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.lastLoginAt,
  });

  @override
  List<Object?> get props => [id, email, name, lastLoginAt];
}
```

**File: `lib/features/02_auth/domain/entities/auth_token.dart`**
```dart
import 'package:equatable/equatable.dart';

class AuthToken extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final String tokenType;

  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt, tokenType];
}
```

**File: `lib/features/02_auth/domain/entities/login_credentials.dart`**
```dart
import 'package:equatable/equatable.dart';

class LoginCredentials extends Equatable {
  final String email;
  final String password;

  const LoginCredentials({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
```

#### 1.2 Create Failure Classes

**File: `lib/features/02_auth/domain/failures/auth_failures.dart`**
```dart
import 'package:equatable/equatable.dart';

abstract class AuthFailure extends Equatable {
  final String message;
  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('Invalid email or password');
}

class NetworkFailure extends AuthFailure {
  const NetworkFailure([String? message]) 
      : super(message ?? 'Network error occurred');
}

class ServerFailure extends AuthFailure {
  const ServerFailure([String? message]) 
      : super(message ?? 'Server error occurred');
}

class TokenExpiredFailure extends AuthFailure {
  const TokenExpiredFailure() : super('Authentication token has expired');
}

class UnknownFailure extends AuthFailure {
  const UnknownFailure([String? message]) 
      : super(message ?? 'Unknown error occurred');
}
```

#### 1.3 Create Repository Interface

**File: `lib/features/02_auth/domain/repositories/auth_repository.dart`**
```dart
import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../entities/auth_token.dart';
import '../entities/login_credentials.dart';
import '../failures/auth_failures.dart';

abstract class AuthRepository {
  Future<Either<AuthFailure, AuthToken>> login(LoginCredentials credentials);
  Future<Either<AuthFailure, void>> logout();
  Future<Either<AuthFailure, AuthToken>> refreshToken();
  Future<Either<AuthFailure, User?>> getCurrentUser();
  Future<Either<AuthFailure, bool>> isLoggedIn();
  Future<Either<AuthFailure, void>> clearAuthData();
}
```

#### 1.4 Create Use Cases

**File: `lib/features/02_auth/domain/use_cases/login_use_case.dart`**
```dart
import 'package:dartz/dartz.dart';
import '../entities/auth_token.dart';
import '../entities/login_credentials.dart';
import '../failures/auth_failures.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<AuthFailure, AuthToken>> call(LoginCredentials credentials) async {
    // Validate credentials
    if (credentials.email.isEmpty || credentials.password.isEmpty) {
      return const Left(InvalidCredentialsFailure());
    }

    // Perform login
    return await repository.login(credentials);
  }
}
```

### Phase 2: Data Layer Implementation

#### 2.1 Create Data Models

**File: `lib/features/02_auth/data/models/user_model.dart`**
```dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      lastLoginAt: user.lastLoginAt,
    );
  }
}
```

#### 2.2 Create Data Sources

**File: `lib/features/02_auth/data/datasources/auth_remote_data_source.dart`**
```dart
import 'package:dio/dio.dart';
import '../models/auth_token_model.dart';
import '../models/login_response_model.dart';
import '../../domain/entities/login_credentials.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginCredentials credentials);
  Future<void> logout(String token);
  Future<AuthTokenModel> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<LoginResponseModel> login(LoginCredentials credentials) async {
    try {
      final response = await dio.post(
        '$baseUrl/login',
        data: {
          'email': credentials.email,
          'password': credentials.password,
        },
        options: Options(headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-App-MirHorizon": _createMD5Hash(),
        }),
      );

      return LoginResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Additional methods...
}
```

#### 2.3 Create Repository Implementation

**File: `lib/features/02_auth/data/repositories/auth_repository_impl.dart`**
```dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/failures/auth_failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';

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
      final response = await remoteDataSource.login(credentials);
      
      if (response.success && response.token != null) {
        final authToken = AuthToken(
          accessToken: response.token!,
          expiresAt: response.expiresAt ?? DateTime.now().add(Duration(hours: 24)),
        );
        
        // Store token locally
        await localDataSource.saveAuthToken(authToken);
        
        return Right(authToken);
      } else {
        return Left(InvalidCredentialsFailure());
      }
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  // Additional methods...
}
```

### Phase 3: Presentation Layer Refactoring

#### 3.1 Create Auth State Management

**File: `lib/features/02_auth/presentation/states/auth_state.dart`**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures/auth_failures.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(AuthFailure failure) = _Error;
}
```

#### 3.2 Create Auth Controller

**File: `lib/features/02_auth/presentation/controllers/auth_controller.dart`**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../../domain/use_cases/logout_use_case.dart';
import '../states/auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthController({
    required this.loginUseCase,
    required this.logoutUseCase,
  }) : super(const AuthState.initial());

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();

    final credentials = LoginCredentials(email: email, password: password);
    final result = await loginUseCase(credentials);

    result.fold(
      (failure) => state = AuthState.error(failure),
      (token) => _handleSuccessfulLogin(token),
    );
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    
    final result = await logoutUseCase();
    
    result.fold(
      (failure) => state = AuthState.error(failure),
      (_) => state = const AuthState.unauthenticated(),
    );
  }

  // Additional methods...
}
```

#### 3.3 Refactor Auth Screen

**File: `lib/features/02_auth/presentation/screens/auth_screen.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';
import '../states/auth_state.dart';
import '../widgets/widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        authenticated: (user) => _navigateToHome(),
        unauthenticated: () {},
        error: (failure) => _showError(failure.message),
      );
    });

    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, top: 150, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'mironline-logo',
              child: Image.asset('assets/logo.png', width: 240),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              color: Colors.white,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  spacing: 12,
                  children: [
                    Text(
                      "Student Login",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        color: Colors.blue[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const GoogleLoginButton(),
                    const OrDivider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mail_outline, color: Colors.blue[900]),
                        const SizedBox(width: 6),
                        Text(
                          "Login with e-mail",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.blue[900],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      color: Colors.grey.shade100,
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        child: Column(
                          spacing: 12,
                          children: [
                            LoginTextField(
                              controller: _emailController,
                              label: "Your e-mail:",
                              obscureText: false,
                            ),
                            LoginTextField(
                              controller: _passwordController,
                              label: "Your password:",
                              obscureText: true,
                            ),
                            authState.when(
                              initial: () => LoginButton(handleLogin: _handleLogin),
                              loading: () => const CircularProgressIndicator(),
                              authenticated: (_) => const Icon(Icons.check_circle),
                              unauthenticated: () => LoginButton(handleLogin: _handleLogin),
                              error: (_) => LoginButton(handleLogin: _handleLogin),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() {
    ref.read(authControllerProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
```

### Phase 4: Dependency Injection Setup

**File: `lib/features/02_auth/presentation/providers/auth_providers.dart`**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Core dependencies
final dioProvider = Provider<Dio>((ref) => Dio());
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

// Data sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    dio: ref.read(dioProvider),
    baseUrl: ApiEndpoints.baseURL,
  );
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(
    secureStorage: ref.read(secureStorageProvider),
  );
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    localDataSource: ref.read(authLocalDataSourceProvider),
  );
});

// Use cases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

// Controller
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    loginUseCase: ref.read(loginUseCaseProvider),
    logoutUseCase: ref.read(logoutUseCaseProvider),
  );
});
```

## Benefits of the Refactored Architecture

### 1. **Separation of Concerns**
- **Domain Layer**: Contains business rules and entities
- **Data Layer**: Handles data persistence and API communication
- **Presentation Layer**: Manages UI state and user interactions

### 2. **Testability**
- Each layer can be tested independently
- Mock implementations can be easily substituted
- Business logic is isolated from UI and external dependencies

### 3. **Maintainability**
- Changes to one layer don't affect others
- Code is organized in logical, cohesive modules
- Easy to locate and modify specific functionality

### 4. **Scalability**
- Easy to add new authentication methods
- Simple to extend with additional features
- Clean interfaces allow for multiple implementations

### 5. **Dependency Inversion**
- High-level modules don't depend on low-level modules
- Both depend on abstractions (interfaces)
- Easy to swap implementations

### 6. **Error Handling**
- Centralized error handling strategy
- Type-safe error propagation using `Either`
- Clear error boundaries between layers

### 7. **State Management**
- Predictable state transitions
- Immutable state objects
- Clear separation of UI state and business state

## Implementation Timeline

| Phase | Duration | Description |
|-------|----------|-------------|
| Phase 1: Domain Layer | 2-3 days | Create entities, repositories, use cases, and failures |
| Phase 2: Data Layer | 3-4 days | Implement data sources, models, and repository implementations |
| Phase 3: Presentation Layer | 2-3 days | Refactor UI components and state management |
| Phase 4: Integration & Testing | 2-3 days | Set up dependency injection and comprehensive testing |
| Phase 5: Documentation & Review | 1-2 days | Complete documentation and code review |

**Total Estimated Time: 10-15 days**

## File Structure Changes Summary

### Before Refactoring
```
lib/features/02_auth/
└── presentation/
    ├── screens/
    │   └── auth_screen.dart (200+ lines, mixed concerns)
    └── widgets/
        └── [5 widget files]
```

### After Refactoring
```
lib/features/02_auth/
├── domain/ (NEW)
│   ├── entities/ (3 files)
│   ├── repositories/ (1 interface)
│   ├── use_cases/ (4 files)
│   └── failures/ (1 file)
├── data/ (NEW)
│   ├── repositories/ (1 implementation)
│   ├── datasources/ (2 files)
│   ├── models/ (3 files)
│   └── mappers/ (1 file)
└── presentation/ (REFACTORED)
    ├── controllers/ (1 file)
    ├── screens/ (1 refactored file)
    ├── widgets/ (5 existing files)
    ├── states/ (1 file)
    └── providers/ (1 file)
```

## Testing Strategy

### Unit Tests
- **Domain Layer**: Test entities, use cases, and business logic
- **Data Layer**: Test repository implementations and data sources
- **Presentation Layer**: Test controllers and state management

### Integration Tests
- Test complete authentication flow
- Test error scenarios and edge cases
- Test state transitions and UI updates

### Widget Tests
- Test UI components in isolation
- Test user interactions and form validation
- Test loading states and error displays

## Migration Strategy

### 1. **Incremental Migration**
- Implement new architecture alongside existing code
- Gradually replace components one by one
- Maintain backward compatibility during transition

### 2. **Feature Flags**
- Use feature flags to switch between old and new implementations
- Test new implementation thoroughly before full migration
- Easy rollback if issues are discovered

### 3. **Parallel Development**
- Keep existing implementation functional
- Develop new architecture in parallel
- Switch over when new implementation is complete and tested

## Conclusion

This refactoring plan transforms the authentication feature from a monolithic, tightly-coupled implementation into a clean, maintainable, and testable architecture. The new structure follows SOLID principles, provides clear separation of concerns, and enables future scalability and maintainability.

The investment in this refactoring will pay dividends in:
- **Reduced development time** for new features
- **Improved code quality** and maintainability
- **Better testing capabilities** and coverage
- **Enhanced team productivity** and collaboration
- **Easier onboarding** for new team members

---

## Implementation Status

### ✅ COMPLETED
- **Domain Layer**: All entities, use cases, repository interfaces, and failures implemented
- **Data Layer**: Remote/local data sources, repository implementation, and models with JSON serialization
- **Presentation Layer**: State management, controllers, providers, and refactored UI components
- **Documentation**: Comprehensive refactoring plan and migration guide

### 🔄 READY FOR INTEGRATION
- New clean architecture implementation is complete and ready for testing
- Migration guide provided for switching from old to new implementation
- All layers follow clean architecture principles and SOLID design patterns

### 📋 NEXT STEPS
1. **Testing**: Create comprehensive unit, widget, and integration tests
2. **Migration**: Follow migration guide to switch to new implementation  
3. **Validation**: Test complete authentication flow with new architecture
4. **Cleanup**: Remove old implementation once new version is validated

---

**Branch**: `refactor/auth-clean-architecture`  
**Author**: Claude AI Assistant  
**Date**: September 1, 2025  
**Status**: ✅ IMPLEMENTATION COMPLETE - Ready for Testing & Migration