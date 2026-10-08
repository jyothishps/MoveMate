import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/constants/app_constants.dart';
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
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderLight),
            ),
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.list_alt, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'No items yet. Tap "Add item" to add the first one.',
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
              ],
            ),
          );
        }

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
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.borderLight,
                  ),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Hero Info Card with Category Accent
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Room Accent Bar
                    Container(
                      height: 5,
                      width: double.infinity,
                      color: AppColors.categoryColor(box.category),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'BOX ${box.shortCode}',
                                  style: AppTextStyles.shortCode.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              StatusChip(
                                label: box.isPacked ? 'Packed' : 'Unpacked',
                                isPacked: box.isPacked,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(box.boxName, style: AppTextStyles.heading),
                          const SizedBox(height: 16),
                          // Horizontal Category & Location Badges
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.categoryLightColor(box.category),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.categoryColor(box.category)
                                        .withValues(alpha: 0.18),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      AppConstants.categoryIcon(box.category),
                                      size: 16,
                                      color: AppColors.categoryColor(box.category),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      box.category,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.categoryColor(box.category),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.place_outlined,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      box.location,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (box.description.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.notes_outlined,
                                    size: 16,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      box.description,
                                      style: AppTextStyles.bodySecondary.copyWith(
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Interactive QR Code Banner Action
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BoxQrScreen(box: box)),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.qr_code_2,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Show Box QR Code',
                                  style: AppTextStyles.subheading.copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'View or save printable moving label',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Items Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Items', style: AppTextStyles.subheading),
                  TextButton.icon(
                    onPressed: _isDeleting ? null : () => _openItemForm(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add item'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _buildItems(),
              const SizedBox(height: 24),

              // Box History
              const Text('Box history', style: AppTextStyles.subheading),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                padding: const EdgeInsets.all(18),
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
              const SizedBox(height: 20),
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