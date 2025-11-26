import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/00_splash/animated_splash_screen.dart';
import 'features/02_auth/presentation/screens/auth_screen.dart';
import 'features/03_today/presentation/screens/join_group_screen.dart';
import 'features/03_today/presentation/screens/today_screen.dart';
import 'features/04_egp_levels/presentation/screens/students_egp_levels_screen.dart';
import 'features/06_unit_activities/presentation/screens/unit_activities_screen.dart';

const platform = MethodChannel('refresh_rate');

Future<void> setRefreshRate(double rate) async {
  try {
    await platform.invokeMethod('setRefreshRate', {'rate': rate});
  } catch (e) {
    // TODO
    // manage error when failing to set the refresh rate
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  setRefreshRate(60.0);
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
    // WidgetsBinding.instance.addPostFrameCallback((_) {});
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
        '/': (context) => AnimatedSplashScreen(),
        '/login': (context) => LoginPage(),
        '/home': (context) => StudentTodayScreen(),
        '/egp-levels': (context) => StudentsEgpLevelsScreen(),
        '/unit-activities': (context) => UnitActivitiesScreen(),
        '/join-group': (context) => JoinGroupScreen(),
      },
    );
    // }
  }
}
