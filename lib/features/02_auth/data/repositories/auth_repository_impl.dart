
import '../../../../services/device-id/device_info_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final DeviceInfoRepository deviceInfoRepository;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.deviceInfoRepository,
  });

  @override
  Future<String> loginWithGoogle(String idToken) async {
    final deviceId = await deviceInfoRepository.getAppSetId();
    if (deviceId == null) {
      throw Exception("Failed to retrieve device ID");
    }
    return remoteDataSource.loginWithGoogle(idToken, deviceId);
  }
}
