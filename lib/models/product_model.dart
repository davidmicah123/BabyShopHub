import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String? uid;
  String? mainImage;
  List<String>? subImages;
  String productName;
  double productPrice;
  String productBrand;
  String productCategory;
  bool isProductFeatured;
  bool isProductSpecialDeals;
  String productDescription;
  int productQuantity;

  Product({
    this.uid,
    this.mainImage,
    this.subImages,
    required this.productName,
    required this.productPrice,
    required this.productBrand,
    required this.productCategory,
    this.isProductFeatured = false,
    this.isProductSpecialDeals = false,
    required this.productDescription,
    required this.productQuantity,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      uid: doc.id,
      mainImage: data['main_image'],
      subImages: data['sub_images'] != null
          ? List<String>.from(data['sub_images'])
          : null,
      productName: data['product_name'] ?? '',
      productPrice: (data['product_price'] ?? 0.0).toDouble(),
      productBrand: data['product_brand'] ?? '',
      productCategory: data['product_category'] ?? '',
      isProductFeatured: data['is_product_featured'] ?? false,
      isProductSpecialDeals: data['is_product_special_deals'] ?? false,
      productDescription: data['product_description'] ?? '',
      productQuantity: data['product_quantity'] ?? 0,
    );
  }
}


