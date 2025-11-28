import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({required String authToken}) : _dio = Dio() {
    _dio.options.headers['Authorization'] = 'Bearer $authToken';
  }

  Dio get dio => _dio;
}
