import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/brand_model.dart';

class BrandService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'brands';
  Stream<List<Brand>> getAllBrands() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Brand.fromFirestore(doc)).toList();
    });
  }

  Future<Brand?> addBrand(String brandName) async {
    try {
      DocumentReference docRef = await _firestore.collection(_collection).add({
        'brandname': brandName,
      });
      
      DocumentSnapshot doc = await docRef.get();
      return Brand.fromFirestore(doc);
    } catch (e) {
      print('Error adding brand: $e');
      return null;
    }
  }

  Future<bool> updateBrand(String brandId, String brandName) async {
    try {
      await _firestore.collection(_collection).doc(brandId).update({
        'brandname': brandName,
      });
      return true;
    } catch (e) {
      print('Error updating brand: $e');
      return false;
    }
  }

  Future<bool> deleteBrand(String brandId) async {
    try {
      await _firestore.collection(_collection).doc(brandId).delete();
      return true;
    } catch (e) {
      print('Error deleting brand: $e');
      return false;
    }
  }
}
