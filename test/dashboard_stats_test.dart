import 'package:flutter_test/flutter_test.dart';
import 'package:qr_packing_app/core/constants/firestore_constants.dart';
import 'package:qr_packing_app/core/utils/dashboard_stats.dart';
import 'package:qr_packing_app/models/box_model.dart';
import 'package:qr_packing_app/models/item_model.dart';

BoxModel _box(
    String id, {
      String status = PackingStatus.unpacked,
      DateTime? createdAt,
      DateTime? lastScannedAt,
    }) {
  return BoxModel(
    id: id,
    userId: 'user1',
    boxName: 'Box $id',
    category: 'Kitchen',
    location: 'Room',
    description: '',
    status: status,
    createdAt: createdAt,
    lastScannedAt: lastScannedAt,
  );
}

ItemModel _item(String id, String boxId) {
  return ItemModel(
    id: id,
    boxId: boxId,
    userId: 'user1',
    itemName: 'Item $id',
    description: '',
    quantity: 1,
    status: PackingStatus.unpacked,
  );
}

void main() {
  test('counts boxes, items, packed and unpacked', () {
    final boxes = [
      _box('a', status: PackingStatus.packed),
      _box('b', status: PackingStatus.packed),
      _box('c'),
    ];
    final items = [_item('1', 'a'), _item('2', 'a'), _item('3', 'c')];

    final stats = DashboardStats.from(boxes: boxes, items: items);

    expect(stats.totalBoxes, 3);
    expect(stats.totalItems, 3);
    expect(stats.packedBoxes, 2);
    expect(stats.unpackedBoxes, 1);
  });

  test('recently added: newest first, at most 3', () {
    final boxes = [
      _box('old', createdAt: DateTime(2026, 1, 1)),
      _box('mid', createdAt: DateTime(2026, 2, 1)),
      _box('new', createdAt: DateTime(2026, 3, 1)),
      _box('newest', createdAt: DateTime(2026, 4, 1)),
    ];

    final stats = DashboardStats.from(boxes: boxes, items: []);

    expect(
      stats.recentlyAdded.map((b) => b.id).toList(),
      ['newest', 'new', 'mid'],
    );
  });

  test('recently scanned: only scanned boxes, latest scan first', () {
    final boxes = [
      _box('never'),
      _box('first', lastScannedAt: DateTime(2026, 5, 1)),
      _box('second', lastScannedAt: DateTime(2026, 6, 1)),
    ];

    final stats = DashboardStats.from(boxes: boxes, items: []);

    expect(
      stats.recentlyScanned.map((b) => b.id).toList(),
      ['second', 'first'],
    );
  });

  test('an empty account gives zeros and empty lists', () {
    final stats = DashboardStats.from(boxes: [], items: []);

    expect(stats.totalBoxes, 0);
    expect(stats.totalItems, 0);
    expect(stats.recentlyAdded, isEmpty);
    expect(stats.recentlyScanned, isEmpty);
  });
}