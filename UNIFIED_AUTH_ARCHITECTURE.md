# Unified Authentication Architecture

## Overview

This document outlines the unified authentication architecture that extracts and generalizes the authentication functionality from the `02_auth` feature to be used across the entire project. This solves the fragmentation issues where different features were using inconsistent authentication services.

## Problem Analysis

### Before Unification

The project had several authentication-related issues:

1. **Multiple Auth Implementations**:
   - `lib/services/auth_service.dart` - Legacy service using HTTP client
   - `lib/features/02_auth/` - New clean architecture implementation
   - Direct `FlutterSecureStorage` usage in various components

2. **Inconsistent API Access**:
   - Different features using different HTTP clients (http vs Dio)
   - Inconsistent header management
   - Duplicated token handling logic

3. **Service Fragmentation**:
   - `today_app_bar.dart` using old `AuthService().logoutUser()`
   - Splash screen directly accessing secure storage
   - Each feature implementing its own API call patterns

## Solution Architecture

### Core Components

```
lib/
├── core/
│   └── auth/
│       ├── auth_manager.dart          # Global auth interface
│       └── auth_manager_impl.dart     # Implementation bridge
├── shared/
│   ├── providers/
│   │   └── auth_providers.dart        # Global auth providers
│   └── services/
│       ├── unified_auth_service.dart   # Simple auth interface
│       └── authenticated_http_service.dart # HTTP service with auth
└── features/
    └── 02_auth/                       # Clean architecture auth
        ├── domain/                    # Business logic
        ├── data/                      # Data layer
        └── presentation/              # UI layer
```

## Architecture Layers

### 1. Core Authentication Layer

#### `AuthManager` Interface
```dart
abstract class AuthManager {
  Future<bool> get isAuthenticated;
  Future<User?> get currentUser;
  Future<AuthToken?> get currentToken;
  
  Future<Either<AuthFailure, User>> login(String email, String password);
  Future<Either<AuthFailure, void>> logout();
  Future<Either<AuthFailure, AuthToken>> refreshToken();
  
  Stream<AuthenticationState> get authStateStream;
}
```

**Purpose**: Global authentication interface for the entire application.

**Benefits**:
- Single source of truth for authentication state
- Type-safe operations with `Either` error handling
- Stream-based state updates for reactive UI
- Clean abstraction from implementation details

#### `AuthManagerImpl` Implementation
```dart
class AuthManagerImpl implements AuthManager {
  // Bridges clean architecture auth feature with global interface
  // Delegates to use cases from 02_auth feature
  // Provides stream of authentication state changes
}
```

**Purpose**: Bridges the clean architecture auth feature with the global interface.

### 2. Shared Services Layer

#### `UnifiedAuthService`
```dart
class UnifiedAuthService {
  Future<bool> login(String email, String password);
  Future<bool> logout();
  Future<String?> getToken();
  Future<bool> isAuthenticated();
  Future<User?> getCurrentUser();
  Future<Map<String, String>> getAuthHeaders();
}
```

**Purpose**: Simplified authentication service for features that need basic auth operations.

**Benefits**:
- Simple boolean return values for ease of use
- Automatic header generation for API calls
- Token management abstraction
- Error handling built-in

#### `AuthenticatedHttpService`
```dart
class AuthenticatedHttpService {
  Future<Response<T>> get<T>(String path);
  Future<Response<T>> post<T>(String path, {dynamic data});
  Future<Response<T>> put<T>(String path, {dynamic data});
  Future<Response<T>> delete<T>(String path);
}
```

**Purpose**: HTTP service that automatically handles authentication.

**Features**:
- Automatic auth token injection
- 401 error handling with token refresh
- Automatic logout on authentication failures
- Consistent API base URL handling

### 3. Feature Integration Layer

#### Global Providers
```dart
// Unified auth providers for entire app
final authManagerProvider = Provider<AuthManager>(...);
final unifiedAuthServiceProvider = Provider<UnifiedAuthService>(...);
final authenticatedHttpServiceProvider = Provider<AuthenticatedHttpService>(...);

// Convenience providers
final globalIsAuthenticatedProvider = FutureProvider<bool>(...);
final globalCurrentUserProvider = FutureProvider<User?>(...);
final authStateStreamProvider = StreamProvider<AuthStateChangeEvent>(...);
```

