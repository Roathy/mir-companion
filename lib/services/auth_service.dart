import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mironline/services/device-id/device_info_repository.dart';

import '../../constants/api_constants.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final DeviceInfoRepository _deviceInfoRepository;

  AuthService(this._deviceInfoRepository);

  String createMD5Hash() {
    DateTime now = DateTime.now();
    final String day = now.day.toString().padLeft(2, '0');
    final String month = now.month.toString().padLeft(2, '0');
    String toHash = '${dotenv.env['SECRET_KEY']}-${now.year}$month$day';
    log('toHash: $toHash');
    return md5.convert(utf8.encode(toHash)).toString();
  }

  Future<String?> getUserToken(String email, String password) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.userLoginURL),
    );

    request.headers.addAll({
      'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer ${await _storage.read(key: 'auth_token') ?? ''}',
      'X-App-MirHorizon': createMD5Hash(),
    });

    final String? deviceId = await _deviceInfoRepository.getAppSetId();
    if (deviceId != null) {
      request.fields['device_id'] = deviceId;
    }
    request.fields['email'] = email;
    request.fields['password'] = password;

    try {
      final response = await http.Response.fromStream(await request.send());
      inspect(response);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        await Future.delayed(const Duration(milliseconds: 120));

        if (decodedResponse.containsKey('data')) {
          final Map<String, dynamic> data = decodedResponse['data'];
          if (data.containsKey('auth_token')) {
            final String accessToken = data['auth_token'];
            await _storage.write(key: 'auth_token', value: accessToken);
            return accessToken;
          } else {
            throw Exception(
                'Failed to authenticate. Access token not found in response.');
          }
        } else {
          throw Exception(
              'Failed to authenticate. "data" key not found in response.');
        }
      } else {
        throw Exception(
            'Failed to authenticate. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to authenticate. Error: $e');
    }
  }

  Future<Map<String, dynamic>> userLogin() async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.userFetchURL),
    );

    String? token = await _storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('No token found. Please login again.');
    }

    request.headers.addAll({
      'X-Requested-With': 'XMLHttpRequest',
      'X-App-MirHorizon': createMD5Hash(),
      'Authorization': 'Bearer $token',
    });

    try {
      final response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);

        await Future.delayed(const Duration(milliseconds: 120));
        if (decodedResponse.containsKey('data')) {
          final Map<String, dynamic> userData = decodedResponse['data'];
          return userData;
        } else {
          throw Exception(
              'Failed to authenticate. "message" key not found in response.');
        }
      } else {
        throw Exception(
            'Failed to authenticate. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('failed to authenticate. Error $e');
    }
  }

  Future<void> logoutUser() async {
    String? token = await _storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('No token found. User may already be logged out.');
    }

    // Las cabeceras exactas que pide la documentación
    final headers = {
      'Authorization': 'Bearer $token',
      'X-Requested-With': 'XMLHttpRequest',
      'X-App-MirHorizon': createMD5Hash(),
    };

    final url = Uri.parse('https://api.mironline.io/api/v1/students/logout');
    log('Attempting logout with GET to $url');
    log('Headers: $headers');

    try {
      // Usando el método GET, como lo especifica la documentación
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        log('Logout successful: ${response.body}');
        await _storage.delete(key: 'auth_token');
      } else {
        log('Logout failed with status: ${response.statusCode}');
        log('Response body: ${response.body}');
        throw Exception('Logout failed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }
}
