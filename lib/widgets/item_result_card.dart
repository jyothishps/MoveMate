import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/theme/app_colors.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/models/box_model.dart';
import 'package:qr_packing_app/models/item_model.dart';

class ItemResultCard extends StatelessWidget {
  final ItemModel item;
  final BoxModel box;
  final VoidCallback onTap;

  const ItemResultCard({
    super.key,
    required this.item,
    required this.box,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                item.isPacked ? Icons.check_circle : Icons.radio_button_unchecked,
                color:
                item.isPacked ? AppColors.success : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: AppTextStyles.subheading,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _InfoLine(
                      label: 'Box',
                      value: '${box.boxName} (BOX ${box.shortCode})',
                    ),
                    _InfoLine(label: 'Category', value: box.category),
                    _InfoLine(label: 'Location', value: box.location),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('x${item.quantity}', style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        '$label: $value',
        style: AppTextStyles.bodySecondary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}