**Purpose**: Global dependency injection for authentication services.

## Migration Examples

### 1. App Bar Logout (Before vs After)

#### Before (today_app_bar.dart)
```dart
import '../../../../services/auth_service.dart';

// In PopupMenuButton onSelected:
try {
  await AuthService().logoutUser();
  // Navigate to login
} catch (e) {
  // Handle error
}
```

#### After (today_app_bar_refactored.dart)
```dart
import '../../../../shared/services/unified_auth_service.dart';

// In Consumer widget:
Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
  final authService = ref.read(unifiedAuthServiceProvider);
  final success = await authService.logout();
  
  if (success) {
    // Navigate to login
  } else {
    // Show error
  }
}
```

**Benefits**:
- Consistent error handling
- Type-safe operations
- Proper state management integration
- Better testing capabilities

### 2. Splash Screen Auth Check (Before vs After)

#### Before (animated_splash_screen.dart)
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<String?> getLastSession() async {
  final String? authToken = await FlutterSecureStorage().read(key: 'auth_token');
  return authToken;
}
```

#### After (animated_splash_screen_refactored.dart)
```dart
import '../../shared/services/unified_auth_service.dart';

Future<void> _checkAuthenticationAndNavigate() async {
  final authService = ref.read(unifiedAuthServiceProvider);
  final isAuthenticated = await authService.isAuthenticated();
  final isTokenValid = await authService.validateToken();
  
  if (isAuthenticated && isTokenValid) {
    _navigateToHome();
  } else {
    _navigateToLogin();
  }
}
```

**Benefits**:
- Proper token validation
- No direct storage access
- Consistent authentication logic
- Better error handling

### 3. API Calls in Features (Before vs After)

#### Before (today_screen.dart)
```dart
final studentTodayProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final dio = ref.read(dioProvider);
  final authToken = ref.read(authTokenProvider);
  
  Response response = await dio.get(
    "${ApiEndpoints.baseURL}${ApiEndpoints.studentsProfile}",
    options: Options(headers: {
      "X-Requested-With": "XMLHttpRequest",
      "X-App-MirHorizon": createMD5Hash(),
      "Authorization": "Bearer $authToken",
    }),
  );
  
  return response.data['data'];
});
```

#### After (today_providers_refactored.dart)
```dart
final studentTodayRefactoredProvider = FutureProvider.autoDispose<StudentTodayModel?>((ref) async {
  final httpService = ref.read(authenticatedHttpServiceProvider);
  
  final response = await httpService.get(ApiEndpoints.studentsProfile);
  
  if (response.statusCode == 200 && response.data != null) {
    return StudentTodayModel.fromJson(response.data['data']);
  }
  
  return null;
});
```

**Benefits**:
- Automatic authentication handling
- No manual header management
- Automatic token refresh on 401 errors
- Type-safe response models
- Consistent error handling

## Implementation Benefits

### 1. **Consistency**
- All features use the same authentication mechanism
- Consistent API call patterns
- Uniform error handling

### 2. **Maintainability**
- Single source of truth for authentication logic
- Easy to modify authentication behavior globally
- Centralized token management

### 3. **Testability**
- Clean dependency injection
- Mockable services
- Isolated testing of authentication logic

### 4. **Scalability**
- Easy to add new authentication methods
- Simple to extend functionality
- Clean separation of concerns

### 5. **Developer Experience**
- Simple API for common operations
- Automatic error handling
- Type-safe operations

## Integration Guide

### For Existing Features

1. **Replace old auth service imports**:
```dart
// OLD
import '../../../../services/auth_service.dart';

// NEW
import '../../../../shared/services/unified_auth_service.dart';
```

2. **Update providers to use authenticated HTTP service**:
```dart
// OLD
final dio = ref.read(dioProvider);
final authToken = ref.read(authTokenProvider);

