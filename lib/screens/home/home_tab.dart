import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/constants/app_constants.dart';
import 'package:qr_packing_app/core/constants/app_routes.dart';
import 'package:qr_packing_app/core/theme/app_colors.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/widgets/primary_button.dart';
import 'package:qr_packing_app/widgets/status_chip.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Welcome!', style: AppTextStyles.heading),
          const SizedBox(height: 4),
          const Text(
            'Manage your boxes and find your things fast.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Create Box',
            icon: Icons.add,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.createBox),
          ),
          const SizedBox(height: 28),
          const Text('Your Boxes', style: AppTextStyles.subheading),
          const SizedBox(height: 12),
          // Demo card. Real boxes from the database come in Phase 6.
          _SampleBoxCard(
            onTap: () => Navigator.pushNamed(context, AppRoutes.boxDetails),
          ),
        ],
      ),
    );
  }
}

class _SampleBoxCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SampleBoxCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BOX B001', style: AppTextStyles.subheading),
                    SizedBox(height: 2),
                    Text(
                      'Kitchen • Storage Room',
                      style: AppTextStyles.bodySecondary,
                    ),
                    SizedBox(height: 4),
                    Text('12 Items', style: AppTextStyles.caption),
                  ],
                ),
              ),
              const StatusChip(label: 'Packed', isPacked: true),
            ],
          ),
        ),
      ),
    );
  }
}