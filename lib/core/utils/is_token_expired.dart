import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<bool> isTokenExpired() async {
  final storage = FlutterSecureStorage();

  // Retrieve the expiration time
  String? expiresAtString = await storage.read(key: 'expires_at');
  if (expiresAtString == null) {
    return true;
  } // If there's no expiration time, treat it as expired.

  // Parse the stored expiration time into a DateTime object
  DateTime expiresAt = DateTime.parse(expiresAtString);

  // Compare the expiration time with the current time
  return DateTime.now().isAfter(expiresAt);
}
