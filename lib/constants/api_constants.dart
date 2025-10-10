class ApiConstants {
  static const String baseURL = 'https://api.mironline.io/api/v1/students';
  static String userLoginURL = '$baseURL/login';
  static String userFetchURL = '$baseURL/today';
  static String checkAlive = '$baseURL/check-alive';
  static String groupEnroll = '$baseURL/group-enroll';
  static const String group = '$baseURL/group';
  static String groupUnenroll = '$baseURL/group-unenroll?word=LEAVE';
}
