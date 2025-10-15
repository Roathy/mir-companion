import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({required String authToken}) : _dio = Dio() {
    debugPrint("--- ApiClient --- Creating new instance with token: $authToken");
    _dio.options.headers['Authorization'] = 'Bearer $authToken';
  }

  Dio get dio => _dio;
}
