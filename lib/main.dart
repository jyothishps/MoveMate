import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/constants/app_constants.dart';
import 'package:qr_packing_app/core/constants/app_routes.dart';
import 'package:qr_packing_app/core/theme/app_theme.dart';
import 'package:qr_packing_app/firebase_options.dart';
import 'package:qr_packing_app/screens/auth/login_screen.dart';
import 'package:qr_packing_app/screens/auth/register_screen.dart';
import 'package:qr_packing_app/screens/box/box_details_screen.dart';
import 'package:qr_packing_app/screens/box/create_box_screen.dart';
import 'package:qr_packing_app/screens/home/home_screen.dart';
import 'package:qr_packing_app/screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Firebase connected: ${Firebase.app().options.projectId}');
  runApp(const QrPackingApp());
}

class QrPackingApp extends StatelessWidget {
  const QrPackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.createBox: (context) => const CreateBoxScreen(),
        AppRoutes.boxDetails: (context) => const BoxDetailsScreen(),
      },
    );
  }
}