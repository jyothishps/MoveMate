import 'package:flutter_test/flutter_test.dart';
import 'package:qr_packing_app/core/utils/validators.dart';

void main() {
  group('Validators.newPassword', () {
    test('requires at least 8 characters', () {
      expect(Validators.newPassword(''), isNotNull);
      expect(Validators.newPassword('1234567'), isNotNull);
      expect(Validators.newPassword('12345678'), isNull);
    });
  });

  group('Validators.name', () {
    test('accepts 2 to 50 characters', () {
      expect(Validators.name('J'), isNotNull);
      expect(Validators.name('Jo'), isNull);
      expect(Validators.name('a' * 50), isNull);
      expect(Validators.name('a' * 51), isNotNull);
    });
  });

  group('Validators.email', () {
    test('rejects invalid and accepts valid emails', () {
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
      expect(Validators.email('a@b.co'), isNull);
    });
  });
}