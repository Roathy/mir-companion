import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants/api_constants.dart';
import '../core/utils/crypto.dart';
import '../core/utils/json_utils.dart';
import 'device-id/device_info_repository.dart';

class NotEnrolledInGroupException implements Exception {
  final String message;
  NotEnrolledInGroupException(this.message);
}

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final DeviceInfoRepository _deviceInfoRepository;

  AuthService(this._deviceInfoRepository);

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
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            await compute(jsonDecode, response.body);
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
    String? token = await _storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('No token found. Please login again.');
    }

    final headers = {
      'X-Requested-With': 'XMLHttpRequest',
      'X-App-MirHorizon': createMD5Hash(),
      'Authorization': 'Bearer $token',
    };

    final url = Uri.parse(ApiConstants.userFetchURL);

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            await compute(jsonDecode, response.body);

        await Future.delayed(const Duration(milliseconds: 120));
        if (decodedResponse.containsKey('data')) {
          final Map<String, dynamic> userData = decodedResponse['data'];
          return userData;
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

  Future<bool> isTokenValid() async {
    String? token = await _storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      return false;
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'X-Requested-With': 'XMLHttpRequest',
      'X-App-MirHorizon': createMD5Hash(),
    };

    final url = Uri.parse(ApiConstants.checkAlive);

    try {
      final response = await http.get(url, headers: headers);
      final bool isValid = response.statusCode == 200;
      return isValid;
    } catch (e) {
      return false;
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
    try {
      // Usando el método GET, como lo especifica la documentación
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        await _storage.delete(key: 'auth_token');
      } else {
        throw Exception('Logout failed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }

  Future<Map<String, dynamic>> joinGroup(String code) async {
    String? token = await _storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('No token found. Please login again.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'X-App-MirHorizon': createMD5Hash(),
      'Authorization': 'Bearer $token',
    };

    final url = Uri.parse(ApiConstants.groupEnroll);
    final body = json.encode({'code': code});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            await compute(jsonDecode, response.body);
        return decodedResponse;
      } else {
        throw Exception(
            'Failed to join group. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to join group. Error: $e');
    }
  }

  Future<Map<String, dynamic>> unlockLevel(String code) async {
    String? token = await _storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('No token found. Please login again.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'X-App-MirHorizon': createMD5Hash(),
      'Authorization': 'Bearer $token',
    };

    final url = Uri.parse(ApiConstants.activateCode);
    final body = json.encode({'code': code});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            await compute(jsonDecode, response.body);
        return decodedResponse;
      } else {
        throw Exception(
            'Failed to unlock level. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to unlock level. Error: $e');
    }
  }

  Future<void> leaveGroup() async {
    String? token = await _storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('No token found. Please login again.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'X-App-MirHorizon': createMD5Hash(),
      'Authorization': 'Bearer $token',
    };

    final url = Uri.parse(ApiConstants.groupUnenroll);

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to leave group. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to leave group. Error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchGroup() async {
    String? token = await _storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('No token found. Please login again.');
    }

    final headers = {
      'X-Requested-With': 'XMLHttpRequest',
      'X-App-MirHorizon': createMD5Hash(),
      'Authorization': 'Bearer $token',
    };

    final url = Uri.parse(ApiConstants.group);

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            await compute(jsonDecode, response.body);
        return decodedResponse;
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> decodedResponse =
            await compute(jsonDecode, response.body);
        if (decodedResponse.containsKey('error') &&
            decodedResponse['error']['message'] ==
                'You are not currently enrolled in a group') {
          throw NotEnrolledInGroupException(
              decodedResponse['error']['message']);
        }
      }
      throw Exception(
          'Failed to fetch group. Status code: ${response.statusCode}');
    } catch (e) {
      if (e is NotEnrolledInGroupException) {
        rethrow;
      }
      throw Exception('Failed to fetch group. Error: $e');
    }
  }
}
