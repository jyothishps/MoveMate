import 'package:flutter_test/flutter_test.dart';
import 'package:qr_packing_app/core/constants/app_constants.dart';
import 'package:qr_packing_app/main.dart';

void main() {
  testWidgets('App starts on the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const QrPackingApp());

    // The splash screen shows the app name.
    expect(find.text(AppConstants.appName), findsOneWidget);

    // Let the 2-second splash timer finish and the page change.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}