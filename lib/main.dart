import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/00_splash/animated_splash_screen.dart';
import 'features/01_welcome_tour/welcome_tour_page.dart';
import 'features/02_auth/presentation/auth_screen.dart';
import 'features/03_1_students_profile/students_profile_screen.dart';
import 'features/04_egp_leves/students_egp_levels_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool goHome = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTour();
    });
  }

  Future<void> _checkAndShowTour() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool dontShowTour = prefs.getBool('dontShowTour') ?? false;

      if (mounted) {
        setState(() {
          goHome = dontShowTour;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error reading SharedPreferences: $e');
      debugPrint(stackTrace.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'mironline',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routes: {
          '/': (context) => AnimatedSplashScreen(goHome: goHome),
          '/welcome': (context) => WelcomeTourPage(),
          '/login': (context) => LoginPage(),
          '/home': (context) => StudentTodayScreen(),
          '/egp-levels': (context) => StudentsEgpLevelsScreen(),
        });
  }
}
