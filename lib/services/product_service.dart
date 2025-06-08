// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new product
  Future<bool> addProduct(Product product) async {
    try {      await _firestore.collection('products').add({
        'product_name': product.productName,
        'product_price': product.productPrice,
        'product_brand': product.productBrand,
        'product_category': product.productCategory,
        'is_product_featured': product.isProductFeatured,
        'is_product_special_deals': product.isProductSpecialDeals,
        'product_description': product.productDescription,
        'product_quantity': product.productQuantity,
        'main_image': product.mainImage,
        'sub_images': product.subImages,
        'created_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }

  // Update a product
  Future<bool> updateProduct(String productId, Product product) async {
    try {      await _firestore.collection('products').doc(productId).update({
        'product_name': product.productName,
        'product_price': product.productPrice,
        'product_brand': product.productBrand,
        'product_category': product.productCategory,
        'is_product_featured': product.isProductFeatured,
        'is_product_special_deals': product.isProductSpecialDeals,
        'product_description': product.productDescription,
        'product_quantity': product.productQuantity,
        'main_image': product.mainImage,
        'sub_images': product.subImages,
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  // Delete a product
  Future<bool> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }
  // Get all products
  Stream<List<Product>> getAllProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Get featured products
  Stream<List<Product>> getFeaturedProducts() {
    return _firestore
        .collection('products')
        .where('is_product_featured', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Get products by category
  Stream<List<Product>> getProductsByCategory(String category) {
    return _firestore
        .collection('products')
        .where('product_category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }
}
