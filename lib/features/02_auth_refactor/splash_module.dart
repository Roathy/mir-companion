import 'package:mironline/core/di/service_locator.dart';

import '../00_splash_refactor/domain/usecases/check_auth_status_usecase.dart';

Future<void> initSplashModule() async {
  // Usecases
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
}
