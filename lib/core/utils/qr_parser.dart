import 'package:qr_packing_app/core/constants/firestore_constants.dart';

class QrParser {
  // Firestore IDs are letters and digits. Anything else is rejected,
  // so tricks like "../users/abc" can never reach the database.
  static final RegExp _idPattern = RegExp(r'^[A-Za-z0-9_-]{6,64}$');

  /// Returns the box ID inside a MoveMate QR text, or null if invalid.
  static String? parseBoxId(String? raw) {
    if (raw == null) return null;

    final text = raw.trim();
    if (!text.startsWith(FirestoreConstants.qrPrefix)) return null;

    final id = text.substring(FirestoreConstants.qrPrefix.length);
    return _idPattern.hasMatch(id) ? id : null;
  }
}