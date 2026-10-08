import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/constants/app_constants.dart';
import 'package:qr_packing_app/core/theme/app_colors.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/models/box_model.dart';
import 'package:qr_packing_app/widgets/status_chip.dart';

class BoxCard extends StatelessWidget {
  final BoxModel box;
  final int itemCount;
  final VoidCallback onTap;

  const BoxCard({
    super.key,
    required this.box,
    required this.itemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.categoryColor(box.category);
    final catBg = AppColors.categoryLightColor(box.category);
    final catIcon = AppConstants.categoryIcon(box.category);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: catColor.withValues(alpha: 0.08),
          highlightColor: catColor.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category-themed leading icon
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: catBg,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: catColor.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    catIcon,
                    color: catColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'BOX ${box.shortCode}',
                              style: AppTextStyles.shortCode.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        box.boxName,
                        style: AppTextStyles.subheading.copyWith(
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text.rich(
                        TextSpan(
                          text: box.category,
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 13,
                            color: catColor,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: ' • ${box.location}',
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusChip(
                  label: box.isPacked ? 'Packed' : 'Unpacked',
                  isPacked: box.isPacked,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}