import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_packing_app/core/constants/firestore_constants.dart';
import 'package:qr_packing_app/models/box_model.dart';
import 'package:qr_packing_app/services/database_exception.dart';

class BoxService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _boxes =>
      _db.collection(FirestoreConstants.boxesCollection);

  CollectionReference<Map<String, dynamic>> get _items =>
      _db.collection(FirestoreConstants.itemsCollection);

  /// Live list of the given user's boxes, newest first.
  Stream<List<BoxModel>> streamUserBoxes(String userId) {
    return _boxes.where('userId', isEqualTo: userId).snapshots().map((snapshot) {
      final boxes = snapshot.docs.map(BoxModel.fromDoc).toList();
      boxes.sort(_newestFirst);
      return boxes;
    });
  }

  /// Live version of a single box. Emits null if the box does not exist.
  Stream<BoxModel?> streamBox(String boxId) {
    return _boxes.doc(boxId).snapshots().map(
          (doc) => doc.exists ? BoxModel.fromDoc(doc) : null,
    );
  }

  /// Finds one box by ID, but only if it belongs to [userId].
  /// Returns null if it does not exist, was deleted, or is not yours.
  Future<BoxModel?> getUserBox(String boxId, String userId) async {
    try {
      final snapshot = await _boxes
          .where('userId', isEqualTo: userId)
          .where(FieldPath.documentId, isEqualTo: boxId)
          .limit(1)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 15));

      if (snapshot.docs.isEmpty) return null;
      return BoxModel.fromDoc(snapshot.docs.first);
    } on TimeoutException {
      throw DatabaseException(
        'Cannot reach the server. Check your internet connection.',
      );
    } on FirebaseException catch (e) {
      // Once strict rules are added, someone else's box is "permission denied".
      // We show that exactly like "not found".
      if (e.code == 'permission-denied') return null;
      throw DatabaseException.fromFirebase(e);
    }
  }

  /// Saves a new box and returns its generated ID.
  Future<String> createBox(BoxModel box) async {
    try {
      final doc = _boxes.doc(); // creates a new unique ID
      await doc.set(box.toCreateMap());
      return doc.id;
    } on FirebaseException catch (e) {
      throw DatabaseException.fromFirebase(e);
    }
  }

  /// Saves changes to an existing box.
  Future<void> updateBox(BoxModel box) async {
    try {
      await _boxes.doc(box.id).update(box.toUpdateMap());
    } on FirebaseException catch (e) {
      throw DatabaseException.fromFirebase(e);
    }
  }

  /// Deletes a box together with all items inside it.
  Future<void> deleteBox(String boxId, String userId) async {
    try {
      final itemsInBox = await _items
          .where('userId', isEqualTo: userId)
          .where('boxId', isEqualTo: boxId)
          .get();

      // A batch makes all deletes succeed or fail together.
      final batch = _db.batch();
      for (final doc in itemsInBox.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_boxes.doc(boxId));
      await batch.commit();
    } on FirebaseException catch (e) {
      throw DatabaseException.fromFirebase(e);
    }
  }

  // Boxes whose time is not yet known (just created) count as newest.
  static int _newestFirst(BoxModel a, BoxModel b) {
    final aTime = a.createdAt ?? DateTime.now();
    final bTime = b.createdAt ?? DateTime.now();
    return bTime.compareTo(aTime);
  }
}