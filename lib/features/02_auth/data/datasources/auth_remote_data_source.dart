import 'package:dio/dio.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';
import '../models/auth_token_model.dart';
import '../../domain/entities/login_credentials.dart';
import '../../../../core/utils/crypto.dart';

/// Exception thrown when a remote data source operation fails
class RemoteDataSourceException implements Exception {
  final String message;
  final int? statusCode;

  const RemoteDataSourceException(this.message, {this.statusCode});

  @override
  String toString() => 'RemoteDataSourceException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Abstract interface for remote authentication data operations
abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginCredentials credentials);
  Future<void> logout(String token);
  Future<AuthTokenModel> refreshToken(String refreshToken);
  Future<UserModel> getUserProfile(String token);
}

/// Implementation of [AuthRemoteDataSource] using Dio HTTP client
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
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
            'X-App-MirHorizon': createMD5Hash(),
          },
        ),
      );

      return LoginResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw RemoteDataSourceException('Unexpected error during login: ${e.toString()}');
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      await dio.post(
        '$baseUrl/logout',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'X-Requested-With': 'XMLHttpRequest',
            'X-App-MirHorizon': createMD5Hash(),
          },
        ),
      );
    } on DioException catch (e) {
      // For logout, we might want to continue even if the request fails
      // since the local token should still be cleared
      if (e.response?.statusCode != 401) {
        throw _handleDioException(e);
      }
    } catch (e) {
      throw RemoteDataSourceException('Unexpected error during logout: ${e.toString()}');
    }
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '$baseUrl/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
            'X-App-MirHorizon': createMD5Hash(),
          },
        ),
      );

      return AuthTokenModel.fromApiResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw RemoteDataSourceException('Unexpected error during token refresh: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getUserProfile(String token) async {
    try {
      final response = await dio.get(
        '$baseUrl/profile',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'X-Requested-With': 'XMLHttpRequest',
            'X-App-MirHorizon': createMD5Hash(),
          },
        ),
      );

      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw RemoteDataSourceException('Unexpected error getting user profile: ${e.toString()}');
    }
  }

  /// Handles Dio exceptions and converts them to [RemoteDataSourceException]
  RemoteDataSourceException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const RemoteDataSourceException('Connection timeout. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = _extractErrorMessage(e.response?.data) ?? 'Server error occurred';
        return RemoteDataSourceException(message, statusCode: statusCode);

      case DioExceptionType.cancel:
        return const RemoteDataSourceException('Request was cancelled');

      case DioExceptionType.connectionError:
        return const RemoteDataSourceException('No internet connection. Please check your network settings.');

      case DioExceptionType.badCertificate:
        return const RemoteDataSourceException('Security certificate error. Please try again.');

      case DioExceptionType.unknown:
      default:
        return RemoteDataSourceException('Network error: ${e.message ?? 'Unknown error occurred'}');
    }
  }

  /// Extracts error message from API response
  String? _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return null;

    try {
      if (responseData is Map<String, dynamic>) {
        // Try different common error message fields
        return responseData['message'] as String? ??
               responseData['error']?['message'] as String? ??
               responseData['errors']?.toString();
      }
      
      return responseData.toString();
    } catch (e) {
      return null;
    }
  }
}