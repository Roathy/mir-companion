
abstract class AuthRemoteDataSource {
  Future<String> loginWithGoogle(String idToken, String deviceId);
}
