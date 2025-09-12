import 'package:app_set_id/app_set_id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mironline/services/auth_service.dart';
import 'package:mironline/services/device-id/device_info_repo_impl.dart';
import 'package:mironline/services/device-id/device_info_repository.dart';

// Provider for AppSetId package
final appSetIdProvider = Provider<AppSetId>((ref) {
  return AppSetId();
});

// Provider for DeviceInfoRepository
final deviceInfoRepositoryProvider = Provider<DeviceInfoRepository>((ref) {
  final appSetId = ref.watch(appSetIdProvider);
  return DeviceInfoRepoImpl(appSetId);
});

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final deviceInfoRepository = ref.watch(deviceInfoRepositoryProvider);
  return AuthService(deviceInfoRepository);
});
