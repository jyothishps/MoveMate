import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_packing_app/core/constants/firestore_constants.dart';
import 'package:qr_packing_app/core/theme/app_theme.dart';
import 'package:qr_packing_app/models/box_model.dart';
import 'package:qr_packing_app/widgets/box_card.dart';

void main() {
  testWidgets('BoxCard shows the box details', (WidgetTester tester) async {
    const box = BoxModel(
      id: 'abc123xyz789',
      userId: 'user1',
      boxName: 'Kitchen essentials',
      category: 'Kitchen',
      location: 'Storage Room',
      description: '',
      status: PackingStatus.packed,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: BoxCard(box: box, itemCount: 3, onTap: () {}),
        ),
      ),
    );

    expect(find.text('BOX ABC123'), findsOneWidget);
    expect(find.text('Kitchen essentials'), findsOneWidget);
    expect(find.text('Kitchen • Storage Room'), findsOneWidget);
    expect(find.text('3 items'), findsOneWidget);
    expect(find.text('Packed'), findsOneWidget);
  });
}