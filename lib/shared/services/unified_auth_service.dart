import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import '../../features/02_auth/domain/entities/user.dart';
import '../../features/02_auth/domain/entities/auth_token.dart';
import '../../features/02_auth/domain/failures/auth_failures.dart';
import '../../core/utils/crypto.dart';
import '../providers/auth_providers.dart';

/// Unified authentication service that provides a simple interface
/// for all features in the application to access authentication functionality.
/// 
/// This replaces the old AuthService and provides a clean, testable interface
/// that works with the clean architecture implementation.
class UnifiedAuthService {
  final ProviderRef _ref;

  UnifiedAuthService(this._ref);

  /// Login with email and password
  /// Returns true if successful, false otherwise
  Future<bool> login(String email, String password) async {
    try {
      final authManager = _ref.read(authManagerProvider);
      final result = await authManager.login(email, password);
      
      return result.fold(
        (failure) => false,
        (user) => true,
      );
    } catch (e) {
      return false;
    }
  }

  /// Logout current user
  /// Returns true if successful, false otherwise
  Future<bool> logout() async {
    try {
      final authManager = _ref.read(authManagerProvider);
      final result = await authManager.logout();
      
      return result.fold(
        (failure) => false,
        (_) => true,
      );
    } catch (e) {
      return false;
    }
  }

  /// Get current authentication token for API calls
  /// Returns null if no valid token is available
  Future<String?> getToken() async {
    try {
      final authManager = _ref.read(authManagerProvider);
      final token = await authManager.currentToken;
      return token?.accessToken;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    try {
      final authManager = _ref.read(authManagerProvider);
      return await authManager.isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  /// Get current user information
  /// Returns null if no user is authenticated
  Future<User?> getCurrentUser() async {
    try {
      final authManager = _ref.read(authManagerProvider);
      return await authManager.currentUser;
    } catch (e) {
      return null;
    }
  }

  /// Validate current token and refresh if needed
  Future<bool> validateToken() async {
    try {
      final authManager = _ref.read(authManagerProvider);
      return await authManager.validateCurrentToken();
    } catch (e) {
      return false;
    }
  }

  /// Clear all authentication data
  Future<void> clearAuthData() async {
    try {
      final authManager = _ref.read(authManagerProvider);
      await authManager.clearAuthData();
    } catch (e) {
      // Handle error silently for now
    }
  }

  /// Get authentication headers for API calls
  /// Returns a map with Authorization and other required headers
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Add the hash header (extracted from old auth service)
    headers['X-App-MirHorizon'] = await _createMD5Hash();

    return headers;
  }

  /// Create MD5 hash as required by the API
  Future<String> _createMD5Hash() async {
    // Import from existing crypto utility
    return _createHashFromCrypto();
  }

  /// Use existing crypto utility
  String _createHashFromCrypto() {
    // We'll import this function from the crypto utility
    return createMD5Hash();
  }
}

/// Provider for the unified auth service
final unifiedAuthServiceProvider = Provider<UnifiedAuthService>((ref) {
  return UnifiedAuthService(ref);
});

/// Convenience provider for getting auth headers
final authHeadersProvider = FutureProvider<Map<String, String>>((ref) async {
  final authService = ref.read(unifiedAuthServiceProvider);
  return await authService.getAuthHeaders();
});