import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_packing_app/core/theme/app_theme.dart';
import 'package:qr_packing_app/screens/auth/login_screen.dart';

void main() {
  testWidgets('Login shows validation errors for empty fields',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light, home: const LoginScreen()),
        );

        expect(find.text('Welcome back'), findsOneWidget);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pump();

        expect(find.text('Please enter your email'), findsOneWidget);
        expect(find.text('Please enter your password'), findsOneWidget);
      });
}