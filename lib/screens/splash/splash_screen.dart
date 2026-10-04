import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/constants/app_constants.dart';
import 'package:qr_packing_app/core/constants/app_routes.dart';
import 'package:qr_packing_app/core/theme/app_colors.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToNextScreen();
  }

  Future<void> _goToNextScreen() async {
    // Show the splash screen for 2 seconds.
    await Future.delayed(const Duration(seconds: 2));

    // Ask Firebase if a user is already logged in on this phone.
    final user = await AuthService().authStateChanges.first;

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      user == null ? AppRoutes.login : AppRoutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: AppTextStyles.heading.copyWith(
                color: Colors.white,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.tagline,
              style: AppTextStyles.bodySecondary.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}