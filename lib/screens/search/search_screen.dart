import 'package:flutter/material.dart';
import 'package:qr_packing_app/widgets/app_text_field.dart';
import 'package:qr_packing_app/widgets/empty_state.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: AppTextField(
              label: 'Search items, boxes, categories...',
              icon: Icons.search,
            ),
          ),
          Expanded(
            child: EmptyState(
              icon: Icons.search,
              title: 'Search your items',
              message: 'Type an item name to find which box it is in.',
            ),
          ),
        ],
      ),
    );
  }
}