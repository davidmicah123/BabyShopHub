import 'package:cloud_firestore/cloud_firestore.dart';

class Brand {
  final String brandId;
  final String brandName;

  Brand({
    required this.brandId,
    required this.brandName,
  });

  factory Brand.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Brand(
      brandId: doc.id,
      brandName: data['brandname'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brandname': brandName,
    };
  }
}
