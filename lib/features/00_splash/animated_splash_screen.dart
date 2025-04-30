import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../02_auth/presentation/screens/auth_screen.dart';

class AnimatedSplashScreen extends ConsumerStatefulWidget {
  final bool goHome;
  const AnimatedSplashScreen({required this.goHome, super.key});

  @override
  AnimatedSplashScreenState createState() => AnimatedSplashScreenState();
}

class AnimatedSplashScreenState extends ConsumerState<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    final Future<String?> hasSessionFuture = getLastSession();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward().whenComplete(() {
        hasSessionFuture.then(
          (token) {
            inspect(token);
            if (mounted) {
              if (token != null && token.isNotEmpty) {
                ref.read(authTokenProvider.notifier).state = token;
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                Navigator.pushReplacementNamed(context, '/login');
              }
            }
          },
        );
      });
  }

  Future<String?> getLastSession() async {
    try {
      final String? authToken =
          await FlutterSecureStorage().read(key: 'auth_token');
      if (authToken == null || authToken.isEmpty) {
        return null;
      }
      return authToken;
    } catch (e) {
      inspect(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ScaleTransition(
                scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                      parent: _controller, curve: Curves.slowMiddle),
                ),
                child: Center(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Hero(
                            tag: 'mironline-logo',
                            child: Image.asset(
                              'assets/logo.png',
                            )))))));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
