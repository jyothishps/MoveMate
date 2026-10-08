import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/core/utils/search_helper.dart';
import 'package:qr_packing_app/models/box_model.dart';
import 'package:qr_packing_app/models/item_model.dart';
import 'package:qr_packing_app/screens/box/box_details_screen.dart';
import 'package:qr_packing_app/services/auth_service.dart';
import 'package:qr_packing_app/services/box_service.dart';
import 'package:qr_packing_app/services/item_service.dart';
import 'package:qr_packing_app/widgets/box_card.dart';
import 'package:qr_packing_app/widgets/empty_state.dart';
import 'package:qr_packing_app/widgets/error_banner.dart';
import 'package:qr_packing_app/widgets/item_result_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  StreamSubscription<List<BoxModel>>? _boxesSubscription;
  StreamSubscription<List<ItemModel>>? _itemsSubscription;

  List<BoxModel>? _boxes;
  List<ItemModel>? _items;
  bool _hasError = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Load this user's boxes and items once, and keep them up to date.
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
    _searchController.dispose();
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

    final query = _query.trim();
    if (query.isEmpty) {
      return const EmptyState(
        icon: Icons.search,
        title: 'Search your items',
        message: 'Type an item name, box name, category or location.',
      );
    }

    final results = SearchHelper.search(
      query: query,
      boxes: boxes,
      items: items,
    );
    if (results.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'No results',
        message: 'Nothing matches "$query". Try a different word.',
      );
    }

    // How many items each box holds (shown on the box cards).
    final counts = <String, int>{};
    for (final item in items) {
      counts[item.boxId] = (counts[item.boxId] ?? 0) + 1;
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        if (results.items.isNotEmpty) ...[
          Text(
            'Items (${results.items.length})',
            style: AppTextStyles.subheading,
          ),
          const SizedBox(height: 12),
          for (final result in results.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ItemResultCard(
                item: result.item,
                box: result.box,
                onTap: () => _openBox(result.box.id),
              ),
            ),
          const SizedBox(height: 12),
        ],
        if (results.boxes.isNotEmpty) ...[
          Text(
            'Boxes (${results.boxes.length})',
            style: AppTextStyles.subheading,
          ),
          const SizedBox(height: 12),
          for (final box in results.boxes)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BoxCard(
                box: box,
                itemCount: counts[box.id] ?? 0,
                onTap: () => _openBox(box.id),
              ),
            ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search items, boxes, categories...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}