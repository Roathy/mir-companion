import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

import 'features/00_splash/animated_splash_screen.dart';
import 'features/01_welcome_tour/welcome_tour_page.dart';
import 'features/02_auth/presentation/screens/auth_screen.dart';
import 'features/03_today/presentation/screens/today_screen.dart';
import 'features/04_egp_levels/presentation/screens/students_egp_levels_screen.dart';
import 'features/06_unit_activities/presentation/screens/unit_activities_screen.dart';

import 'package:flutter/services.dart';

// ✅ SEGURIDAD: Importar servicios de seguridad
import 'core/config/app_config.dart';
import 'core/security/secure_storage_service.dart';
import 'core/utils/secure_logger.dart';

const platform = MethodChannel('refresh_rate');

Future<void> setRefreshRate(double rate) async {
  try {
    await platform.invokeMethod('setRefreshRate', {'rate': rate});
  } catch (e) {
    SecureLogger.error('Failed to set refresh rate', error: e);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ SEGURIDAD: Inicializar servicios de seguridad antes que todo
  try {
    // Determinar si estamos en modo desarrollo
    const isDevelopment = kDebugMode;
    
    SecureLogger.info('Initializing MiR Online app (${isDevelopment ? 'Development' : 'Production'} mode)');
    
    // Inicializar configuración segura
    await AppConfig.initialize(isDevelopment: isDevelopment);
    SecureLogger.info('App configuration initialized');
    
    // Inicializar almacenamiento seguro
    await SecureStorageService.initialize();
    SecureLogger.info('Secure storage initialized');
    
    // Validar configuración crítica
    AppConfig.validateConfiguration();
    SecureLogger.info('Configuration validation passed');
    
  } catch (e) {
    SecureLogger.error('Failed to initialize security services', error: e);
    
    // En caso de error crítico, mostrar mensaje de error
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Security Initialization Failed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'The app could not initialize security services.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Exit App'),
              ),
            ],
          ),
        ),
      ),
    ));
    return;
  }
  
  try {
    await setRefreshRate(60.0);
  } catch (e) {
    SecureLogger.warning('Could not set refresh rate', tag: 'MAIN');
  }
  
  SecureLogger.info('Starting MiR Online app');
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
    if (Platform.isIOS) {
      return CupertinoApp(
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        title: 'mironline',
        theme: const CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue,
        ),
        routes: {
          '/': (context) => AnimatedSplashScreen(goHome: goHome),
          '/welcome': (context) => WelcomeTourPage(),
          '/login': (context) => LoginPage(),
          '/home': (context) => StudentTodayScreen(),
          '/egp-levels': (context) => StudentsEgpLevelsScreen(),
          '/unit-activities': (context) => UnitActivitiesScreen(),
        },
      );
    } else {
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
          '/unit-activities': (context) => UnitActivitiesScreen(),
        },
      );
    }
  }
}
