import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/theme/app_colors.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/models/box_model.dart';
import 'package:qr_packing_app/screens/box/create_box_screen.dart';
import 'package:qr_packing_app/services/box_service.dart';
import 'package:qr_packing_app/services/database_exception.dart';
import 'package:qr_packing_app/widgets/empty_state.dart';
import 'package:qr_packing_app/widgets/error_banner.dart';
import 'package:qr_packing_app/widgets/status_chip.dart';

class BoxDetailsScreen extends StatefulWidget {
  final String boxId;

  const BoxDetailsScreen({super.key, required this.boxId});

  @override
  State<BoxDetailsScreen> createState() => _BoxDetailsScreenState();
}

class _BoxDetailsScreenState extends State<BoxDetailsScreen> {
  final _boxService = BoxService();
  late final Stream<BoxModel?> _boxStream;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _boxStream = _boxService.streamBox(widget.boxId);
  }

  Future<void> _confirmDelete(BoxModel box) async {
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
        if (box == null) {
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
                onPressed: _isDeleting ? null : () => _confirmDelete(box),
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
              const SizedBox(height: 24),
              const Text('Items', style: AppTextStyles.subheading),
              const SizedBox(height: 12),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.list_alt, color: AppColors.textSecondary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Items inside this box will appear here (Phase 7).',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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