import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_packing_app/core/constants/firestore_constants.dart';
import 'package:qr_packing_app/models/item_model.dart';

class ItemService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Live list of all items owned by the given user.
  Stream<List<ItemModel>> streamUserItems(String userId) {
    return _db
        .collection(FirestoreConstants.itemsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ItemModel.fromDoc).toList());
  }
}