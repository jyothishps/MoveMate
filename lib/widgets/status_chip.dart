import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final bool isPacked;

  const StatusChip({
    super.key,
    required this.label,
    required this.isPacked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isPacked ? AppColors.successLight : AppColors.warningLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isPacked ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }
}