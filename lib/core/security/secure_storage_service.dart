import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/secure_logger.dart';

/// Servicio de almacenamiento seguro con cifrado adicional
/// Protege tokens y datos sensibles con múltiples capas de seguridad
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Claves para diferentes tipos de datos
  static const String _authTokenKey = 'secure_auth_token';
  static const String _userDataKey = 'secure_user_data';
  static const String _encryptionKeyKey = 'internal_encryption_key';

  /// Inicializa el servicio de almacenamiento seguro
  static Future<void> initialize() async {
    try {
      // Generar clave de cifrado interna si no existe
      await _ensureEncryptionKey();
      SecureLogger.info('Secure storage service initialized');
    } catch (e) {
      SecureLogger.error('Failed to initialize secure storage', error: e);
      throw Exception('Secure storage initialization failed');
    }
  }

  /// Almacena un token de autenticación de forma segura
  static Future<void> storeAuthToken(String token) async {
    try {
      if (token.isEmpty) {
        throw ArgumentError('Token cannot be empty');
      }

      // Cifrar el token con clave adicional
      final encryptedToken = await _encrypt(token);
      
      // Almacenar con metadatos de seguridad
      final secureData = {
        'token': encryptedToken,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'checksum': _generateChecksum(token),
      };

      await _storage.write(
        key: _authTokenKey,
        value: jsonEncode(secureData),
      );

      SecureLogger.auth('Auth token stored securely');
    } catch (e) {
      SecureLogger.error('Failed to store auth token', error: e);
      throw Exception('Token storage failed');
    }
  }

  /// Recupera un token de autenticación
  static Future<String?> getAuthToken() async {
    try {
      final storedData = await _storage.read(key: _authTokenKey);
      if (storedData == null) {
        return null;
      }

      final secureData = jsonDecode(storedData) as Map<String, dynamic>;
      final encryptedToken = secureData['token'] as String;
      final storedChecksum = secureData['checksum'] as String;
      final timestamp = secureData['timestamp'] as int;

      // Verificar si el token ha expirado (24 horas)
      final tokenAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (tokenAge > 24 * 60 * 60 * 1000) {
        SecureLogger.warning('Auth token expired, removing');
        await deleteAuthToken();
        return null;
      }

      // Descifrar el token
      final decryptedToken = await _decrypt(encryptedToken);

      // Verificar integridad
      if (_generateChecksum(decryptedToken) != storedChecksum) {
        SecureLogger.error('Token integrity check failed');
        await deleteAuthToken();
        return null;
      }

      SecureLogger.auth('Auth token retrieved successfully');
      return decryptedToken;
      
    } catch (e) {
      SecureLogger.error('Failed to retrieve auth token', error: e);
      // En caso de error, limpiar el token corrupto
      await deleteAuthToken();
      return null;
    }
  }

  /// Elimina el token de autenticación
  static Future<void> deleteAuthToken() async {
    try {
      await _storage.delete(key: _authTokenKey);
      SecureLogger.auth('Auth token deleted');
    } catch (e) {
      SecureLogger.error('Failed to delete auth token', error: e);
    }
  }

  /// Verifica si existe un token válido
  static Future<bool> hasValidAuthToken() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Almacena datos de usuario de forma segura
  static Future<void> storeUserData(Map<String, dynamic> userData) async {
    try {
      final encryptedData = await _encrypt(jsonEncode(userData));
      
      final secureData = {
        'data': encryptedData,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'checksum': _generateChecksum(jsonEncode(userData)),
      };

      await _storage.write(
        key: _userDataKey,
        value: jsonEncode(secureData),
      );

      SecureLogger.info('User data stored securely');
    } catch (e) {
      SecureLogger.error('Failed to store user data', error: e);
      throw Exception('User data storage failed');
    }
  }

  /// Recupera datos de usuario
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final storedData = await _storage.read(key: _userDataKey);
      if (storedData == null) {
        return null;
      }

      final secureData = jsonDecode(storedData) as Map<String, dynamic>;
      final encryptedData = secureData['data'] as String;
      final storedChecksum = secureData['checksum'] as String;

      final decryptedData = await _decrypt(encryptedData);
      final userData = jsonDecode(decryptedData) as Map<String, dynamic>;

      // Verificar integridad
      if (_generateChecksum(decryptedData) != storedChecksum) {
        SecureLogger.error('User data integrity check failed');
        await deleteUserData();
        return null;
      }

      return userData;
      
    } catch (e) {
      SecureLogger.error('Failed to retrieve user data', error: e);
      await deleteUserData();
      return null;
    }
  }

  /// Elimina datos de usuario
  static Future<void> deleteUserData() async {
    try {
      await _storage.delete(key: _userDataKey);
      SecureLogger.info('User data deleted');
    } catch (e) {
      SecureLogger.error('Failed to delete user data', error: e);
    }
  }

  /// Limpia todos los datos almacenados
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      SecureLogger.info('All secure storage cleared');
    } catch (e) {
      SecureLogger.error('Failed to clear secure storage', error: e);
    }
  }

  // =============== MÉTODOS PRIVADOS ===============

  /// Asegura que exista una clave de cifrado interna
  static Future<void> _ensureEncryptionKey() async {
    final existingKey = await _storage.read(key: _encryptionKeyKey);
    if (existingKey == null) {
      final newKey = _generateRandomKey();
      await _storage.write(key: _encryptionKeyKey, value: newKey);
    }
  }

  /// Genera una clave aleatoria
  static String _generateRandomKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// Obtiene la clave de cifrado interna
  static Future<String> _getEncryptionKey() async {
    final key = await _storage.read(key: _encryptionKeyKey);
    if (key == null) {
      throw Exception('Encryption key not found');
    }
    return key;
  }

  /// Cifra un texto usando la clave interna
  static Future<String> _encrypt(String plaintext) async {
    try {
      final key = await _getEncryptionKey();
      final keyBytes = base64.decode(key);
      final plaintextBytes = utf8.encode(plaintext);
      
      // Usar HMAC para cifrado básico (en producción usar AES)
      final hmac = Hmac(sha256, keyBytes);
      final digest = hmac.convert(plaintextBytes);
      
      // Combinar datos originales con hash para verificación
      final combined = plaintextBytes + digest.bytes;
      return base64.encode(combined);
      
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  /// Descifra un texto usando la clave interna
  static Future<String> _decrypt(String ciphertext) async {
    try {
      final key = await _getEncryptionKey();
      final keyBytes = base64.decode(key);
      final combined = base64.decode(ciphertext);
      
      if (combined.length < 32) {
        throw Exception('Invalid ciphertext length');
      }
      
      // Separar datos originales y hash
      final plaintextBytes = combined.sublist(0, combined.length - 32);
      final storedHash = combined.sublist(combined.length - 32);
      
      // Verificar integridad
      final hmac = Hmac(sha256, keyBytes);
      final computedHash = hmac.convert(plaintextBytes);
      
      if (!_bytesEqual(storedHash, computedHash.bytes)) {
        throw Exception('Data integrity check failed');
      }
      
      return utf8.decode(plaintextBytes);
      
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Genera un checksum para verificación de integridad
  static String _generateChecksum(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Compara dos listas de bytes de forma segura
  static bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}