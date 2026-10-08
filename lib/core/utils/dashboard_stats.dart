import 'package:qr_packing_app/models/box_model.dart';
import 'package:qr_packing_app/models/item_model.dart';

class DashboardStats {
  final int totalBoxes;
  final int totalItems;
  final int packedBoxes;
  final int unpackedBoxes;
  final List<BoxModel> recentlyAdded;
  final List<BoxModel> recentlyScanned;

  const DashboardStats({
    required this.totalBoxes,
    required this.totalItems,
    required this.packedBoxes,
    required this.unpackedBoxes,
    required this.recentlyAdded,
    required this.recentlyScanned,
  });

  factory DashboardStats.from({
    required List<BoxModel> boxes,
    required List<ItemModel> items,
    int recentCount = 3,
  }) {
    final packed = boxes.where((box) => box.isPacked).length;

    // Newest first. A box whose time is not yet known counts as newest.
    final added = [...boxes]..sort((a, b) {
      final aTime = a.createdAt ?? DateTime.now();
      final bTime = b.createdAt ?? DateTime.now();
      return bTime.compareTo(aTime);
    });

    // Only boxes that were scanned, most recent scan first.
    final scanned = boxes.where((box) => box.lastScannedAt != null).toList()
      ..sort((a, b) => b.lastScannedAt!.compareTo(a.lastScannedAt!));

    return DashboardStats(
      totalBoxes: boxes.length,
      totalItems: items.length,
      packedBoxes: packed,
      unpackedBoxes: boxes.length - packed,
      recentlyAdded: added.take(recentCount).toList(),
      recentlyScanned: scanned.take(recentCount).toList(),
    );
  }
}