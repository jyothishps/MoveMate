import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/constants/app_routes.dart';
import 'package:qr_packing_app/core/theme/app_colors.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/widgets/primary_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          const Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, size: 44, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          // Demo text. Real user details come in Phase 4.
          const Center(
            child: Text('Your Name', style: AppTextStyles.subheading),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'you@example.com',
              style: AppTextStyles.bodySecondary,
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Logout',
            icon: Icons.logout,
            // Placeholder: real logout comes in Phase 4.
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
                  (route) => false,
            ),
          ),
        ],
      ),
    );
  }
}