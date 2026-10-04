import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:qr_packing_app/core/constants/firestore_constants.dart';

/// A simple error that carries a message safe to show to the user.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  // A getter, so Firebase is only touched when we actually use it.
  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Emits the current user (or null) now and whenever login state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// The logged-in user, or null if nobody is logged in.
  User? get currentUser => _auth.currentUser;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());
        await user.reload();
        await _saveUserProfile(user.uid, name.trim(), email.trim());
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Saves users/{uid} in Firestore. The app does not depend on this
  /// document, so a failure here must not block registration.
  Future<void> _saveUserProfile(String uid, String name, String email) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Could not save user profile: $e');
    }
  }

  /// Turns Firebase's technical error codes into friendly messages.
  static String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}