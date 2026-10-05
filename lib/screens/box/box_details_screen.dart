import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/constants/firestore_constants.dart';
import 'package:qr_packing_app/core/theme/app_colors.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/models/box_model.dart';
import 'package:qr_packing_app/models/item_model.dart';
import 'package:qr_packing_app/screens/box/create_box_screen.dart';
import 'package:qr_packing_app/screens/item/item_form_screen.dart';
import 'package:qr_packing_app/screens/qr/box_qr_screen.dart';
import 'package:qr_packing_app/services/auth_service.dart';
import 'package:qr_packing_app/services/box_service.dart';
import 'package:qr_packing_app/services/database_exception.dart';
import 'package:qr_packing_app/services/item_service.dart';
import 'package:qr_packing_app/widgets/empty_state.dart';
import 'package:qr_packing_app/widgets/error_banner.dart';
import 'package:qr_packing_app/widgets/item_tile.dart';
import 'package:qr_packing_app/widgets/status_chip.dart';

class BoxDetailsScreen extends StatefulWidget {
  final String boxId;

  const BoxDetailsScreen({super.key, required this.boxId});

  @override
  State<BoxDetailsScreen> createState() => _BoxDetailsScreenState();
}

class _BoxDetailsScreenState extends State<BoxDetailsScreen> {
  final _boxService = BoxService();
  final _itemService = ItemService();
  late final Stream<BoxModel?> _boxStream;
  late final Stream<List<ItemModel>> _itemsStream;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _boxStream = _boxService.streamBox(widget.boxId);
    _itemsStream = _itemService.streamBoxItems(
      userId: AuthService().currentUser?.uid ?? '',
      boxId: widget.boxId,
    );
  }

  // ---------- Box actions ----------

  Future<void> _confirmDeleteBox(BoxModel box) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete box?'),
        content: Text(
          '"${box.boxName}" and all items inside it will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isDeleting = true);

    try {
      await _boxService.deleteBox(box.id, box.userId);
      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Box deleted')));
    } on DatabaseException catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    }
  }

  // ---------- Item actions ----------

  void _openItemForm({ItemModel? item}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemFormScreen(boxId: widget.boxId, item: item),
      ),
    );
  }

  Future<void> _toggleItem(ItemModel item) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _itemService.setStatus(
        item.id,
        item.isPacked ? PackingStatus.unpacked : PackingStatus.packed,
      );
    } on DatabaseException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _confirmDeleteItem(ItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('"${item.itemName}" will be removed from this box.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await _itemService.deleteItem(item.id);
      messenger.showSnackBar(const SnackBar(content: Text('Item deleted')));
    } on DatabaseException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  // ---------- Items list ----------

  Widget _buildItems() {
    return StreamBuilder<List<ItemModel>>(
      stream: _itemsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const ErrorBanner(
            message: 'Could not load items. Check your connection.',
          );
        }

        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final items = snapshot.data!;
        if (items.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.list_alt, color: AppColors.textSecondary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No items yet. Tap "Add item" to add the first one.',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                ItemTile(
                  item: items[i],
                  onToggle: () => _toggleItem(items[i]),
                  onEdit: () => _openItemForm(item: items[i]),
                  onDelete: () => _confirmDeleteItem(items[i]),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ---------- Screen ----------

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BoxModel?>(
      stream: _boxStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Box Details')),
            body: const Padding(
              padding: EdgeInsets.all(20),
              child: ErrorBanner(
                message: 'Could not load this box. Check your connection.',
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Box Details')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final box = snapshot.data;
        // Never show a box that belongs to another account.
        if (box == null || box.userId != AuthService().currentUser?.uid) {
          return Scaffold(
            appBar: AppBar(title: const Text('Box Details')),
            body: const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Box not found',
              message: 'This box may have been deleted.',
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Box ${box.shortCode}'),
            actions: [
              IconButton(
                tooltip: 'Edit box',
                icon: const Icon(Icons.edit_outlined),
                onPressed: _isDeleting
                    ? null
                    : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateBoxScreen(box: box),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Delete box',
                icon: const Icon(Icons.delete_outline),
                onPressed: _isDeleting ? null : () => _confirmDeleteBox(box),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'BOX ${box.shortCode}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          StatusChip(
                            label: box.isPacked ? 'Packed' : 'Unpacked',
                            isPacked: box.isPacked,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(box.boxName, style: AppTextStyles.heading),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.category_outlined,
                        label: 'Category',
                        value: box.category,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.place_outlined,
                        label: 'Location',
                        value: box.location,
                      ),
                      if (box.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.notes_outlined,
                          label: 'Description',
                          value: box.description,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BoxQrScreen(box: box)),
                ),
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Show QR Code'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Items', style: AppTextStyles.subheading),
                  TextButton.icon(
                    onPressed: _isDeleting ? null : () => _openItemForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add item'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _buildItems(),
              const SizedBox(height: 24),
              const Text('Box history', style: AppTextStyles.subheading),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.add_circle_outline,
                        label: 'Created',
                        value: _formatDate(box.createdAt),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.update,
                        label: 'Last updated',
                        value: _formatDate(box.updatedAt),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.body),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return 'Just now';
  final d = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}