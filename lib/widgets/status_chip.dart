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
    final fgColor = isPacked ? AppColors.success : AppColors.warning;
    final bgColor = isPacked ? AppColors.successLight : AppColors.warningLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: fgColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fgColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}