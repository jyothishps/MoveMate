import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_packing_app/core/theme/app_colors.dart';
import 'package:qr_packing_app/core/theme/app_theme.dart';
import 'package:qr_packing_app/widgets/primary_button.dart';
import 'package:qr_packing_app/widgets/stat_card.dart';

void main() {
  testWidgets('PrimaryButton copes with very large text',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(20),
                  child: PrimaryButton(label: 'Create Box', onPressed: () {}),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Create Box'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

  testWidgets('StatCard is announced as one phrase',
          (WidgetTester tester) async {
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: StatCard(
                icon: Icons.inventory_2_outlined,
                value: 12,
                label: 'Boxes',
                color: AppColors.primary,
                backgroundColor: AppColors.primaryLight,
              ),
            ),
          ),
        );

        expect(find.bySemanticsLabel('12 Boxes'), findsOneWidget);
        handle.dispose();
      });
}