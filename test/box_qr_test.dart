import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_packing_app/core/constants/firestore_constants.dart';
import 'package:qr_packing_app/core/theme/app_theme.dart';
import 'package:qr_packing_app/models/box_model.dart';
import 'package:qr_packing_app/screens/qr/box_qr_screen.dart';

void main() {
  testWidgets('QR screen shows name, ID and a QR code',
          (WidgetTester tester) async {
        const box = BoxModel(
          id: 'abc123xyz789',
          userId: 'user1',
          boxName: 'Kitchen essentials',
          category: 'Kitchen',
          location: 'Storage Room',
          description: '',
          status: PackingStatus.unpacked,
        );

        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light, home: const BoxQrScreen(box: box)),
        );

        expect(find.text('Kitchen essentials'), findsOneWidget);
        expect(find.text('BOX ABC123'), findsOneWidget);
        expect(find.text('abc123xyz789'), findsOneWidget);
        expect(find.byType(QrImageView), findsOneWidget);
      });
}