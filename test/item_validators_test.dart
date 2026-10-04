import 'package:flutter_test/flutter_test.dart';
import 'package:qr_packing_app/core/utils/validators.dart';

void main() {
  group('Validators.quantity', () {
    test('accepts whole numbers from 1 to 999', () {
      expect(Validators.quantity('1'), isNull);
      expect(Validators.quantity('12'), isNull);
      expect(Validators.quantity('999'), isNull);
    });

    test('rejects empty, zero, too large and non-numbers', () {
      expect(Validators.quantity(''), isNotNull);
      expect(Validators.quantity('0'), isNotNull);
      expect(Validators.quantity('1000'), isNotNull);
      expect(Validators.quantity('abc'), isNotNull);
      expect(Validators.quantity('2.5'), isNotNull);
    });
  });

  group('Validators.itemName', () {
    test('requires a name', () {
      expect(Validators.itemName(''), isNotNull);
      expect(Validators.itemName('   '), isNotNull);
      expect(Validators.itemName('Plates'), isNull);
    });
  });
}