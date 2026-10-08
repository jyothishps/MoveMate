import 'package:flutter_test/flutter_test.dart';
import 'package:qr_packing_app/core/utils/time_helper.dart';

void main() {
  final now = DateTime(2026, 10, 10, 12, 0, 0);

  test('shows friendly text for recent times', () {
    expect(timeAgo(now.subtract(const Duration(seconds: 20)), now: now),
        'Just now');
    expect(timeAgo(now.subtract(const Duration(minutes: 5)), now: now),
        '5 min ago');
    expect(timeAgo(now.subtract(const Duration(hours: 3)), now: now),
        '3 h ago');
    expect(timeAgo(now.subtract(const Duration(days: 2)), now: now),
        '2 d ago');
  });

  test('shows a date for older times', () {
    expect(timeAgo(DateTime(2026, 9, 1), now: now), '01/09/2026');
  });
}