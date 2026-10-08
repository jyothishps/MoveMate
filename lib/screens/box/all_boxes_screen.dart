import 'package:flutter/material.dart';
import 'package:qr_packing_app/models/box_model.dart';
import 'package:qr_packing_app/models/item_model.dart';
import 'package:qr_packing_app/screens/box/box_details_screen.dart';
import 'package:qr_packing_app/services/auth_service.dart';
import 'package:qr_packing_app/services/box_service.dart';
import 'package:qr_packing_app/services/item_service.dart';
import 'package:qr_packing_app/widgets/box_card.dart';
import 'package:qr_packing_app/widgets/empty_state.dart';
import 'package:qr_packing_app/widgets/error_banner.dart';

class AllBoxesScreen extends StatefulWidget {
  const AllBoxesScreen({super.key});

  @override
  State<AllBoxesScreen> createState() => _AllBoxesScreenState();
}

class _AllBoxesScreenState extends State<AllBoxesScreen> {
  late final Stream<List<BoxModel>> _boxesStream;
  late final Stream<List<ItemModel>> _itemsStream;

  @override
  void initState() {
    super.initState();
    final userId = AuthService().currentUser?.uid ?? '';
    _boxesStream = BoxService().streamUserBoxes(userId);
    _itemsStream = ItemService().streamUserItems(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Boxes')),
      body: StreamBuilder<List<BoxModel>>(
        stream: _boxesStream,
        builder: (context, boxSnapshot) {
          if (boxSnapshot.hasError) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: ErrorBanner(
                message: 'Could not load your boxes. Check your connection.',
              ),
            );
          }

          if (!boxSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final boxes = boxSnapshot.data!;
          if (boxes.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No boxes yet',
              message: 'Create your first box from the Home tab.',
            );
          }

          return StreamBuilder<List<ItemModel>>(
            stream: _itemsStream,
            builder: (context, itemSnapshot) {
              final counts = <String, int>{};
              for (final item in itemSnapshot.data ?? <ItemModel>[]) {
                counts[item.boxId] = (counts[item.boxId] ?? 0) + 1;
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  for (final box in boxes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BoxCard(
                        box: box,
                        itemCount: counts[box.id] ?? 0,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BoxDetailsScreen(boxId: box.id),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}