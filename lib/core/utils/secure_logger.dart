import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Logger seguro que previene la exposición de datos sensibles
/// Reemplaza todos los debugPrint() y print() inseguros
class SecureLogger {
  static const String _sensitiveDataMask = '***HIDDEN***';
  
  /// Patrones de datos sensibles que deben ser ocultados
  static final List<RegExp> _sensitivePatterns = [
    RegExp(r'token["\s]*[:=]["\s]*([^""\s,}]+)', caseSensitive: false),
    RegExp(r'password["\s]*[:=]["\s]*([^""\s,}]+)', caseSensitive: false),
    RegExp(r'secret["\s]*[:=]["\s]*([^""\s,}]+)', caseSensitive: false),
    RegExp(r'authorization["\s]*[:=]["\s]*([^""\s,}]+)', caseSensitive: false),
    RegExp(r'bearer\s+([a-zA-Z0-9\-._~+/]+)', caseSensitive: false),
    RegExp(r'email["\s]*[:=]["\s]*([^""\s,}]+)', caseSensitive: false),
    RegExp(r'api[-_]?key["\s]*[:=]["\s]*([^""\s,}]+)', caseSensitive: false),
  ];
  
  /// Log de información general (solo en modo debug)
  static void info(String message, {String? tag}) {
    if (kDebugMode && AppConfig.isDebugMode) {
      final sanitizedMessage = _sanitizeMessage(message);
      developer.log(sanitizedMessage, name: tag ?? 'MirOnline');
    }
  }
  
  /// Log de errores (siempre se registra, pero sanitizado)
  static void error(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    final sanitizedMessage = _sanitizeMessage(message);
    final sanitizedError = error != null ? _sanitizeMessage(error.toString()) : null;
    
    if (kDebugMode) {
      developer.log(
        sanitizedMessage,
        name: tag ?? 'MirOnline-ERROR',
        error: sanitizedError,
        stackTrace: stackTrace,
        level: 1000, // Error level
      );
    }
    
    // En producción, solo log crítico (sin datos sensibles)
    if (kReleaseMode) {
      developer.log(
        'Error occurred: ${tag ?? 'Unknown'}',
        name: 'MirOnline-PROD-ERROR',
        level: 1000,
      );
    }
  }
  
  /// Log de advertencias
  static void warning(String message, {String? tag}) {
    if (kDebugMode && AppConfig.isDebugMode) {
      final sanitizedMessage = _sanitizeMessage(message);
      developer.log(
        sanitizedMessage,
        name: tag ?? 'MirOnline-WARNING',
        level: 900, // Warning level
      );
    }
  }
  
  /// Log de eventos de red (solo en debug)
  static void network(String message, {String? tag}) {
    if (kDebugMode && AppConfig.isDebugMode) {
      final sanitizedMessage = _sanitizeMessage(message);
      developer.log(sanitizedMessage, name: tag ?? 'MirOnline-NETWORK');
    }
  }
  
  /// Log de autenticación (extra cuidado con datos sensibles)
  static void auth(String message, {String? tag}) {
    if (kDebugMode && AppConfig.isDebugMode) {
      final sanitizedMessage = _sanitizeAuthMessage(message);
      developer.log(sanitizedMessage, name: tag ?? 'MirOnline-AUTH');
    }
  }
  
  /// Sanitiza un mensaje removiendo datos sensibles
  static String _sanitizeMessage(String message) {
    String sanitized = message;
    
    for (final pattern in _sensitivePatterns) {
      sanitized = sanitized.replaceAllMapped(pattern, (match) {
        final key = match.group(0)?.split(RegExp(r'[:=]'))[0] ?? 'sensitive_data';
        return '$key: $_sensitiveDataMask';
      });
    }
    
    return sanitized;
  }
  
  /// Sanitización extra para mensajes de autenticación
  static String _sanitizeAuthMessage(String message) {
    String sanitized = _sanitizeMessage(message);
    
    // Patrones adicionales para autenticación
    final authPatterns = [
      RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/]+=*', caseSensitive: false),
      RegExp(r'[A-Za-z0-9]{32,}'), // Posibles tokens largos
    ];
    
    for (final pattern in authPatterns) {
      sanitized = sanitized.replaceAll(pattern, _sensitiveDataMask);
    }
    
    return sanitized;
  }
  
  /// Método de conveniencia para reemplazar debugPrint
  static void debug(String message) {
    info(message, tag: 'DEBUG');
  }
  
  /// Log de inicio de sesión exitoso (sin datos sensibles)
  static void loginSuccess(String userIdentifier) {
    final maskedIdentifier = _maskUserIdentifier(userIdentifier);
    info('Login successful for user: $maskedIdentifier', tag: 'AUTH');
  }
  
  /// Log de cierre de sesión
  static void logoutSuccess() {
    info('User logged out successfully', tag: 'AUTH');
  }
  
  /// Enmascara identificadores de usuario (email, ID, etc.)
  static String _maskUserIdentifier(String identifier) {
    if (identifier.contains('@')) {
      // Es un email
      final parts = identifier.split('@');
      if (parts.length == 2) {
        final username = parts[0];
        final domain = parts[1];
        final maskedUsername = username.length > 2 
            ? '${username.substring(0, 2)}***'
            : '***';
        return '$maskedUsername@$domain';
      }
    }
    
    // Para otros identificadores, mostrar solo los primeros 3 caracteres
    return identifier.length > 3 
        ? '${identifier.substring(0, 3)}***'
        : '***';
  }
  
  /// Verifica si el logging está habilitado
  static bool get isLoggingEnabled => kDebugMode && AppConfig.isDebugMode;
}