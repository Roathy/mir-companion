import 'package:app_set_id/app_set_id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/02_auth/presentation/screens/auth_screen.dart';
import '../network/api_client.dart';
import 'auth_service.dart';
import 'device-id/device_info_repo_impl.dart';
import 'device-id/device_info_repository.dart';

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

// final dioProvider = Provider<ApiClient>((ref) => ApiClient());

final apiClientProvider = Provider<ApiClient>((ref) {
  final authToken = ref.watch(authTokenProvider);
  return ApiClient(authToken: authToken);
});
