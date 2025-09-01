import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

/// Exception thrown when a local data source operation fails
class LocalDataSourceException implements Exception {
  final String message;

  const LocalDataSourceException(this.message);

  @override
  String toString() => 'LocalDataSourceException: $message';
}

/// Abstract interface for local authentication data operations
abstract class AuthLocalDataSource {
  Future<void> saveAuthToken(AuthTokenModel token);
  Future<AuthTokenModel?> getAuthToken();
  Future<void> deleteAuthToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> deleteUser();
  Future<void> clearAllAuthData();
  Future<bool> hasValidToken();
}

/// Implementation of [AuthLocalDataSource] using Flutter Secure Storage
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  AuthLocalDataSourceImpl({
    required this.secureStorage,
  });

  @override
  Future<void> saveAuthToken(AuthTokenModel token) async {
    try {
      final tokenJson = json.encode(token.toJson());
      await secureStorage.write(key: _tokenKey, value: tokenJson);
    } catch (e) {
      throw LocalDataSourceException('Failed to save auth token: ${e.toString()}');
    }
  }

  @override
  Future<AuthTokenModel?> getAuthToken() async {
    try {
      final tokenJson = await secureStorage.read(key: _tokenKey);
      
      if (tokenJson == null || tokenJson.isEmpty) {
        return null;
      }

      final tokenMap = json.decode(tokenJson) as Map<String, dynamic>;
      return AuthTokenModel.fromJson(tokenMap);
    } catch (e) {
      // If we can't parse the stored token, delete it to prevent future errors
      await deleteAuthToken();
      throw LocalDataSourceException('Failed to retrieve auth token: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAuthToken() async {
    try {
      await secureStorage.delete(key: _tokenKey);
    } catch (e) {
      throw LocalDataSourceException('Failed to delete auth token: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await secureStorage.write(key: _userKey, value: userJson);
    } catch (e) {
      throw LocalDataSourceException('Failed to save user data: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userJson = await secureStorage.read(key: _userKey);
      
      if (userJson == null || userJson.isEmpty) {
        return null;
      }

      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      // If we can't parse the stored user, delete it to prevent future errors
      await deleteUser();
      throw LocalDataSourceException('Failed to retrieve user data: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      await secureStorage.delete(key: _userKey);
    } catch (e) {
      throw LocalDataSourceException('Failed to delete user data: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAllAuthData() async {
    try {
      await Future.wait([
        deleteAuthToken(),
        deleteUser(),
      ]);
    } catch (e) {
      throw LocalDataSourceException('Failed to clear auth data: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasValidToken() async {
    try {
      final token = await getAuthToken();
      return token != null && token.isValid;
    } catch (e) {
      // If there's an error reading the token, consider it invalid
      return false;
    }
  }

  /// Additional utility method to check if any auth data exists
  Future<bool> hasAnyAuthData() async {
    try {
      final tokenExists = await secureStorage.containsKey(key: _tokenKey);
      final userExists = await secureStorage.containsKey(key: _userKey);
      return tokenExists || userExists;
    } catch (e) {
      return false;
    }
  }

  /// Additional utility method to get all stored keys (for debugging)
  Future<Map<String, String>> getAllStoredData() async {
    try {
      return await secureStorage.readAll();
    } catch (e) {
      throw LocalDataSourceException('Failed to read all stored data: ${e.toString()}');
    }
  }
}