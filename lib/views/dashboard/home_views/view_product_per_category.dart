import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:BabyShop/utils/app_colors.dart';
import '../../../utils/cart_functionalities.dart';
import '../../../utils/cart_provider.dart';
import '../../../utils/wishlist_functionalities.dart';
import '../../../models/product_model.dart';
import 'view_product_details.dart';

class ProductsPerCategory extends StatelessWidget {
  final String categoryName;
  final List<Product> products;

  const ProductsPerCategory({
    super.key,
    required this.categoryName,
    required this.products,
  });

  void _navigateToProductDetails(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button and header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF4F4F4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Color(0xFF272727)),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    categoryName,
                    style: const TextStyle(
                      color: Color(0xFF272727),
                      fontSize: 24,
                      fontFamily: 'Gabarito',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Products grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.48,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () => _navigateToProductDetails(context, product),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          Expanded(
                            flex: 7,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: Image.network(
                                product.mainImage ?? 'assets/placeholder.png',
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Product Details
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.productName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₦${product.productPrice}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  // Action Buttons
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Wishlist Button
                                      Consumer<WishlistProvider>(
                                        builder:
                                            (context, wishlistProvider, child) {
                                          final isInWishlist =
                                              wishlistProvider.isItemInWishlist(
                                                  product.uid!);
                                          return IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: Icon(
                                              isInWishlist
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              size: 20,
                                              color: isInWishlist
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                            onPressed: () {
                                              if (isInWishlist) {
                                                wishlistProvider
                                                    .removeFromWishlist(
                                                        product.uid!);
                                              } else {
                                                final wishlistProduct = {
                                                  'product_id': product.uid,
                                                  'name': product.productName,
                                                  'price': product.productPrice,
                                                  'image': product.mainImage,
                                                  'category': product.productCategory,
                                                  'brand': product.productBrand,
                                                };
                                                wishlistProvider.addToWishlist(
                                                    wishlistProduct);
                                              }
                                            },
                                          );
                                        },
                                      ),
                                      // Cart Button
                                      Consumer<CartProvider>(
                                        builder:
                                            (context, cartProvider, child) {
                                          final isInCart =
                                              cartProvider.isItemInCart(
                                                  product.uid!);
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isInCart
                                                  ? Colors.red
                                                  : AppColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                if (isInCart) {
                                                  cartProvider.removeFromCart(
                                                      product.uid!);
                                                } else {
                                                  final cartProduct = {
                                                    'product_id': product.uid,
                                                    'name': product.productName,
                                                    'price': product.productPrice,
                                                    'image': product.mainImage,
                                                    'quantity': 1,
                                                    'category': product.productCategory,
                                                    'brand': product.productBrand,
                                                  };
                                                  cartProvider
                                                      .addToCart(cartProduct);
                                                }
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    isInCart
                                                        ? Icons.delete_outline
                                                        : Icons
                                                            .shopping_cart_outlined,
                                                    size: 16,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    isInCart ? 'Remove' : 'Add',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
