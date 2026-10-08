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
    // Only this user's data is requested.
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

    // How many items each box holds (shown on the box cards).
    final counts = <String, int>{};
    for (final item in items) {
      counts[item.boxId] = (counts[item.boxId] ?? 0) + 1;
    }

    final displayName = AuthService().currentUser?.displayName?.trim() ?? '';
    final firstName = displayName.split(' ').first;
    final welcomeText = firstName.isEmpty ? 'Welcome!' : 'Welcome, $firstName!';

    final actionStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(welcomeText, style: AppTextStyles.heading),
        const SizedBox(height: 4),
        const Text(
          'Manage your boxes and find your things fast.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 20),

        // Statistics
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.inventory_2_outlined,
                value: stats.totalBoxes,
                label: 'Boxes',
                color: AppColors.primary,
                backgroundColor: AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.list_alt,
                value: stats.totalItems,
                label: 'Items',
                color: AppColors.primary,
                backgroundColor: AppColors.primaryLight,
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
        const SizedBox(height: 20),

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
              child: OutlinedButton.icon(
                onPressed: widget.onScanTap,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR'),
                style: actionStyle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onSearchTap,
                icon: const Icon(Icons.search),
                label: const Text('Search Item'),
                style: actionStyle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Recently added boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recently added', style: AppTextStyles.subheading),
            if (boxes.isNotEmpty)
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllBoxesScreen()),
                ),
                child: const Text('See all'),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: _buildBody(),
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

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
        ),
        title: Text(
          box.boxName,
          style: AppTextStyles.body,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'BOX ${box.shortCode} • ${scannedAt == null ? '' : timeAgo(scannedAt)}',
          style: AppTextStyles.bodySecondary,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String message;

  const _EmptyHint({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(message, style: AppTextStyles.bodySecondary),
      ),
    );
  }
}