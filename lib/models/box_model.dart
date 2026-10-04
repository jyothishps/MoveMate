import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_packing_app/core/constants/firestore_constants.dart';

class BoxModel {
  final String id;
  final String userId;
  final String boxName;
  final String category;
  final String location;
  final String description;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BoxModel({
    required this.id,
    required this.userId,
    required this.boxName,
    required this.category,
    required this.location,
    required this.description,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPacked => status == PackingStatus.packed;

  /// Short code for display only, e.g. "K3F9A2".
  String get shortCode =>
      (id.length >= 6 ? id.substring(0, 6) : id).toUpperCase();

  /// The text stored inside this box's QR code.
  String get qrData => '${FirestoreConstants.qrPrefix}$id';

  /// Builds a BoxModel from a Firestore document.
  factory BoxModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return BoxModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      boxName: data['boxName'] as String? ?? '',
      category: data['category'] as String? ?? '',
      location: data['location'] as String? ?? '',
      description: data['description'] as String? ?? '',
      status: data['status'] as String? ?? PackingStatus.unpacked,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Fields saved when a new box is created.
  Map<String, dynamic> toCreateMap() {
    return {
      'userId': userId,
      'boxName': boxName,
      'category': category,
      'location': location,
      'description': description,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Fields saved when a box is edited (userId and createdAt never change).
  Map<String, dynamic> toUpdateMap() {
    return {
      'boxName': boxName,
      'category': category,
      'location': location,
      'description': description,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}