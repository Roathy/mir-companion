import '../../core/di/service_locator.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/auth_repository_impl.dart';
import 'domain/usecases/get_stored_auth_token_usecase.dart';

// Data sources
Future<void> initAuthModule() async {
  sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Usecases
  sl.registerLazySingleton(() => GetStoredAuthTokenUseCase(sl()));
}
