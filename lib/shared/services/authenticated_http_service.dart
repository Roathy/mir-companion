import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'unified_auth_service.dart';
import '../../network/api_endpoints.dart';

/// HTTP service that automatically handles authentication for API calls
/// 
/// This service provides a unified way for all features to make authenticated
/// API requests without having to manage tokens manually.
class AuthenticatedHttpService {
  final Dio _dio;
  final UnifiedAuthService _authService;

  AuthenticatedHttpService({
    required Dio dio,
    required UnifiedAuthService authService,
  })  : _dio = dio,
        _authService = authService {
    _setupInterceptors();
  }

  /// Setup interceptors for automatic auth token injection
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth headers to all requests
          final headers = await _authService.getAuthHeaders();
          options.headers.addAll(headers);
          
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 errors by trying to refresh token
          if (error.response?.statusCode == 401) {
            final tokenRefreshed = await _authService.validateToken();
            
            if (tokenRefreshed) {
              // Retry the request with new token
              final retryOptions = error.requestOptions;
              final headers = await _authService.getAuthHeaders();
              retryOptions.headers.addAll(headers);
              
              try {
                final response = await _dio.fetch(retryOptions);
                handler.resolve(response);
                return;
              } catch (e) {
                // If retry fails, continue with original error
              }
            } else {
              // Token refresh failed, clear auth data
              await _authService.clearAuthData();
            }
          }
          
          handler.next(error);
        },
      ),
    );
  }

  /// GET request with automatic authentication
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final url = _buildFullUrl(path);
    
    return await _dio.get<T>(
      url,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// POST request with automatic authentication
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final url = _buildFullUrl(path);
    
    return await _dio.post<T>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// PUT request with automatic authentication
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final url = _buildFullUrl(path);
    
    return await _dio.put<T>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// DELETE request with automatic authentication
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final url = _buildFullUrl(path);
    
    return await _dio.delete<T>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Build full URL from base URL and path
  String _buildFullUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    
    return '${ApiEndpoints.baseURL}$path';
  }

  /// Check if user is authenticated before making requests
  Future<bool> isAuthenticated() async {
    return await _authService.isAuthenticated();
  }

  /// Get current user information
  Future<dynamic> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  /// Manual token refresh
  Future<bool> refreshToken() async {
    return await _authService.validateToken();
  }
}

/// Provider for authenticated HTTP service
final authenticatedHttpServiceProvider = Provider<AuthenticatedHttpService>((ref) {
  // Create Dio instance with default configuration
  final dio = Dio();
  
  // Configure Dio
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);
  dio.options.sendTimeout = const Duration(seconds: 30);
  
  // Add logging in debug mode
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (object) => print('HTTP: $object'),
  ));

  final authService = ref.read(unifiedAuthServiceProvider);
  
  return AuthenticatedHttpService(
    dio: dio,
    authService: authService,
  );
});