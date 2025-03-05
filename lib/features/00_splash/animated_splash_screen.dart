import 'package:flutter/material.dart';

class AnimatedSplashScreen extends StatefulWidget {
  final bool goHome;
  const AnimatedSplashScreen({required this.goHome, super.key});

  @override
  AnimatedSplashScreenState createState() => AnimatedSplashScreenState();
}

class AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward().whenComplete(() {
        Navigator.pushNamed(context, '/login');
      });
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
