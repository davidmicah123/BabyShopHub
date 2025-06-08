import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:BabyShop/utils/product_status_provider.dart';
import 'package:BabyShop/utils/app_colors.dart';
import 'dart:convert';
import '../../../utils/cart_functionalities.dart';
import '../../dashboard/home_views/view_categories.dart';
import '../cart_and_checkout_views/cart_empty.dart';
import '../cart_and_checkout_views/cart_filled.dart';
import 'package:provider/provider.dart';
import '../../dashboard/home_views/view_product_details.dart';
import '../../../utils/cart_provider.dart';
import '../../../utils/wishlist_functionalities.dart';
import '../../dashboard/profile_views/wishlist_page.dart';
import '../../dashboard/home_views/filters/search_products.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../../services/category_service.dart';
import '../../../services/product_service.dart';
import 'view_product_per_category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CategoryService _categoryService = CategoryService();
  final ProductService _productService = ProductService();
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> specialOffers = [];
  List<Map<String, dynamic>> latestProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final categoriesStream = _categoryService.getAllCategories();
      final productsStream = _productService.getAllProducts();
      
      final categoriesSnapshot = await categoriesStream.first;
      final productsSnapshot = await productsStream.first;
      
      if (mounted) {
        setState(() {
          // Convert Category models to maps
          categories = categoriesSnapshot.map((category) => {
            'image': category.categoryBannerImage,
            'name': category.categoryName,
          }).toList();

          // Convert Product models to maps
          products = productsSnapshot.map((product) => {
            'product_id': product.uid,
            'product_image': {
              'main_image': product.mainImage,
              'sub_images': product.subImages ?? [],
            },
            'product_name': product.productName,
            'product_price': product.productPrice,
            'product_brand': product.productBrand,
            'product_category': product.productCategory,
            'product_specification': {
              'ram': '',
              'rom': '',
              'screen_size': '',
              'battery': '',
              'camera': '',
            },
            'is_product_featured': product.isProductFeatured,
            'is_product_special_deals': product.isProductSpecialDeals,
            'product_description': product.productDescription,
            'product_quantity': product.productQuantity,
            // Keep these for the product list display
            'image': product.mainImage,
            'name': product.productName,
            'price': '₦${product.productPrice.toStringAsFixed(2)}',
          }).toList();

          // Select products for special offers and latest products
          specialOffers = products
              .where((product) => product['is_product_special_deals'])
              .toList()
              .take(4)
              .toList();
          latestProducts = products
              .where((product) => product['is_product_featured'])
              .toList()
              .take(4)
              .toList();
          
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Baby Shop', style: TextStyle(color: Color(0xFF272727))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Color(0xFF272727)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchProducts()),
              );
            },
          ),
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      if (cartProvider.cartItems.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartFilled(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmptyCart(),
                          ),
                        );
                      }
                    },
                  ),
                  if (cartProvider.cartItems.isNotEmpty)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${cartProvider.cartItems.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WishlistPage(),
                        ),
                      );
                    },
                  ),
                  if (wishlistProvider.wishlistItems.isNotEmpty)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${wishlistProvider.wishlistItems.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      _buildSectionHeader('Categories', onSeeAllPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Categories(),
                          ),
                        );
                      }),
                      SizedBox(height: 16),
                      _buildCategoriesSection(),
                      SizedBox(height: 24),
                      _buildSectionHeader('Top Selling', onSeeAllPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SearchProducts()),
                        );
                      }),
                      SizedBox(height: 16),
                      _buildTopSellingProducts(),
                      SizedBox(height: 24),
                      _buildSectionHeader('Special Offers', onSeeAllPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SearchProducts()),
                        );
                      }),
                      SizedBox(height: 16),
                      _buildSpecialOffers(),
                      SizedBox(height: 24),
                      _buildSectionHeader('Latest Products', onSeeAllPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SearchProducts()),
                        );
                      }),
                      SizedBox(height: 16),
                      _buildLatestProducts(),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onSeeAllPressed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF272727),
          ),
        ),
        TextButton(
          onPressed: onSeeAllPressed,
          child: Text(
            'See All',
            style: TextStyle(
              color: Color(0xFF8E6CEE),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              // Filter products for this category
              final categoryProducts = products
                  .where((product) => product['product_category'] == category['name'])
                  .map((product) => Product(
                    uid: product['product_id'],
                    mainImage: product['image'],
                    subImages: product['product_image']['sub_images'],
                    productName: product['product_name'],
                    productPrice: product['product_price'],
                    productBrand: product['product_brand'],
                    productCategory: product['product_category'],
                    productDescription: product['product_description'],
                    productQuantity: product['product_quantity'],
                    isProductFeatured: product['is_product_featured'],
                    isProductSpecialDeals: product['is_product_special_deals'],
                  ))
                  .toList();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductsPerCategory(
                    categoryName: category['name'],
                    products: categoryProducts,
                  ),
                ),
              );
            },
            child: Container(
              width: 100,
              margin: EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      category['image'],
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.error),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    category['name'],
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopSellingProducts() {
    final randomTopSelling = products.toList()..shuffle();
    return _buildProductSection(randomTopSelling.take(4).toList());
  }

  Widget _buildSpecialOffers() {
    return _buildProductSection(specialOffers);
  }

  Widget _buildLatestProducts() {
    return _buildProductSection(latestProducts);
  }

  Widget _buildProductSection(List<Map<String, dynamic>> productList) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: productList.length,
        itemBuilder: (context, index) {
          final product = productList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductPage(
                    product: Product(
                      uid: product['product_id'],
                      mainImage: product['image'],
                      subImages: product['product_image']['sub_images'],
                      productName: product['product_name'],
                      productPrice: product['product_price'],
                      productBrand: product['product_brand'],
                      productCategory: product['product_category'],
                      productDescription: product['product_description'],
                      productQuantity: product['product_quantity'],
                      isProductFeatured: product['is_product_featured'],
                      isProductSpecialDeals: product['is_product_special_deals'],
                    ),
                  ),
                ),
              );
            },
            child: Consumer<ProductStatusProvider>(
              builder: (context, productStatusProvider, child) {
                final bool isInCart = productStatusProvider.isItemInCart(product['product_id']);
                final bool isInWishlist = productStatusProvider.isItemInWishlist(product['product_id']);

                return Container(
                  width: 200,
                  margin: EdgeInsets.only(right: 16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              product['image'],
                              width: double.infinity,
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
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  product['product_name'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF272727),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  product['price'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                      icon: Icon(
                                        isInWishlist ? Icons.favorite : Icons.favorite_border,
                                        color: isInWishlist ? Colors.red : Colors.grey,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
                                        if (isInWishlist) {
                                          wishlistProvider.removeFromWishlist(product['product_id']);
                                        } else {
                                          final wishlistProduct = {
                                            'product_id': product['product_id'],
                                            'name': product['product_name'],
                                            'price': product['price'],
                                            'image': product['image'],
                                            'category': product['product_category'],
                                            'brand': product['product_brand'],
                                          };
                                          wishlistProvider.addToWishlist(wishlistProduct);
                                        }
                                      },
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isInCart ? Colors.red : AppColors.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: InkWell(
                                        onTap: () async {
                                          final cartProvider = Provider.of<CartProvider>(context, listen: false);
                                          if (isInCart) {
                                            await cartProvider.removeFromCart(product['product_id']);
                                          } else {
                                            final cartProduct = {
                                              'product_id': product['product_id'],
                                              'name': product['product_name'],
                                              'price': product['price'],
                                              'image': product['image'],
                                              'quantity': 1,
                                              'category': product['product_category'],
                                              'brand': product['product_brand'],
                                            };
                                            await cartProvider.addToCart(cartProduct);
                                          }
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isInCart ? Icons.delete_outline : Icons.shopping_cart_outlined,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              isInCart ? 'Remove' : 'Add',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
          );
        },
      ),
    );
  }
}
