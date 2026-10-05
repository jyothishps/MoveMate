import 'package:flutter_test/flutter_test.dart';
import 'package:qr_packing_app/core/utils/qr_parser.dart';

void main() {
  group('QrParser.parseBoxId', () {
    test('returns the ID from a valid MoveMate QR text', () {
      expect(
        QrParser.parseBoxId('movemate:Xy12AbC3dEf4GhI5jKl6'),
        'Xy12AbC3dEf4GhI5jKl6',
      );
      expect(
        QrParser.parseBoxId('  movemate:Xy12AbC3dEf4GhI5jKl6  '),
        'Xy12AbC3dEf4GhI5jKl6',
      );
    });

    test('rejects anything that is not a MoveMate box code', () {
      expect(QrParser.parseBoxId(null), isNull);
      expect(QrParser.parseBoxId(''), isNull);
      expect(QrParser.parseBoxId('hello'), isNull);
      expect(QrParser.parseBoxId('https://example.com'), isNull);
      expect(QrParser.parseBoxId('movemate:'), isNull);
      expect(QrParser.parseBoxId('movemate:ab'), isNull);
      expect(QrParser.parseBoxId('MOVEMATE:Xy12AbC3dEf4GhI5jKl6'), isNull);
    });

    test('rejects IDs that try to point at other database paths', () {
      expect(QrParser.parseBoxId('movemate:../users/abc123'), isNull);
      expect(QrParser.parseBoxId('movemate:abc/def/ghi'), isNull);
    });
  });
}