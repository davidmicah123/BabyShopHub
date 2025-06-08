import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all categories
  Stream<List<Category>> getAllCategories() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
    });
  }

  // Add a new category
  Future<bool> addCategory(Category category) async {
    try {
      await _firestore.collection('categories').add(category.toMap());
      return true;
    } catch (e) {
      print('Error adding category: $e');
      return false;
    }
  }

  // Update a category
  Future<bool> updateCategory(String categoryId, Category category) async {
    try {
      await _firestore.collection('categories').doc(categoryId).update(category.toMap());
      return true;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  // Delete a category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
      return true;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }
}
