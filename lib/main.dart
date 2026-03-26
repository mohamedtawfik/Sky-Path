import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/splash_screen.dart';
import 'services/analytics_service.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Lock orientation to portrait
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Full screen immersive mode
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0D1B2A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Initialize Firebase
    await Firebase.initializeApp();

    // Set up Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Log app open
    AnalyticsService().logAppOpen();

    final gameProvider = GameProvider();

    runApp(
      ChangeNotifierProvider.value(
        value: gameProvider,
        child: SkyPathApp(gameProvider: gameProvider),
      ),
    );
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

class SkyPathApp extends StatelessWidget {
  final GameProvider gameProvider;

  const SkyPathApp({super.key, required this.gameProvider});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sky Path',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [AnalyticsService().observer],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00F5D4),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: SplashScreen(gameProvider: gameProvider),
    );
  }
}
