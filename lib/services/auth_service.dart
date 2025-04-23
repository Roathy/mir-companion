import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants/api_constants.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String createMD5Hash() {
    DateTime now = DateTime.now();
    final String month = now.month.toString().padLeft(2, '0');
    String toHash = '752486-${now.year}$month${now.day}';
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

  //todo: logout
  Future<void> logoutUser() async {
    final String? token = await _storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('No token found. User may already be logged out.');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'X-Requested-With': 'XMLHttpRequest',
      'X-App-MirHorizon': createMD5Hash(),
    };

    final url = Uri.parse('https://api.mironline.io/api/v1/students/logout');

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        await _storage.delete(
            key: 'auth_token'); // Borra el token del dispositivo
      } else {
        log('Logout failed: ${response.statusCode}');
        throw Exception('Logout failed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }
}
