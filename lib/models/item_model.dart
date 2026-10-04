import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_packing_app/core/constants/firestore_constants.dart';

class ItemModel {
  final String id;
  final String boxId;
  final String userId;
  final String itemName;
  final String description;
  final int quantity;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ItemModel({
    required this.id,
    required this.boxId,
    required this.userId,
    required this.itemName,
    required this.description,
    required this.quantity,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPacked => status == PackingStatus.packed;

  /// Builds an ItemModel from a Firestore document.
  factory ItemModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ItemModel(
      id: doc.id,
      boxId: data['boxId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      itemName: data['itemName'] as String? ?? '',
      description: data['description'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      status: data['status'] as String? ?? PackingStatus.unpacked,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Fields saved when a new item is created.
  Map<String, dynamic> toCreateMap() {
    return {
      'boxId': boxId,
      'userId': userId,
      'itemName': itemName,
      'description': description,
      'quantity': quantity,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Fields saved when an item is edited (boxId, userId, createdAt never change).
  Map<String, dynamic> toUpdateMap() {
    return {
      'itemName': itemName,
      'description': description,
      'quantity': quantity,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}