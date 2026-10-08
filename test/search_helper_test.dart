import 'package:flutter_test/flutter_test.dart';
import 'package:qr_packing_app/core/constants/firestore_constants.dart';
import 'package:qr_packing_app/core/utils/search_helper.dart';
import 'package:qr_packing_app/models/box_model.dart';
import 'package:qr_packing_app/models/item_model.dart';

BoxModel _box(String id, String name, String category, String location) {
  return BoxModel(
    id: id,
    userId: 'user1',
    boxName: name,
    category: category,
    location: location,
    description: '',
    status: PackingStatus.unpacked,
  );
}

ItemModel _item(String id, String boxId, String name) {
  return ItemModel(
    id: id,
    boxId: boxId,
    userId: 'user1',
    itemName: name,
    description: '',
    quantity: 1,
    status: PackingStatus.unpacked,
  );
}

void main() {
  final boxes = [
    _box('b1', 'Kitchen essentials', 'Kitchen', 'Storage Room'),
    _box('b2', 'Winter clothes', 'Clothing', 'Bedroom'),
    _box('b3', 'Old books', 'Books', 'Storage Room'),
  ];
  final items = [
    _item('i1', 'b1', 'Plates'),
    _item('i2', 'b2', 'Winter Jacket'),
    _item('i3', 'b2', 'Jacket liner'),
    _item('i4', 'b3', 'Atlas'),
  ];

  test('empty query returns nothing', () {
    final results =
    SearchHelper.search(query: '   ', boxes: boxes, items: items);
    expect(results.isEmpty, true);
  });

  test('finds an item and tells which box it is in', () {
    final results =
    SearchHelper.search(query: 'plates', boxes: boxes, items: items);
    expect(results.items.length, 1);
    expect(results.items.first.item.itemName, 'Plates');
    expect(results.items.first.box.id, 'b1');
  });

  test('is not case sensitive', () {
    final results =
    SearchHelper.search(query: 'PLATES', boxes: boxes, items: items);
    expect(results.items.length, 1);
  });

  test('all words must match, in any order', () {
    final a = SearchHelper.search(
        query: 'winter jacket', boxes: boxes, items: items);
    final b = SearchHelper.search(
        query: 'jacket winter', boxes: boxes, items: items);
    expect(a.items.length, 1);
    expect(b.items.length, 1);
  });

  test('names that start with the text come first', () {
    final results =
    SearchHelper.search(query: 'jacket', boxes: boxes, items: items);
    expect(results.items.map((r) => r.item.itemName).toList(),
        ['Jacket liner', 'Winter Jacket']);
  });

  test('finds boxes by category and by location', () {
    final byCategory =
    SearchHelper.search(query: 'clothing', boxes: boxes, items: items);
    expect(byCategory.boxes.map((b) => b.id).toList(), ['b2']);

    final byLocation = SearchHelper.search(
        query: 'storage room', boxes: boxes, items: items);
    expect(byLocation.boxes.map((b) => b.id).toList(), ['b1', 'b3']);
  });

  test('no match gives empty results', () {
    final results =
    SearchHelper.search(query: 'xyz', boxes: boxes, items: items);
    expect(results.isEmpty, true);
  });
}