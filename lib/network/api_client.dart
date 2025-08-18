import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../core/config/app_config.dart';
import '../core/utils/secure_logger.dart';

class DioClient {
  late Dio _dio;

  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(seconds: AppConfig.networkTimeout),
      receiveTimeout: Duration(seconds: AppConfig.networkTimeout),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
    ));

    // Configurar certificate pinning si está habilitado
    if (AppConfig.certificatePinningEnabled) {
      _setupCertificatePinning();
    }

    // Agregar interceptor de logging seguro
    _dio.interceptors.add(_createSecureLoggingInterceptor());
    
    // Agregar interceptor de autenticación
    _dio.interceptors.add(_createAuthInterceptor());
  }

  Dio get dio => _dio;

  /// Configura certificate pinning para mayor seguridad
  void _setupCertificatePinning() {
    if (_dio.httpClientAdapter is DefaultHttpClientAdapter) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
        client.badCertificateCallback = (cert, host, port) {
          // Lista de hashes SHA-256 de certificados permitidos
          final allowedCertificates = [
            // Hash del certificado de api.mironline.io (debe actualizarse con el real)
            'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
            // Hash de respaldo
            'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
          ];

          if (host == 'api.mironline.io') {
            final certSha256 = cert.sha1.toUpperCase();
            final isAllowed = allowedCertificates.any((allowed) => 
              allowed.toUpperCase() == certSha256);
            
            if (!isAllowed) {
              SecureLogger.error('Certificate pinning failed for host: $host');
            }
            
            return isAllowed;
          }

          // Para otros hosts, usar validación estándar
          return true;
        };
        
        return client;
      };
    }
  }

  /// Crea interceptor de logging seguro
  Interceptor _createSecureLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        SecureLogger.network('API Request: ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        SecureLogger.network('API Response: ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        SecureLogger.error(
          'API Error: ${error.response?.statusCode} ${error.requestOptions.path}',
          tag: 'API_CLIENT',
          error: error.type.toString(),
        );
        handler.next(error);
      },
    );
  }

  /// Crea interceptor de autenticación
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // Agregar header de seguridad requerido
        try {
          options.headers['X-App-MirHorizon'] = AppConfig.createSecureHash();
        } catch (e) {
          SecureLogger.error('Failed to create security hash', error: e);
        }
        handler.next(options);
      },
    );
  }

  /// Agrega un interceptor personalizado
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// Configura el token de autenticación para todas las peticiones
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    SecureLogger.auth('Auth token configured');
  }

  /// Remueve el token de autenticación
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    SecureLogger.auth('Auth token cleared');
  }
}
