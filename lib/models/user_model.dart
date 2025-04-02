// class UserModel {
//   final String? id;
//   final String email;
//   final DateTime? timestamp;

//   UserModel({this.id, required this.email, this.timestamp});

//   // Convert UserModel to a Map for Firestore
//   Map<String, dynamic> toMap() {
//     return {'email': email, 'timestamp': timestamp ?? DateTime.now()};
//   }

//   // Create UserModel from a Firestore document
//   factory UserModel.fromMap(Map<String, dynamic> data, String id) {
//     return UserModel(
//       id: id,
//       email: data['email'],
//       timestamp: data['timestamp']?.toDate(),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final Timestamp timestamp;

  UserModel({required this.id, required this.email, required this.timestamp});

  // Convert Firestore document to UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {'email': email, 'timestamp': timestamp};
  }
}
