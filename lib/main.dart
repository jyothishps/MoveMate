import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/constants/app_constants.dart';
import 'package:qr_packing_app/core/constants/app_routes.dart';
import 'package:qr_packing_app/core/theme/app_colors.dart';
import 'package:qr_packing_app/core/theme/app_theme.dart';
import 'package:qr_packing_app/firebase_options.dart';
import 'package:qr_packing_app/screens/auth/login_screen.dart';
import 'package:qr_packing_app/screens/auth/register_screen.dart';
import 'package:qr_packing_app/screens/box/create_box_screen.dart';
import 'package:qr_packing_app/screens/home/home_screen.dart';
import 'package:qr_packing_app/screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      // On phones this changes nothing. On tablets or in landscape it keeps
      // the app at a comfortable reading width, centered on the screen.
      builder: (context, child) {
        return ColoredBox(
          color: AppColors.background,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: child,
            ),
          ),
        );
      },
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.createBox: (context) => const CreateBoxScreen(),
      },
    );
  }
}