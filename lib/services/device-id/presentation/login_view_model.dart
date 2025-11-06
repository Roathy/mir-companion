import '../device_info_repository.dart';

class LoginViewModel {
  final DeviceInfoRepository _deviceInfoRepository;

  LoginViewModel(this._deviceInfoRepository);

  Future<String?> login() async {
    final appSetId = await _deviceInfoRepository.getAppSetId();

    if (appSetId != null) {
      return appSetId;
    } else {
      return null;
    }
  }
}
