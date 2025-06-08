import 'package:flutter/material.dart';
import 'package:BabyShop/utils/product_status_provider.dart';
import 'package:BabyShop/utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../utils/cart_functionalities.dart';
import '../../../utils/cart_provider.dart';
import '../../../utils/wishlist_functionalities.dart';
import '../../../models/product_model.dart';

class ProductPage extends StatefulWidget {
  final Product product;

  const ProductPage({super.key, required this.product});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String selectedSize = 'S';
  String selectedColor = 'Orange';
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.productName ?? 'Product Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Consumer<ProductStatusProvider>(
            builder: (context, productStatusProvider, child) {
              final bool isInWishlist = productStatusProvider
                  .isItemInWishlist(product.uid ?? '');
              return IconButton(
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWishlist ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  final wishlistProvider =
                      Provider.of<WishlistProvider>(context, listen: false);
                  if (isInWishlist) {
                    wishlistProvider.removeFromWishlist(product.uid ?? '');
                  } else {
                    final wishlistProduct = {
                      'product_id': product.uid,
                      'name': product.productName,
                      'price': product.productPrice,
                      'image': product.mainImage ?? 'assets/placeholder.png',
                      'category': product.productCategory,
                      'brand': product.productBrand,
                    };
                    wishlistProvider.addToWishlist(wishlistProduct);
                  }
                },
              );
            },
          ),
        ],
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
                        product.mainImage ?? 'assets/placeholder.png',
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
                  SizedBox(width: 8),
                  // Sub Images Column
                  if (product.subImages != null && product.subImages!.isNotEmpty)
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: product.subImages!.take(3).map((subImage) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  subImage,
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
                          );
                        }).toList(),
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
                    product.productName ?? 'Unnamed Product',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "₦${product.productPrice ?? '0.00'}",
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      color: Colors.purple,
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
                              product.productBrand ?? 'No Brand',
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
                              product.productCategory ?? 'Uncategorized',
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
                  SizedBox(height: 24),
                  Text('Description',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      )),
                  SizedBox(height: 8),
                  Text(
                    product.productDescription ?? 'No description available',
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),

                  // Product Status
                  SizedBox(height: 24),
                  Row(
                    children: [
                      _buildStatusChip(
                        'Featured',
                        product.isProductFeatured ?? false,
                      ),
                      SizedBox(width: 8),
                      _buildStatusChip(
                        'Special Deal',
                        product.isProductSpecialDeals ?? false,
                      ),
                    ],
                  ),

                  // Stock Information
                  SizedBox(height: 16),
                  Text(
                    'In Stock: ${product.productQuantity ?? 0} units',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ],
              ),
            ),

            // Add to Cart Button
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Center(
                child: Consumer<ProductStatusProvider>(
                  builder: (context, productStatusProvider, child) {
                    final bool isInCart = productStatusProvider
                        .isItemInCart(product.uid ?? '');
                    return SizedBox(
                      width: screenWidth * 0.75,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isInCart ? Colors.red : AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          final cartProvider =
                              Provider.of<CartProvider>(context, listen: false);
                          if (isInCart) {
                            cartProvider.removeFromCart(product.uid ?? '');
                          } else {
                            final cartProduct = {
                              'product_id': product.uid,
                              'name': product.productName,
                              'price': product.productPrice,
                              'image': product.mainImage ?? 'assets/placeholder.png',
                              'quantity': 1,
                              'category': product.productCategory,
                              'brand': product.productBrand,
                            };
                            cartProvider.addToCart(cartProduct);
                          }
                        },
                        child: Text(
                          isInCart ? 'Remove from Cart' : 'Add to Cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isActive) {
    return Chip(
      label: Text(label),
      backgroundColor:
          isActive ? AppColors.primary.withOpacity(0.2) : Colors.grey[200],
      labelStyle: TextStyle(
        color: isActive ? AppColors.primary : Colors.grey[600],
        fontSize: MediaQuery.of(context).size.width * 0.035,
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final double rating;
  final String reviewer;
  final String comment;

  const ReviewCard(
      {super.key,
      required this.rating,
      required this.reviewer,
      required this.comment});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reviewer,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ),
            SizedBox(height: 4),
            Text(comment),
          ],
        ),
      ),
    );
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const CustomDropdown(
      {super.key,
      required this.value,
      required this.items,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      isExpanded: true,
      value: value,
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                Text(item.toString(), style: TextStyle(fontSize: 16)),
                Spacer(),
                // Color indicator for color dropdown
                if (items == ['Orange', 'Black', 'Red', 'Yellow', 'Blue'])
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: item == 'Orange'
                          ? Colors.orange
                          : item == 'Black'
                              ? Colors.black
                              : item == 'Red'
                                  ? Colors.red
                                  : item == 'Yellow'
                                      ? Colors.yellow
                                      : Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      underline: Container(),
      style: TextStyle(color: Colors.black),
      dropdownColor: Colors.white,
    );
  }
}
