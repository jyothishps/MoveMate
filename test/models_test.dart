import 'package:flutter_test/flutter_test.dart';
import 'package:qr_packing_app/core/constants/firestore_constants.dart';
import 'package:qr_packing_app/models/box_model.dart';

void main() {
  test('BoxModel builds QR text, short code and packed flag', () {
    const box = BoxModel(
      id: 'abc123xyz789',
      userId: 'user1',
      boxName: 'Kitchen',
      category: 'Kitchen',
      location: 'Storage Room',
      description: '',
      status: PackingStatus.packed,
    );

    expect(box.qrData, 'movemate:abc123xyz789');
    expect(box.shortCode, 'ABC123');
    expect(box.isPacked, true);
  });
}