// NEW
final httpService = ref.read(authenticatedHttpServiceProvider);
```

3. **Use unified auth methods**:
```dart
// OLD
await AuthService().logoutUser();

// NEW
final authService = ref.read(unifiedAuthServiceProvider);
await authService.logout();
```

### For New Features

1. **Use authenticated HTTP service for API calls**:
```dart
final myDataProvider = FutureProvider((ref) async {
  final httpService = ref.read(authenticatedHttpServiceProvider);
  final response = await httpService.get('/my-endpoint');
  return MyModel.fromJson(response.data);
});
```

2. **Check authentication status**:
```dart
final authService = ref.read(unifiedAuthServiceProvider);
final isAuthenticated = await authService.isAuthenticated();
```

3. **Listen to authentication state changes**:
```dart
ref.listen(authStateStreamProvider, (previous, next) {
  // Handle auth state changes
});
```

## Migration Checklist

### Phase 1: Core Infrastructure ✅
- [x] Create `AuthManager` interface
- [x] Implement `AuthManagerImpl`
- [x] Create `UnifiedAuthService`
- [x] Create `AuthenticatedHttpService`
- [x] Set up global providers

### Phase 2: Feature Migration
- [ ] Update all features to use unified services
- [ ] Replace old `AuthService` usage
- [ ] Update API call patterns
- [ ] Test authentication flows

### Phase 3: Cleanup
- [ ] Remove old `auth_service.dart`
- [ ] Update documentation
- [ ] Add comprehensive tests
- [ ] Performance optimization

## Testing Strategy

### Unit Tests
```dart
// Test auth manager
test('should return true when user is authenticated', () async {
  when(mockRepository.isLoggedIn()).thenAnswer((_) async => Right(true));
  
  final result = await authManager.isAuthenticated;
  
  expect(result, true);
});

// Test unified service
test('should logout successfully', () async {
  when(mockAuthManager.logout()).thenAnswer((_) async => Right(null));
  
  final result = await unifiedAuthService.logout();
  
  expect(result, true);
});
```

### Integration Tests
```dart
// Test authenticated HTTP service
test('should add auth headers to requests', () async {
  final response = await authenticatedHttpService.get('/test');
  
  verify(mockDio.get(any, options: argThat(
    hasAuthHeaders(), 
    named: 'options',
  )));
});
```

### Widget Tests
```dart
// Test app bar logout
testWidgets('should logout when logout button is pressed', (tester) async {
  await tester.pumpWidget(createTestWidget());
  
  await tester.tap(find.text('Logout'));
  await tester.pumpAndSettle();
  
  verify(mockAuthService.logout()).called(1);
});
```

## Performance Considerations

### 1. **Lazy Loading**
- Providers are initialized only when needed
- Services are created on-demand

### 2. **Caching**
- Authentication state is cached
- Token validation is optimized
- HTTP responses can be cached

### 3. **Memory Management**
- Proper disposal of streams and controllers
- Weak references where appropriate
- Resource cleanup on logout

## Security Considerations

### 1. **Token Management**
- Secure storage for authentication tokens
- Automatic token refresh
- Proper token expiration handling

### 2. **API Security**
- Consistent header injection
- Proper error handling for security failures
- Automatic logout on security violations

### 3. **State Management**
- Secure state transitions
- Proper cleanup on authentication changes
- No sensitive data in logs

## Conclusion

The unified authentication architecture provides:

✅ **Consistency**: All features use the same authentication patterns  
✅ **Maintainability**: Centralized authentication logic  
✅ **Testability**: Clean, mockable interfaces  
✅ **Security**: Proper token management and security practices  
✅ **Developer Experience**: Simple APIs for common operations  
✅ **Scalability**: Easy to extend and modify  

This architecture establishes a solid foundation for authentication across the entire application while maintaining the benefits of clean architecture in the core auth feature.

---

**Branch**: `feature/unified-auth-services`  
**Based on**: `feature/auth-clean-architecture-refactor`  
**Status**: Implementation Complete - Ready for Integration Testing