import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
}

final GoRouter appRouter = GoRouter(initialLocation: AppRoutes.splash, routes: [
  GoRoute(
    path: AppRoutes.splash,
    // builder: (context, state) => SplashScreen(),
  ),
  GoRoute(
    path: AppRoutes.login,
  ),
]);
