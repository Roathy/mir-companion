import 'dart:convert';

/// Utilidades para validación y sanitización de entrada
/// Previene ataques de inyección y datos maliciosos
class InputValidator {
  // Patrones de validación
  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp _alphanumericPattern = RegExp(r'^[a-zA-Z0-9]+$');
  static final RegExp _safeTextPattern = RegExp(r'^[a-zA-Z0-9\s\-._@]+$');
  
  // Caracteres peligrosos que deben ser removidos o escapados
  static final List<String> _dangerousChars = [
    '<', '>', '"', "'", '&', '/', '\\', '{', '}', '[', ']', '(', ')',
    ';', ':', '|', '`', '~', '!', '@', '#', '\$', '%', '^', '*', '+', '=',
    '?', '\n', '\r', '\t'
  ];

  /// Valida y sanitiza un email
  static ValidationResult validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return ValidationResult(
        isValid: false,
        sanitizedValue: '',
        errorMessage: 'Email is required',
      );
    }

    // Sanitizar el email
    String sanitized = sanitizeBasicInput(email);
    
    // Validar longitud
    if (sanitized.length > 254) {
      return ValidationResult(
        isValid: false,
        sanitizedValue: sanitized,
        errorMessage: 'Email is too long',
      );
    }

    // Validar formato
    if (!_emailPattern.hasMatch(sanitized)) {
      return ValidationResult(
        isValid: false,
        sanitizedValue: sanitized,
        errorMessage: 'Please enter a valid email address',
      );
    }

    return ValidationResult(
      isValid: true,
      sanitizedValue: sanitized.toLowerCase().trim(),
      errorMessage: null,
    );
  }

  /// Valida y sanitiza una contraseña
  static ValidationResult validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return ValidationResult(
        isValid: false,
        sanitizedValue: '',
        errorMessage: 'Password is required',
      );
    }

    // Para contraseñas, sanitizar menos agresivamente
    String sanitized = password.trim();
    
    // Validar longitud mínima
    if (sanitized.length < 6) {
      return ValidationResult(
        isValid: false,
        sanitizedValue: sanitized,
        errorMessage: 'Password must be at least 6 characters long',
      );
    }

    // Validar longitud máxima
    if (sanitized.length > 128) {
      return ValidationResult(
        isValid: false,
        sanitizedValue: sanitized,
        errorMessage: 'Password is too long',
      );
    }

    // Verificar que no contenga caracteres peligrosos específicos
    final dangerousForPassword = ['<', '>', '"', "'", '&', '\n', '\r', '\t'];
    for (final char in dangerousForPassword) {
      if (sanitized.contains(char)) {
        return ValidationResult(
          isValid: false,
          sanitizedValue: sanitized,
          errorMessage: 'Password contains invalid characters',
        );
      }
    }

    return ValidationResult(
      isValid: true,
      sanitizedValue: sanitized,
      errorMessage: null,
    );
  }

  /// Valida y sanitiza texto general
  static ValidationResult validateText(String? text, {
    int maxLength = 255,
    int minLength = 1,
    bool allowEmpty = false,
    bool strictMode = true,
  }) {
    if (text == null || text.isEmpty) {
      if (allowEmpty) {
        return ValidationResult(
          isValid: true,
          sanitizedValue: '',
          errorMessage: null,
        );
      }
      return ValidationResult(
        isValid: false,
        sanitizedValue: '',
        errorMessage: 'This field is required',
      );
    }

    // Sanitizar según el modo
    String sanitized = strictMode 
        ? sanitizeStrictInput(text)
        : sanitizeBasicInput(text);

    // Validar longitud
    if (sanitized.length < minLength) {
      return ValidationResult(
        isValid: false,
        sanitizedValue: sanitized,
        errorMessage: 'Text is too short (minimum $minLength characters)',
      );
    }

    if (sanitized.length > maxLength) {
      return ValidationResult(
        isValid: false,
        sanitizedValue: sanitized.substring(0, maxLength),
        errorMessage: 'Text is too long (maximum $maxLength characters)',
      );
    }

    return ValidationResult(
      isValid: true,
      sanitizedValue: sanitized,
      errorMessage: null,
    );
  }

  /// Sanitización básica para inputs generales
  static String sanitizeBasicInput(String input) {
    String sanitized = input.trim();
    
    // Remover caracteres de control
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    
    // Escapar caracteres HTML básicos
    sanitized = sanitized
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
    
    return sanitized;
  }

  /// Sanitización estricta para inputs sensibles
  static String sanitizeStrictInput(String input) {
    String sanitized = input.trim();
    
    // Remover todos los caracteres peligrosos
    for (final char in _dangerousChars) {
      sanitized = sanitized.replaceAll(char, '');
    }
    
    // Remover caracteres de control y no ASCII
    sanitized = sanitized.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
    
    // Remover múltiples espacios
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    
    return sanitized.trim();
  }

  /// Sanitiza JSON para prevenir inyección
  static String? sanitizeJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      // Intentar decodificar para validar que es JSON válido
      final decoded = jsonDecode(jsonString);
      
      // Re-codificar para limpiar cualquier caracteres extraño
      return jsonEncode(decoded);
    } catch (e) {
      return null; // JSON inválido
    }
  }

  /// Valida URL para WebView
  static bool isUrlSafe(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Solo permitir HTTPS (o HTTP para desarrollo local)
      if (!uri.hasScheme || 
          (uri.scheme != 'https' && 
           !_isLocalDevelopmentUrl(uri))) {
        return false;
      }
      
      // Validar que el host no esté vacío
      if (uri.host.isEmpty) {
        return false;
      }
      
      // Verificar que no contenga caracteres peligrosos
      final urlString = url.toLowerCase();
      final dangerousPatterns = [
        'javascript:', 'data:', 'file:', 'ftp:', 'blob:',
        'vbscript:', 'about:', 'chrome:', 'resource:',
      ];
      
      for (final pattern in dangerousPatterns) {
        if (urlString.contains(pattern)) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si es una URL de desarrollo local
  static bool _isLocalDevelopmentUrl(Uri uri) {
    if (uri.scheme != 'http') return false;
    
    final localHosts = ['localhost', '127.0.0.1', '10.0.2.2'];
    return localHosts.contains(uri.host);
  }

  /// Sanitiza datos de respuesta de API
  static Map<String, dynamic> sanitizeApiResponse(Map<String, dynamic> response) {
    final sanitized = <String, dynamic>{};
    
    response.forEach((key, value) {
      final sanitizedKey = sanitizeStrictInput(key);
      
      if (value is String) {
        sanitized[sanitizedKey] = sanitizeBasicInput(value);
      } else if (value is Map<String, dynamic>) {
        sanitized[sanitizedKey] = sanitizeApiResponse(value);
      } else if (value is List) {
        sanitized[sanitizedKey] = _sanitizeList(value);
      } else {
        sanitized[sanitizedKey] = value;
      }
    });
    
    return sanitized;
  }

  /// Sanitiza una lista recursivamente
  static List _sanitizeList(List list) {
    return list.map((item) {
      if (item is String) {
        return sanitizeBasicInput(item);
      } else if (item is Map<String, dynamic>) {
        return sanitizeApiResponse(item);
      } else if (item is List) {
        return _sanitizeList(item);
      } else {
        return item;
      }
    }).toList();
  }

  /// Valida ID numérico
  static ValidationResult validateId(dynamic id) {
    if (id == null) {
      return ValidationResult(
        isValid: false,
        sanitizedValue: null,
        errorMessage: 'ID is required',
      );
    }

    int? numericId;
    
    if (id is int) {
      numericId = id;
    } else if (id is String) {
      numericId = int.tryParse(sanitizeStrictInput(id));
    }

    if (numericId == null || numericId <= 0) {
      return ValidationResult(
        isValid: false,
        sanitizedValue: id,
        errorMessage: 'Invalid ID format',
      );
    }

    return ValidationResult(
      isValid: true,
      sanitizedValue: numericId,
      errorMessage: null,
    );
  }
}

/// Resultado de validación
class ValidationResult {
  final bool isValid;
  final dynamic sanitizedValue;
  final String? errorMessage;

  const ValidationResult({
    required this.isValid,
    required this.sanitizedValue,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, sanitizedValue: $sanitizedValue, errorMessage: $errorMessage)';
  }
}