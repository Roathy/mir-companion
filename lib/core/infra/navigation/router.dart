import 'package:go_router/go_router.dart';

import '../../../features/00_splash_refactor/presentation/pages/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
}

final GoRouter appRouter = GoRouter(initialLocation: AppRoutes.splash, routes: [
  GoRoute(
    path: AppRoutes.splash,
    builder: (context, state) => const SplashScreen(),
  ),
]);
