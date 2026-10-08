import 'package:qr_packing_app/models/box_model.dart';
import 'package:qr_packing_app/models/item_model.dart';

/// One item that matched, together with the box it is in.
class ItemSearchResult {
  final ItemModel item;
  final BoxModel box;

  const ItemSearchResult({required this.item, required this.box});
}

class SearchResults {
  final List<BoxModel> boxes;
  final List<ItemSearchResult> items;

  const SearchResults({this.boxes = const [], this.items = const []});

  bool get isEmpty => boxes.isEmpty && items.isEmpty;
}

class SearchHelper {
  static SearchResults search({
    required String query,
    required List<BoxModel> boxes,
    required List<ItemModel> items,
  }) {
    final terms = _splitIntoTerms(query);
    if (terms.isEmpty) return const SearchResults();

    // Boxes match on name, category or location.
    final matchedBoxes = boxes
        .where(
          (box) => _matchesAll(
        terms,
        '${box.boxName} ${box.category} ${box.location}',
      ),
    )
        .toList()
      ..sort((a, b) => _compare(terms, a.boxName, b.boxName));

    // Items match on their name. Each result carries its box.
    final boxById = {for (final box in boxes) box.id: box};
    final matchedItems = <ItemSearchResult>[];
    for (final item in items) {
      final box = boxById[item.boxId];
      if (box == null) continue; // an item without a box cannot be opened
      if (_matchesAll(terms, item.itemName)) {
        matchedItems.add(ItemSearchResult(item: item, box: box));
      }
    }
    matchedItems.sort(
          (a, b) => _compare(terms, a.item.itemName, b.item.itemName),
    );

    return SearchResults(boxes: matchedBoxes, items: matchedItems);
  }

  static List<String> _splitIntoTerms(String query) {
    return query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList();
  }

  // True only if EVERY search word appears somewhere in the text.
  static bool _matchesAll(List<String> terms, String text) {
    final lower = text.toLowerCase();
    return terms.every((term) => lower.contains(term));
  }

  // Names starting with the search text come first, then A to Z.
  static int _compare(List<String> terms, String a, String b) {
    final aLower = a.toLowerCase();
    final bLower = b.toLowerCase();
    final aStarts = aLower.startsWith(terms.first) ? 0 : 1;
    final bStarts = bLower.startsWith(terms.first) ? 0 : 1;
    if (aStarts != bStarts) return aStarts.compareTo(bStarts);
    return aLower.compareTo(bLower);
  }
}