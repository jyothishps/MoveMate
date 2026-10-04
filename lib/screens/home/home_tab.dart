import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/constants/app_constants.dart';
import 'package:qr_packing_app/core/constants/app_routes.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/models/box_model.dart';
import 'package:qr_packing_app/models/item_model.dart';
import 'package:qr_packing_app/screens/box/box_details_screen.dart';
import 'package:qr_packing_app/services/auth_service.dart';
import 'package:qr_packing_app/services/box_service.dart';
import 'package:qr_packing_app/services/item_service.dart';
import 'package:qr_packing_app/widgets/box_card.dart';
import 'package:qr_packing_app/widgets/empty_state.dart';
import 'package:qr_packing_app/widgets/error_banner.dart';
import 'package:qr_packing_app/widgets/primary_button.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final Stream<List<BoxModel>> _boxesStream;
  late final Stream<List<ItemModel>> _itemsStream;

  @override
  void initState() {
    super.initState();
    // Only this user's data is requested.
    final userId = AuthService().currentUser?.uid ?? '';
    _boxesStream = BoxService().streamUserBoxes(userId);
    _itemsStream = ItemService().streamUserItems(userId);
  }

  Widget _buildBoxList() {
    return StreamBuilder<List<BoxModel>>(
      stream: _boxesStream,
      builder: (context, boxSnapshot) {
        if (boxSnapshot.hasError) {
          return const ErrorBanner(
            message: 'Could not load your boxes. Check your connection.',
          );
        }

        if (!boxSnapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final boxes = boxSnapshot.data!;
        if (boxes.isEmpty) {
          return const EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No boxes yet',
            message: 'Tap "Create Box" to add your first box.',
          );
        }

        return StreamBuilder<List<ItemModel>>(
          stream: _itemsStream,
          builder: (context, itemSnapshot) {
            // Count how many items each box contains.
            final counts = <String, int>{};
            for (final item in itemSnapshot.data ?? <ItemModel>[]) {
              counts[item.boxId] = (counts[item.boxId] ?? 0) + 1;
            }

            return Column(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = AuthService().currentUser?.displayName?.trim() ?? '';
    final firstName = displayName.split(' ').first;
    final welcomeText = firstName.isEmpty ? 'Welcome!' : 'Welcome, $firstName!';

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(welcomeText, style: AppTextStyles.heading),
          const SizedBox(height: 4),
          const Text(
            'Manage your boxes and find your things fast.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Create Box',
            icon: Icons.add,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.createBox),
          ),
          const SizedBox(height: 28),
          const Text('Your Boxes', style: AppTextStyles.subheading),
          const SizedBox(height: 12),
          _buildBoxList(),
        ],
      ),
    );
  }
}