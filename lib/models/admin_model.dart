import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String uid;
  String email;
  String username;
  String role;
  bool isActive;
  
  Admin({
    required this.uid,
    required this.email,
    required this.username,
    required this.role,
    this.isActive = true,
  });

  // Factory constructor to create an Admin object from a Firestore document
  factory Admin.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Admin(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      role: data['role'] ?? 'admin',
      isActive: data['is_active'] ?? true,
    );
  }
}
