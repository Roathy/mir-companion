import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/infra/navigation/router.dart';
import '../controllers/splash_controller.dart';
import '../states/splash_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward().whenComplete(() {
        ref.read(splashControllerProvider.notifier).checkAuthStatus();
      });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SplashState>(splashControllerProvider, (previous, current) {
      current.when(
        initial: () => null,
        loading: () => null,
        authenticated: () => context.go(AppRoutes.home),
        unauthenticated: () => context.go(AppRoutes.login),
        error: (message) {
          context.go(AppRoutes.login);
        },
      );
    });

    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.slowMiddle),
          ),
          child: Center(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Hero(
                  tag: 'mironline-logo',
                  child: Image.asset('assets/logo.png'),
                )),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
