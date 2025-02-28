import 'package:dio/dio.dart';

import 'api_client.dart';

class ApiService {
  final DioClient dioClient;

  ApiService(this.dioClient);

  Future<Response> login(String email, String password, String md5Hash) async {
    final String fullUrl = '/login'; // Your login endpoint

    return await dioClient.dio.post(
      fullUrl,
      data: {"email": email, "password": password},
      options: Options(
        headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-App-MirHorizon": md5Hash,
        },
      ),
    );
  }

  Future<Response> fetchStudentProfile(String authToken, String md5Hash) async {
    final String fullUrl = '/profile'; // Your profile endpoint

    return await dioClient.dio.get(
      fullUrl,
      options: Options(
        headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-App-MirHorizon": md5Hash,
          "Authorization": "Bearer $authToken", // Token authorization
        },
      ),
    );
  }
}
