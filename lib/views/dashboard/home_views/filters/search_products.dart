import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:BabyShop/utils/cart_provider.dart';
import '../../../../utils/cart_functionalities.dart';
import '../../../../utils/wishlist_functionalities.dart';
import '../view_product_details.dart';
import 'empty_search_screen.dart'; // Import the empty search screen
import 'package:provider/provider.dart';
import '../../../../models/category_model.dart';
import '../../../../models/product_model.dart';
import '../../../../models/brand_model.dart';
import '../../../../services/category_service.dart';
import '../../../../services/product_service.dart';
import '../../../../services/brand_service.dart';
import 'package:BabyShop/utils/app_colors.dart';

class SearchProducts extends StatefulWidget {
  const SearchProducts({super.key});

  @override
  _SearchProductsState createState() => _SearchProductsState();
}

class _SearchProductsState extends State<SearchProducts> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final BrandService _brandService = BrandService();
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _brands = [];
  String _searchQuery = '';
  String _selectedPriceOption = 'All';
  String _selectedCategoryOption = 'All Categories';
  String _selectedBrandOption = 'All Brands';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final productsStream = _productService.getAllProducts();
      final categoriesStream = _categoryService.getAllCategories();
      final brandsStream = _brandService.getAllBrands();
      
      final productsSnapshot = await productsStream.first;
      final categoriesSnapshot = await categoriesStream.first;
      final brandsSnapshot = await brandsStream.first;
      
      if (mounted) {
        setState(() {
          _products = productsSnapshot.map((product) => {
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

          _filteredProducts = _products;
          _categories = categoriesSnapshot.map((category) => {
            'categoryname': category.categoryName,
          }).toList();
          _brands = brandsSnapshot.map((brand) => {
            'brandname': brand.brandName,
          }).toList();
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

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final name = product['name']?.toString() ?? '';
        return name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  void _filterProductsByCategory(String category) {
    setState(() {
      if (category == 'All Categories') {
        _filteredProducts = List.from(_products);
      } else {
        _filteredProducts = _products.where((product) {
          final productCategory = product['product_category']?.toString() ?? '';
          return productCategory.toLowerCase() == category.toLowerCase();
        }).toList();
      }
    });
  }

  void _filterProductsByBrand(String brand) {
    setState(() {
      if (brand == 'All Brands') {
        _filteredProducts = List.from(_products);
      } else {
        _filteredProducts = _products.where((product) {
          final productBrand = product['product_brand']?.toString() ?? '';
          return productBrand.toLowerCase() == brand.toLowerCase();
        }).toList();
      }
    });
  }

  void _sortProductsByPrice(String option) {
    setState(() {
      switch (option) {
        case 'All':
          _filteredProducts = List.from(_products);
          break;
        case 'Lowest to Highest':
          _filteredProducts.sort((a, b) =>
              (a['product_price'] as num).compareTo(b['product_price'] as num));
          break;
        case 'Highest to Lowest':
          _filteredProducts.sort((a, b) =>
              (b['product_price'] as num).compareTo(a['product_price'] as num));
          break;
      }
    });
  }

  void _showFilterBottomSheet(BuildContext context, String filterType) {
    String selectedOption = '';
    // ignore: unused_local_variable
    Color textColor = Colors.white;

    switch (filterType) {
      case 'Price':
        selectedOption = _selectedPriceOption;
        textColor =
            _selectedPriceOption != 'All' ? Colors.purple : Colors.white;
        break;
      case 'Categories':
        selectedOption = _selectedCategoryOption;
        textColor = _selectedCategoryOption != 'All Categories'
            ? Colors.purple
            : Colors.white;
        break;
      case 'Brands':
        selectedOption = _selectedBrandOption;
        textColor =
            _selectedBrandOption != 'All Brands' ? Colors.purple : Colors.white;
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                children: [
                  Text(
                    'Filter by $filterType',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filterType == 'Price') ...[
                    ...['All', 'Lowest to Highest', 'Highest to Lowest']
                        .map((option) {
                      return ListTile(
                        title: Text(option),
                        trailing: selectedOption == option
                            ? Icon(Icons.check_circle, color: Colors.purple)
                            : null,
                        onTap: () {
                          setState(() {
                            selectedOption = option;
                          });
                          this.setState(() {
                            _selectedPriceOption = option;
                          });
                          _sortProductsByPrice(option);
                          Navigator.pop(context);
                        },
                      );
                      // ignore: unnecessary_to_list_in_spreads
                    }).toList(),
                  ] else if (filterType == 'Categories') ...[
                    ListTile(
                      title: Text('All Categories'),
                      trailing: selectedOption == 'All Categories'
                          ? Icon(Icons.check_circle, color: Colors.purple)
                          : null,
                      onTap: () {
                        setState(() {
                          selectedOption = 'All Categories';
                        });
                        this.setState(() {
                          _selectedCategoryOption = 'All Categories';
                        });
                        _filterProductsByCategory('All Categories');
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category =
                              _categories[index]['categoryname']?.toString() ??
                                  '';
                          return ListTile(
                            title: Text(category),
                            trailing: selectedOption == category
                                ? Icon(Icons.check_circle, color: Colors.purple)
                                : null,
                            onTap: () {
                              setState(() {
                                selectedOption = category;
                              });
                              this.setState(() {
                                _selectedCategoryOption = category;
                              });
                              _filterProductsByCategory(category);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ] else if (filterType == 'Brands') ...[
                    ListTile(
                      title: Text('All Brands'),
                      trailing: selectedOption == 'All Brands'
                          ? Icon(Icons.check_circle, color: Colors.purple)
                          : null,
                      onTap: () {
                        setState(() {
                          selectedOption = 'All Brands';
                        });
                        this.setState(() {
                          _selectedBrandOption = 'All Brands';
                        });
                        _filterProductsByBrand('All Brands');
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _brands.length,
                        itemBuilder: (context, index) {
                          final brand =
                              _brands[index]['brandname']?.toString() ?? '';
                          return ListTile(
                            title: Text(brand),
                            trailing: selectedOption == brand
                                ? Icon(Icons.check_circle, color: Colors.purple)
                                : null,
                            onTap: () {
                              setState(() {
                                selectedOption = brand;
                              });
                              this.setState(() {
                                _selectedBrandOption = brand;
                              });
                              _filterProductsByBrand(brand);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToProductDetails(Map<String, dynamic> product) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search bar and filters row
              Row(
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _filterProducts();
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search products...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          suffixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filter buttons
              if (_filteredProducts.isNotEmpty) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterButton(context, 'Price'),
                      const SizedBox(width: 8),
                      _buildFilterButton(context, 'Categories'),
                      const SizedBox(width: 8),
                      _buildFilterButton(context, 'Brands'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Products grid
              Expanded(
                child: _filteredProducts.isNotEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  constraints.maxWidth > 600 ? 3 : 2,
                              childAspectRatio: 0.48,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              return _buildProductCard(
                                  _filteredProducts[index]);
                            },
                          );
                        },
                      )
                    : Center(child: SearchResult()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, String filterType) {
    String selectedOption = '';
    Color textColor = Colors.white;

    switch (filterType) {
      case 'Price':
        selectedOption = _selectedPriceOption;
        textColor =
            _selectedPriceOption != 'All' ? Colors.purple : Colors.white;
        break;
      case 'Categories':
        selectedOption = _selectedCategoryOption;
        textColor = _selectedCategoryOption != 'All Categories'
            ? Colors.purple
            : Colors.white;
        break;
      case 'Brands':
        selectedOption = _selectedBrandOption;
        textColor =
            _selectedBrandOption != 'All Brands' ? Colors.purple : Colors.white;
        break;
    }

    return ElevatedButton(
      onPressed: () => _showFilterBottomSheet(context, filterType),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            textColor == Colors.purple ? Colors.white : Colors.purple,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Colors.purple,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            filterType,
            style: TextStyle(
              color: textColor == Colors.purple ? Colors.purple : Colors.white,
            ),
          ),
          if (selectedOption != 'All' &&
              selectedOption != 'All Categories' &&
              selectedOption != 'All Brands') ...[
            const SizedBox(width: 4),
            Icon(
              Icons.check_circle,
              size: 16,
              color: textColor == Colors.purple ? Colors.purple : Colors.white,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => _navigateToProductDetails(product),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  product['image'] ?? 'assets/placeholder.png',
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
                      product['name'] ?? 'Unknown Product',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['price'] ?? '₦0.00',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Wishlist Button
                        Consumer<WishlistProvider>(
                          builder: (context, wishlistProvider, child) {
                            final isInWishlist = wishlistProvider.isItemInWishlist(product['product_id']);
                            return IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                isInWishlist ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: isInWishlist ? Colors.red : Colors.grey,
                              ),
                              onPressed: () {
                                if (isInWishlist) {
                                  wishlistProvider.removeFromWishlist(product['product_id']);
                                } else {
                                  final wishlistProduct = {
                                    'product_id': product['product_id'],
                                    'name': product['name'],
                                    'price': product['price'],
                                    'image': product['image'],
                                    'category': product['product_category'],
                                    'brand': product['product_brand'],
                                  };
                                  wishlistProvider.addToWishlist(wishlistProduct);
                                }
                              },
                            );
                          },
                        ),
                        // Cart Button
                        Consumer<CartProvider>(
                          builder: (context, cartProvider, child) {
                            final isInCart = cartProvider.isItemInCart(product['product_id']);
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isInCart ? Colors.red : AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: InkWell(
                                onTap: () {
                                  if (isInCart) {
                                    cartProvider.removeFromCart(product['product_id']);
                                  } else {
                                    final cartProduct = {
                                      'product_id': product['product_id'],
                                      'name': product['name'],
                                      'price': product['price'],
                                      'image': product['image'],
                                      'quantity': 1,
                                      'category': product['product_category'],
                                      'brand': product['product_brand'],
                                    };
                                    cartProvider.addToCart(cartProduct);
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
                                    const SizedBox(width: 4),
                                    Text(
                                      isInCart ? 'Remove' : 'Add',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
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
  }
}
