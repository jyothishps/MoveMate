import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/theme/app_colors.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/models/item_model.dart';

class ItemTile extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final details = item.description.isEmpty
        ? 'Qty: ${item.quantity}'
        : 'Qty: ${item.quantity} • ${item.description}';

    return ListTile(
      onTap: onEdit,
      leading: IconButton(
        tooltip: item.isPacked ? 'Mark as unpacked' : 'Mark as packed',
        icon: Icon(
          item.isPacked ? Icons.check_circle : Icons.radio_button_unchecked,
          color: item.isPacked ? AppColors.success : AppColors.textSecondary,
        ),
        onPressed: onToggle,
      ),
      title: Text(
        item.itemName,
        style: AppTextStyles.body,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        details,
        style: AppTextStyles.bodySecondary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            onEdit();
          } else {
            onDelete();
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}