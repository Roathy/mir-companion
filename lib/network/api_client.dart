import 'package:dio/dio.dart';

/// A singleton class to manage the single instance of the Dio HTTP client.
/// This approach ensures that all API calls share the same configuration
/// and resources, improving efficiency and consistency.
class ApiClient {
  // A private static instance of the class itself.
  // This is the core of the singleton pattern.
  static final ApiClient _instance = ApiClient._internal();

  // A private final instance of the Dio client.
  // We use 'final' because we only initialize it once.
  final Dio _dio;

  /// A factory constructor that always returns the same singleton instance.
  /// This prevents the creation of multiple ApiClient objects.
  factory ApiClient() {
    return _instance;
  }

  /// The private constructor used to initialize the singleton instance.
  /// It's marked as private with an underscore to prevent direct instantiation.
  ApiClient._internal() : _dio = Dio();

  /// A public getter to access the configured Dio instance.
  /// This is the primary way to get the client for making requests.
  Dio get dio => _dio;

  /// A method to add a list of Interceptors to the Dio instance.
  /// Interceptors are useful for logging, authentication, and error handling.
  ///
  /// Example:
  /// apiClient.addInterceptors([
  ///   LogInterceptor(),
  ///   AuthInterceptor(),
  /// ]);
  // void addInterceptors(List<Interceptor> interceptors) {
  //   _dio.interceptors.addAll(interceptors);
  // }

  /// A method to configure the Dio instance with base options.
  /// This is where you would set the base URL, timeouts, and headers.
  ///
  /// Example:
  /// apiClient.configureDio(
  ///   BaseOptions(
  ///     baseUrl: 'https://api.example.com',
  ///     connectTimeout: 5000,
  ///     receiveTimeout: 3000,
  ///   ),
  /// );
  // void configureDio(BaseOptions options) {
  //   _dio.options = options;
  // }
}
