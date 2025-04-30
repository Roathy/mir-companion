import 'package:mironline/core/infra/storage/secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<String?> getStoredAuthToken();
  Future<void> saveAuthToken(String token);
  Future<void> clearAuthToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService secureStorageService;
  final String _tokenKey = 'auth_token';

  AuthLocalDataSourceImpl(this.secureStorageService);

  @override
  Future<String?> getStoredAuthToken() async {
    try {
      return await secureStorageService.read(_tokenKey);
    } catch (e) {
      // Handle any errors that may occur during read operation
      return null;
    }
  }

  @override
  Future<void> saveAuthToken(String token) async {
    try {
      await secureStorageService.write(_tokenKey, token);
    } catch (e) {
      // Handle any errors that may occur during write operation
    }
  }

  @override
  Future<void> clearAuthToken() async {
    try {
      await secureStorageService.delete(_tokenKey);
    } catch (e) {
      // Handle any errors that may occur during delete operation
    }
  }
}
