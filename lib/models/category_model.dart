import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String categoryId;
  final String categoryBannerImage;
  final String categoryName;

  Category({
    required this.categoryId,
    required this.categoryBannerImage,
    required this.categoryName,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      categoryId: doc.id,
      categoryBannerImage: data['categorybannerimage'] ?? '',
      categoryName: data['categoryname'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categorybannerimage': categoryBannerImage,
      'categoryname': categoryName,
    };
  }
}
