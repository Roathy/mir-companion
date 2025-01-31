import 'dart:developer';

import 'package:flutter/material.dart';

import '../../lab_features/lab_widgets/two_word_container.dart';

class AnimatedSplashScreen extends StatefulWidget {
  final bool goHome;

  const AnimatedSplashScreen({required this.goHome, super.key});

  @override
  AnimatedSplashScreenState createState() => AnimatedSplashScreenState();
}

class AnimatedSplashScreenState extends State<AnimatedSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward().whenComplete(() => widget.goHome ? navigateToLogin() : navigateToTour());
  }

  void navigateToTour() {
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  void navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
          ),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TwoWordContainer(title: 'companion', subtitle: 'MIR'),
              Image.asset('assets/logo.png'),
            ],
          )),
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
