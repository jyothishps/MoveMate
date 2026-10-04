import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/constants/app_routes.dart';
import 'package:qr_packing_app/core/theme/app_colors.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/services/auth_service.dart';
import 'package:qr_packing_app/widgets/primary_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final name = (user?.displayName ?? '').trim();
    final email = user?.email ?? '';

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
          Center(
            child: Text(
              name.isEmpty ? 'MoveMate user' : name,
              style: AppTextStyles.subheading,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(email, style: AppTextStyles.bodySecondary),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Logout',
            icon: Icons.logout,
            onPressed: () => _logout(context),
          ),
        ],
      ),
    );
  }
}