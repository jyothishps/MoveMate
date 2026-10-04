import 'package:firebase_core/firebase_core.dart';

/// An error with a message that is safe to show to the user.
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  /// Converts a technical Firebase error into a friendly message.
  factory DatabaseException.fromFirebase(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return DatabaseException('You do not have permission to do that.');
      case 'unavailable':
      case 'deadline-exceeded':
        return DatabaseException(
          'Cannot reach the server. Check your internet connection.',
        );
      case 'not-found':
        return DatabaseException('This item no longer exists.');
      default:
        return DatabaseException('Something went wrong. Please try again.');
    }
  }

  @override
  String toString() => message;
}