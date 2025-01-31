import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mir_companion_app/lab_features/background_video/background_video_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/06_a11_unit1_activities/view/pages/a11_unit1_activities_page.dart';
import 'features/05_egp_a11_units/view/pages/egp_units_page.dart';
import 'features/04_egp_leves/egp_levels_page.dart';
import 'features/03_home/view/screens/home_screen.dart';
import 'features/02_login/login_and_google.dart';
import 'features/01_welcome_tour/welcome_tour_page.dart';
import 'features/00_splash/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(
    child: MyApp(),
  ));
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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _checkAndShowTour();
      },
    );
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
      title: 'MIR Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => AnimatedSplashScreen(goHome: goHome),
        // '/': (context) => VideoBackgroundScreen(),
        '/welcome': (context) => WelcomeTourPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => Home(),
        '/egp-levels': (context) => EGPLevels(),
        '/a1-1': (context) => EGPA11(),
        '/a11-activities': (context) => A11Activities(),
      },
    );
  }
}
