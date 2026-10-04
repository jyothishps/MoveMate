class FirestoreConstants {
  static const String usersCollection = 'users';
  static const String boxesCollection = 'boxes';
  static const String itemsCollection = 'items';

  /// Text placed before the box ID inside every QR code.
  static const String qrPrefix = 'movemate:';
}

class PackingStatus {
  static const String packed = 'packed';
  static const String unpacked = 'unpacked';
}