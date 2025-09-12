import 'package:app_set_id/app_set_id.dart';
import 'package:mironline/services/device-id/device_info_repository.dart';

class DeviceInfoRepoImpl implements DeviceInfoRepository {
  final AppSetId _appSetId;

  DeviceInfoRepoImpl(this._appSetId);

  @override
  Future<String?> getAppSetId() async {
    try {
      final appSetId = await _appSetId.getIdentifier();
      return appSetId;
    } catch (e) {
      return null;
    }
  }
}
