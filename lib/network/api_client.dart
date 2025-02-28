import 'package:dio/dio.dart';

class DioClient {
  late Dio _dio;

  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://your-api-url.com/', // Your base URL
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ));
  }

  Dio get dio => _dio;

  // You can add interceptors here if needed
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }
}
