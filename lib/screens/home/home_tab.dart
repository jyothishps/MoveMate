import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/constants/app_constants.dart';
import 'package:qr_packing_app/core/constants/app_routes.dart';
import 'package:qr_packing_app/core/theme/app_colors.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/core/utils/dashboard_stats.dart';
import 'package:qr_packing_app/core/utils/time_helper.dart';
import 'package:qr_packing_app/models/box_model.dart';
import 'package:qr_packing_app/models/item_model.dart';
import 'package:qr_packing_app/screens/box/all_boxes_screen.dart';
import 'package:qr_packing_app/screens/box/box_details_screen.dart';
import 'package:qr_packing_app/services/auth_service.dart';
import 'package:qr_packing_app/services/box_service.dart';
import 'package:qr_packing_app/services/item_service.dart';
import 'package:qr_packing_app/widgets/box_card.dart';
import 'package:qr_packing_app/widgets/empty_state.dart';
import 'package:qr_packing_app/widgets/error_banner.dart';
import 'package:qr_packing_app/widgets/primary_button.dart';
import 'package:qr_packing_app/widgets/stat_card.dart';

class HomeTab extends StatefulWidget {
  /// Called when "Scan QR" is tapped (switches to the Scan tab).
  final VoidCallback onScanTap;

  /// Called when "Search Item" is tapped (switches to the Search tab).
  final VoidCallback onSearchTap;

  const HomeTab({
    super.key,
    required this.onScanTap,
    required this.onSearchTap,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  StreamSubscription<List<BoxModel>>? _boxesSubscription;
  StreamSubscription<List<ItemModel>>? _itemsSubscription;

  List<BoxModel>? _boxes;
  List<ItemModel>? _items;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    final userId = AuthService().currentUser?.uid ?? '';

    _boxesSubscription = BoxService().streamUserBoxes(userId).listen(
      (boxes) {
        if (mounted) setState(() => _boxes = boxes);
      },
      onError: (_) {
        if (mounted) setState(() => _hasError = true);
      },
    );

    _itemsSubscription = ItemService().streamUserItems(userId).listen(
      (items) {
        if (mounted) setState(() => _items = items);
      },
      onError: (_) {
        if (mounted) setState(() => _hasError = true);
      },
    );
  }

  @override
  void dispose() {
    _boxesSubscription?.cancel();
    _itemsSubscription?.cancel();
    super.dispose();
  }

  void _openBox(String boxId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BoxDetailsScreen(boxId: boxId)),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: ErrorBanner(
          message: 'Could not load your data. Check your connection.',
        ),
      );
    }

    final boxes = _boxes;
    final items = _items;
    if (boxes == null || items == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final stats = DashboardStats.from(boxes: boxes, items: items);

    final counts = <String, int>{};
    for (final item in items) {
      counts[item.boxId] = (counts[item.boxId] ?? 0) + 1;
    }

    final displayName = AuthService().currentUser?.displayName?.trim() ?? '';
    final firstName = displayName.split(' ').first;
    final welcomeText = firstName.isEmpty ? 'Welcome!' : 'Welcome, $firstName!';
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'M';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Header with Avatar Initials
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(welcomeText, style: AppTextStyles.display.copyWith(fontSize: 26)),
                  const SizedBox(height: 3),
                  const Text(
                    'Manage your boxes and find your things fast.',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Statistics Cards
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.inventory_2_outlined,
                value: stats.totalBoxes,
                label: 'Total Boxes',
                color: AppColors.primary,
                backgroundColor: AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.list_alt,
                value: stats.totalItems,
                label: 'Total Items',
                color: AppColors.catBedroom,
                backgroundColor: AppColors.catBedroomLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.check_circle_outline,
                value: stats.packedBoxes,
                label: 'Packed boxes',
                color: AppColors.success,
                backgroundColor: AppColors.successLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.pending_outlined,
                value: stats.unpackedBoxes,
                label: 'Unpacked boxes',
                color: AppColors.warning,
                backgroundColor: AppColors.warningLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Quick actions
        PrimaryButton(
          label: 'Create Box',
          icon: Icons.add,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.createBox),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SecondaryActionButton(
                label: 'Scan QR',
                icon: Icons.qr_code_scanner,
                onPressed: widget.onScanTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SecondaryActionButton(
                label: 'Search Item',
                icon: Icons.search,
                onPressed: widget.onSearchTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Recently added boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Recently added', style: AppTextStyles.subheading),
                if (boxes.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${boxes.length}',
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (boxes.isNotEmpty)
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllBoxesScreen()),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('See all'),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (stats.recentlyAdded.isEmpty)
          const EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No boxes yet',
            message: 'Tap "Create Box" to add your first box.',
          )
        else
          for (final box in stats.recentlyAdded)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BoxCard(
                box: box,
                itemCount: counts[box.id] ?? 0,
                onTap: () => _openBox(box.id),
              ),
            ),
        const SizedBox(height: 16),

        // Recently scanned boxes
        const Text('Recently scanned', style: AppTextStyles.subheading),
        const SizedBox(height: 12),
        if (stats.recentlyScanned.isEmpty)
          const _EmptyHint(
            message:
                'No boxes scanned yet. Scan a box QR code and it will show up here.',
          )
        else
          for (final box in stats.recentlyScanned)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RecentScanTile(box: box, onTap: () => _openBox(box.id)),
            ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: AppTextStyles.heading.copyWith(fontSize: 22),
        ),
      ),
      body: _buildBody(),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _SecondaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentScanTile extends StatelessWidget {
  final BoxModel box;
  final VoidCallback onTap;

  const _RecentScanTile({required this.box, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scannedAt = box.lastScannedAt;
    final catColor = AppColors.categoryColor(box.category);
    final catBg = AppColors.categoryLightColor(box.category);
    final catIcon = AppConstants.categoryIcon(box.category);

    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: catBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: catColor.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Icon(catIcon, color: catColor, size: 20),
        ),
        title: Text(
          box.boxName,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'BOX ${box.shortCode} • ${scannedAt == null ? '' : timeAgo(scannedAt)}',
          style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String message;

  const _EmptyHint({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(20),
      child: Text(
        message,
        style: AppTextStyles.bodySecondary.copyWith(height: 1.4),
      ),
    );
  }
}