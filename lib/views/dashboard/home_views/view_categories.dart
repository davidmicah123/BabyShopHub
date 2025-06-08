import 'package:flutter/material.dart';
import 'view_product_per_category.dart';
import '../../../services/category_service.dart';
import '../../../services/product_service.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final CategoryService _categoryService = CategoryService();
  final ProductService _productService = ProductService();
  List<Category> categories = [];
  List<Product> products = [];
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
          categories = categoriesSnapshot;
          products = productsSnapshot;
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

  List<Product> _getProductsForCategory(String categoryId) {
    return products.where((product) => product.productCategory == categoryId).toList();
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
                  const Text(
                    'Shop by Categories',
                    style: TextStyle(
                      color: Color(0xFF272727),
                      fontSize: 24,
                      fontFamily: 'Gabarito',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Categories list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: CategoryItem(
                            title: category.categoryName,
                            imageUrl: category.categoryBannerImage ?? 'assets/placeholder.png',
                            products: _getProductsForCategory(category.categoryId),
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

// Category item widget
class CategoryItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final List<Product> products;

  const CategoryItem({
    required this.title,
    required this.imageUrl,
    required this.products,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductsPerCategory(
              categoryName: title,
              products: products,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: ShapeDecoration(
          color: const Color(0xFFF4F4F4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.fill,
                ),
                shape: const OvalBorder(),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF272727),
                fontSize: 16,
                fontFamily: 'Circular Std',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
