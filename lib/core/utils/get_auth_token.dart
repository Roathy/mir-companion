import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<String> getAuthToken() async {
  final storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'auth_token');
  return token ?? '';
}
