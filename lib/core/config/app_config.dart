import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';

/// Configuración segura de la aplicación
/// Maneja variables de entorno y configuraciones sensibles de forma segura
class AppConfig {
  static bool _initialized = false;
  
  /// Inicializa la configuración de la aplicación
  static Future<void> initialize({bool isDevelopment = false}) async {
    try {
      if (isDevelopment) {
        await dotenv.load(fileName: ".env.development");
      } else {
        await dotenv.load(fileName: ".env");
      }
      _initialized = true;
    } catch (e) {
      // Fallback a valores por defecto si no se puede cargar el archivo
      _initialized = false;
      throw Exception('Failed to load environment configuration: $e');
    }
  }
  
  /// Verifica si la configuración está inicializada
  static bool get isInitialized => _initialized;
  
  // =============== API CONFIGURATION ===============
  
  /// Secret para el header X-App-MirHorizon
  /// CRÍTICO: Este valor debe ser único por aplicación en producción
  static String get apiSecret {
    if (!_initialized) {
      throw Exception('AppConfig not initialized. Call AppConfig.initialize() first.');
    }
    
    final secret = dotenv.env['API_SECRET'];
    if (secret == null || secret.isEmpty) {
      throw Exception('API_SECRET not found in environment configuration');
    }
    
    // Validar que no sea el valor temporal de desarrollo en producción
    if (!isDebugMode && (secret.contains('dev_') || secret.contains('temp'))) {
      throw Exception('Development secret detected in production environment');
    }
    
    return secret;
  }
  
  /// URL base de la API
  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'https://api.mironline.io/api/v1';
  }
  
  /// Endpoint para login de estudiantes
  static String get studentsLoginEndpoint {
    return dotenv.env['API_STUDENTS_LOGIN'] ?? '/students/login';
  }
  
  /// Endpoint para perfil de estudiantes
  static String get studentsProfileEndpoint {
    return dotenv.env['API_STUDENTS_PROFILE'] ?? '/students/today';
  }
  
  /// Endpoint para EGP de estudiantes
  static String get studentsEgpEndpoint {
    return dotenv.env['API_STUDENTS_EGP'] ?? '/students/egp';
  }
  
  /// Endpoint para intento extra de estudiantes
  static String get studentsExtraAttemptEndpoint {
    return dotenv.env['API_STUDENTS_EXTRA_ATTEMPT'] ?? '/students/extra-attempt';
  }
  
  /// Endpoint para logout de estudiantes
  static String get studentsLogoutEndpoint {
    return dotenv.env['API_STUDENTS_LOGOUT'] ?? '/students/logout';
  }
  
  // =============== NETWORK CONFIGURATION ===============
  
  /// Timeout para conexiones de red (en segundos)
  static int get networkTimeout {
    final timeout = dotenv.env['NETWORK_TIMEOUT'];
    return int.tryParse(timeout ?? '10') ?? 10;
  }
  
  /// Si el certificate pinning está habilitado
  static bool get certificatePinningEnabled {
    return dotenv.env['CERTIFICATE_PINNING_ENABLED']?.toLowerCase() == 'true';
  }
  
  // =============== DEBUG CONFIGURATION ===============
  
  /// Si el logging de debug está habilitado
  static bool get isDebugMode {
    return dotenv.env['DEBUG_LOGGING_ENABLED']?.toLowerCase() == 'true';
  }
  
  // =============== SECURITY HELPERS ===============
  
  /// Genera un hash MD5 seguro con el secret de la aplicación
  /// Este método reemplaza la función createMD5Hash() anterior
  static String createSecureHash() {
    final now = DateTime.now();
    final formattedDate = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    
    // Usar el secret de configuración en lugar de hardcoded
    final hashInput = '${apiSecret}-$formattedDate';
    
    return md5.convert(utf8.encode(hashInput)).toString();
  }
  
  /// Valida que toda la configuración crítica esté presente
  static void validateConfiguration() {
    if (!_initialized) {
      throw Exception('Configuration not initialized');
    }
    
    // Validar configuraciones críticas
    final criticalConfigs = [
      'API_SECRET',
      'API_BASE_URL',
    ];
    
    for (final config in criticalConfigs) {
      final value = dotenv.env[config];
      if (value == null || value.isEmpty) {
        throw Exception('Critical configuration missing: $config');
      }
    }
  }
}