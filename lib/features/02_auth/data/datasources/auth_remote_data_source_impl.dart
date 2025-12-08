
import 'package:dio/dio.dart';
import '../../../../core/utils/utils.dart';
import '../../../../network/api_endpoints.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<String> loginWithGoogle(String idToken, String deviceId) async {
    final fullUrl = "${ApiEndpoints.baseURL}${ApiEndpoints.studentsLogin}";

    try {
      final response = await dio.post(
        fullUrl,
        data: {
          "google_token": idToken,
          "device_id": deviceId,
        },
        options: Options(headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-App-MirHorizon": createMD5Hash(),
        }),
      );

      if (response.data["success"] == true) {
        final token = response.data['data']['token'];
        if (token != null) {
          return token;
        }
      } 
      
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: "Invalid response format: missing token",
      );
      
    } catch (e) {
      rethrow;
    }
  }
}
