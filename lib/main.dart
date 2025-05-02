import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mironline/features/00_splash_refactor/presentation/pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/service_locator.dart' as di;
import 'features/00_splash/animated_splash_screen.dart';
import 'features/01_welcome_tour/welcome_tour_page.dart';
import 'features/02_auth/presentation/screens/auth_screen.dart';
import 'features/03_today/presentation/screens/today_screen.dart';
import 'features/04_egp_levels/presentation/screens/students_egp_levels_screen.dart';

import 'package:flutter/services.dart';

import 'features/06_unit_activities/presentation/screens/unit_activities_screen.dart';

const platform = MethodChannel('refresh_rate');

Future<void> setRefreshRate(double rate) async {
  try {
    await platform.invokeMethod('setRefreshRate', {'rate': rate});
  } catch (e) {
    print('Error: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setRefreshRate(60.0);
  await di.initDependencies();
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
      // _checkAndShowTour();
    });
  }

  // Future<void> _checkAndShowTour() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     bool dontShowTour = prefs.getBool('dontShowTour') ?? false;
  //     if (mounted) {
  //       setState(() {
  //         goHome = dontShowTour;
  //       });
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint('Error reading SharedPreferences: $e');
  //     debugPrint(stackTrace.toString());
  //   }
  // }

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
          '/': (context) => SplashScreen(),
          // '/': (context) => AnimatedSplashScreen(goHome: goHome),
          '/welcome': (context) => WelcomeTourPage(),
          '/login': (context) => LoginPage(),
          '/home': (context) => StudentTodayScreen(),
          '/egp-levels': (context) => StudentsEgpLevelsScreen(),
          '/unit-activities': (context) => UnitActivitiesScreen(),
        });
  }
}
