import 'package:flutter/material.dart';
import 'package:mir_companion_app/lab_widgets/two_word_container.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

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
    )..forward().whenComplete(() => navigateToHome());
  }

  void navigateToHome() {
    Navigator.pushReplacementNamed(context, '/welcome');
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
              // Text(
              //   'MIR',
              //   style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 21),
              // ),
              // Text(
              //   'companion',
              //   style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 45),
              // ),
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
