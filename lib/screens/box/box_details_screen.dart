import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/theme/app_colors.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/widgets/status_chip.dart';

class BoxDetailsScreen extends StatelessWidget {
  const BoxDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Box Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Demo data. Real box data comes in Phase 6 and 7.
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('BOX B001', style: AppTextStyles.heading),
                      StatusChip(label: 'Packed', isPacked: true),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('Kitchen', style: AppTextStyles.subheading),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 6),
                      Text('Storage Room', style: AppTextStyles.bodySecondary),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Items', style: AppTextStyles.subheading),
          const SizedBox(height: 12),
          const Card(
            child: Column(
              children: [
                _ItemTile(name: 'Plates', quantity: 12, packed: true),
                Divider(height: 1),
                _ItemTile(name: 'Glasses', quantity: 6, packed: true),
                Divider(height: 1),
                _ItemTile(name: 'Mixer', quantity: 1, packed: true),
                Divider(height: 1),
                _ItemTile(name: 'Pressure cooker', quantity: 1, packed: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String name;
  final int quantity;
  final bool packed;

  const _ItemTile({
    required this.name,
    required this.quantity,
    required this.packed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        packed ? Icons.check_circle : Icons.radio_button_unchecked,
        color: packed ? AppColors.success : AppColors.textSecondary,
      ),
      title: Text(name, style: AppTextStyles.body),
      trailing: Text('x$quantity', style: AppTextStyles.bodySecondary),
    );
  }
}