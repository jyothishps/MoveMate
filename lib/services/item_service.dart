import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_packing_app/core/constants/firestore_constants.dart';
import 'package:qr_packing_app/models/item_model.dart';
import 'package:qr_packing_app/services/database_exception.dart';

class ItemService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _items =>
      _db.collection(FirestoreConstants.itemsCollection);

  /// Live list of all items owned by the given user.
  Stream<List<ItemModel>> streamUserItems(String userId) {
    return _items
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ItemModel.fromDoc).toList());
  }

  /// Live list of the items inside one box, oldest first.
  Stream<List<ItemModel>> streamBoxItems({
    required String userId,
    required String boxId,
  }) {
    return _items
        .where('userId', isEqualTo: userId)
        .where('boxId', isEqualTo: boxId)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map(ItemModel.fromDoc).toList();
      items.sort(_oldestFirst);
      return items;
    });
  }

  Future<void> createItem(ItemModel item) async {
    try {
      await _items.doc().set(item.toCreateMap());
    } on FirebaseException catch (e) {
      throw DatabaseException.fromFirebase(e);
    }
  }

  Future<void> updateItem(ItemModel item) async {
    try {
      await _items.doc(item.id).update(item.toUpdateMap());
    } on FirebaseException catch (e) {
      throw DatabaseException.fromFirebase(e);
    }
  }

  /// Changes only the packed/unpacked status of one item.
  Future<void> setStatus(String itemId, String status) async {
    try {
      await _items.doc(itemId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw DatabaseException.fromFirebase(e);
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _items.doc(itemId).delete();
    } on FirebaseException catch (e) {
      throw DatabaseException.fromFirebase(e);
    }
  }

  // Items whose time is not yet known (just added) go to the end.
  static int _oldestFirst(ItemModel a, ItemModel b) {
    final aTime = a.createdAt ?? DateTime.now();
    final bTime = b.createdAt ?? DateTime.now();
    return aTime.compareTo(bTime);
  }
}