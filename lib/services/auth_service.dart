import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../core/security/secure_storage_service.dart';
import '../core/utils/secure_logger.dart';
import '../core/utils/input_validator.dart';

class AuthService {
  /// ✅ SEGURO: Crear hash usando configuración segura
  String createMD5Hash() {
    return AppConfig.createSecureHash();
  }

  /// ✅ SEGURO: Obtener token de usuario con validación
  Future<String?> getUserToken(String email, String password) async {
    // Validar y sanitizar entradas
    final emailValidation = InputValidator.validateEmail(email);
    final passwordValidation = InputValidator.validatePassword(password);
    
    if (!emailValidation.isValid) {
      throw Exception('Invalid email: ${emailValidation.errorMessage}');
    }
    
    if (!passwordValidation.isValid) {
      throw Exception('Invalid password: ${passwordValidation.errorMessage}');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.studentsLoginEndpoint}'),
    );

    // Obtener token existente de forma segura
    final existingToken = await SecureStorageService.getAuthToken();

    request.headers.addAll({
      'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer ${existingToken ?? ''}',
      'X-App-MirHorizon': createMD5Hash(),
    });

    request.fields['email'] = emailValidation.sanitizedValue;
    request.fields['password'] = passwordValidation.sanitizedValue;

    try {
      final response = await http.Response.fromStream(await request.send());
      SecureLogger.network('Login response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        
        // ✅ SEGURIDAD: Sanitizar respuesta de la API
        final sanitizedResponse = InputValidator.sanitizeApiResponse(decodedResponse);
        await Future.delayed(const Duration(milliseconds: 120));

        if (sanitizedResponse.containsKey('data')) {
          final Map<String, dynamic> data = sanitizedResponse['data'];
          if (data.containsKey('auth_token')) {
            final String accessToken = data['auth_token'].toString();
            
            // ✅ SEGURIDAD: Usar almacenamiento cifrado
            await SecureStorageService.storeAuthToken(accessToken);
            SecureLogger.loginSuccess(emailValidation.sanitizedValue);
            
            return accessToken;
          } else {
            SecureLogger.error('Access token not found in login response');
            throw Exception('Failed to authenticate. Access token not found in response.');
          }
        } else {
          SecureLogger.error('Data key not found in login response');
          throw Exception('Failed to authenticate. "data" key not found in response.');
        }
      } else {
        SecureLogger.error('Login failed with status code: ${response.statusCode}');
        throw Exception('Failed to authenticate. Status code: ${response.statusCode}');
      }
    } catch (e) {
      SecureLogger.error('Login authentication failed', error: e);
      throw Exception('Failed to authenticate. Error: $e');
    }
  }

  /// ✅ SEGURO: Obtener datos de usuario de forma segura
  Future<Map<String, dynamic>> userLogin() async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.studentsProfileEndpoint}'),
    );

    // ✅ SEGURIDAD: Usar almacenamiento seguro
    String? token = await SecureStorageService.getAuthToken();
    if (token == null || token.isEmpty) {
      SecureLogger.warning('No auth token found for user data fetch');
      throw Exception('No token found. Please login again.');
    }

    request.headers.addAll({
      'X-Requested-With': 'XMLHttpRequest',
      'X-App-MirHorizon': createMD5Hash(),
      'Authorization': 'Bearer $token',
    });

    try {
      final response = await http.Response.fromStream(await request.send());
      SecureLogger.network('User data fetch status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        
        // ✅ SEGURIDAD: Sanitizar respuesta
        final sanitizedResponse = InputValidator.sanitizeApiResponse(decodedResponse);

        await Future.delayed(const Duration(milliseconds: 120));
        if (sanitizedResponse.containsKey('data')) {
          final Map<String, dynamic> userData = sanitizedResponse['data'];
          
          // ✅ SEGURIDAD: Almacenar datos de usuario de forma segura
          await SecureStorageService.storeUserData(userData);
          SecureLogger.info('User data retrieved and stored securely');
          
          return userData;
        } else {
          SecureLogger.error('Data key not found in user data response');
          throw Exception('Failed to fetch user data. "data" key not found in response.');
        }
      } else {
        SecureLogger.error('User data fetch failed with status: ${response.statusCode}');
        throw Exception('Failed to fetch user data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      SecureLogger.error('User data fetch failed', error: e);
      throw Exception('Failed to fetch user data. Error: $e');
    }
  }

  /// ✅ SEGURO: Logout con limpieza completa de datos
  Future<void> logoutUser() async {
    final String? token = await SecureStorageService.getAuthToken();
    if (token == null || token.isEmpty) {
      SecureLogger.warning('No token found during logout');
      // Limpiar datos locales de todas formas
      await SecureStorageService.clearAll();
      return;
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'X-Requested-With': 'XMLHttpRequest',
      'X-App-MirHorizon': createMD5Hash(),
    };

    final url = Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.studentsLogoutEndpoint}');

    try {
      final response = await http.get(url, headers: headers);
      SecureLogger.network('Logout response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // ✅ SEGURIDAD: Limpiar todos los datos almacenados de forma segura
        await SecureStorageService.clearAll();
        SecureLogger.logoutSuccess();
      } else {
        SecureLogger.error('Logout failed with status: ${response.statusCode}');
        // Limpiar datos locales aunque el servidor falle
        await SecureStorageService.clearAll();
        throw Exception('Logout failed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      SecureLogger.error('Logout error', error: e);
      // En caso de error, limpiar datos locales de todas formas
      await SecureStorageService.clearAll();
      throw Exception('Logout error: $e');
    }
  }
}
