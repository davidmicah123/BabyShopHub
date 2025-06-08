import 'package:flutter/material.dart';
import 'package:BabyShop/utils/cart_provider.dart';
import 'package:provider/provider.dart';
import '../../../utils/cart_functionalities.dart';
// import '../../../utils/cart_provider.dart';
import '../../../utils/wishlist_functionalities.dart';
import 'package:BabyShop/utils/app_colors.dart';

class WishlistDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const WishlistDetailPage({super.key, required this.product});

  Widget _buildSpecificationRow(
      BuildContext context, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: MediaQuery.of(context).size.width * 0.04,
              )),
          Text(value ?? 'N/A',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isActive) {
    return Chip(
      label: Text(label),
      backgroundColor:
          // ignore: deprecated_member_use
          isActive ? AppColors.primary.withOpacity(0.2) : Colors.grey[200],
      labelStyle: TextStyle(
        color: isActive ? AppColors.primary : Colors.grey[600],
        fontSize: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(product['name']),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images Section
            SizedBox(
              height: screenWidth * 0.8,
              child: Row(
                children: [
                  // Main Image
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details Section
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    product['price'],
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Brand and Category
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Brand',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenWidth * 0.035,
                                )),
                            Text(
                              product['brand'] ?? 'No Brand',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Category',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenWidth * 0.035,
                                )),
                            Text(
                              product['category'] ?? 'No Category',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Product Description
                  if (product['product_description'] != null) ...[
                    SizedBox(height: 24),
                    Text('Description',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(height: 8),
                    Text(
                      product['product_description'],
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                  ],

                  // Specifications
                  if (product['product_specification'] != null) ...[
                    SizedBox(height: 24),
                    Text('Specifications',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(height: 8),
                    _buildSpecificationRow(context, 'RAM',
                        product['product_specification']['ram']),
                    _buildSpecificationRow(context, 'Storage',
                        product['product_specification']['rom']),
                    _buildSpecificationRow(context, 'Screen',
                        product['product_specification']['screen_size']),
                    _buildSpecificationRow(context, 'Battery',
                        product['product_specification']['battery']),
                    _buildSpecificationRow(context, 'Camera',
                        product['product_specification']['camera']),
                  ],

                  // Product Status
                  if (product['is_product_featured'] != null ||
                      product['is_product_special_deals'] != null) ...[
                    SizedBox(height: 24),
                    Row(
                      children: [
                        if (product['is_product_featured'] != null)
                          _buildStatusChip(
                              'Featured', product['is_product_featured']),
                        SizedBox(width: 8),
                        if (product['is_product_special_deals'] != null)
                          _buildStatusChip('Special Deal',
                              product['is_product_special_deals']),
                      ],
                    ),
                  ],

                  // Stock Information
                  if (product['product_quantity'] != null) ...[
                    SizedBox(height: 16),
                    Text(
                      'In Stock: ${product['product_quantity']} units',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                  ],

                  // Cart and Wishlist Actions
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Consumer2<CartProvider, WishlistProvider>(
                        builder:
                            (context, cartProvider, wishlistProvider, child) {
                          final isInCart =
                              cartProvider.isItemInCart(product['product_id']);
                          final isInWishlist = wishlistProvider
                              .isItemInWishlist(product['product_id']);

                          return Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isInWishlist
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      isInWishlist ? Colors.red : Colors.grey,
                                ),
                                onPressed: () {
                                  if (isInWishlist) {
                                    wishlistProvider.removeFromWishlist(
                                        product['product_id']);
                                    Navigator.pop(
                                        context); // Return to previous screen after removal
                                  }
                                },
                              ),
                              SizedBox(width: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isInCart ? Colors.red : AppColors.primary,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  if (isInCart) {
                                    cartProvider
                                        .removeFromCart(product['product_id']);
                                  } else {
                                    cartProvider.addToCart(product);
                                  }
                                },
                                child: Text(
                                  isInCart ? 'Remove from Cart' : 'Add to Cart',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
