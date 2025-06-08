import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../models/brand_model.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';
import '../../services/brand_service.dart';
import '../../services/cloudinary_service.dart';
import '../../utils/app_colors.dart';

class EditProduct extends StatefulWidget {
  final Product product;
  
  const EditProduct({super.key, required this.product});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final BrandService _brandService = BrandService();
  final ImagePicker _picker = ImagePicker();
  
  late String productName;
  late double productPrice;
  late String productBrand;
  late String productCategory;
  late String productDescription;
  late int productQuantity;
  late bool isProductFeatured;
  late bool isProductSpecialDeals;
  
  File? mainImage;
  List<File> subImages = [];
  List<String> existingSubImages = [];
  bool isLoading = false;
  List<Category> categories = [];
  List<Brand> brands = [];

  @override
  void initState() {
    super.initState();
    // Initialize fields with existing product data
    productName = widget.product.productName;
    productPrice = widget.product.productPrice;
    productBrand = widget.product.productBrand;
    productCategory = widget.product.productCategory;
    productDescription = widget.product.productDescription;
    productQuantity = widget.product.productQuantity;
    isProductFeatured = widget.product.isProductFeatured;
    isProductSpecialDeals = widget.product.isProductSpecialDeals;
    if (widget.product.subImages != null) {
      existingSubImages = List.from(widget.product.subImages!);
    }
    _loadCategoriesAndBrands();
  }

  Future<void> _loadCategoriesAndBrands() async {
    try {
      final categoriesStream = _categoryService.getAllCategories();
      final brandsStream = _brandService.getAllBrands();
      
      final categoriesSnapshot = await categoriesStream.first;
      final brandsSnapshot = await brandsStream.first;
      
      if (mounted) {
        setState(() {
          categories = categoriesSnapshot;
          brands = brandsSnapshot;
        });
      }
    } catch (e) {
      print('Error loading categories and brands: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoading = true;
      });

      try {
        // Handle main image upload if changed
        String? mainImageUrl = widget.product.mainImage;
        if (mainImage != null) {
          mainImageUrl = await CloudinaryService.uploadImage(mainImage!);
        }
        
        // Handle sub images
        List<String> finalSubImages = [...existingSubImages];
        if (subImages.isNotEmpty) {
          List<String> newSubImageUrls = await CloudinaryService.uploadImages(subImages);
          finalSubImages.addAll(newSubImageUrls);
        }

        // Get brand and category names from their IDs
        String brandName = brands.firstWhere((brand) => brand.brandId == productBrand).brandName;
        String categoryName = categories.firstWhere((category) => category.categoryId == productCategory).categoryName;

        final updatedProduct = Product(
          uid: widget.product.uid,
          productName: productName,
          productPrice: productPrice,
          productBrand: brandName,
          productCategory: categoryName,
          productDescription: productDescription,
          productQuantity: productQuantity,
          isProductFeatured: isProductFeatured,
          isProductSpecialDeals: isProductSpecialDeals,
          mainImage: mainImageUrl,
          subImages: finalSubImages,
        );

        final success = await _productService.updateProduct(widget.product.uid!, updatedProduct);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully!')),
          );
          Navigator.pop(context);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update product')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildImagePreview(String imageUrl, {bool isMain = false, VoidCallback? onRemove}) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error);
              },
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: onRemove,
            ),
          ),
        if (isMain)
          const Positioned(
            bottom: 8,
            right: 8,
            child: Chip(
              label: Text('Main'),
              backgroundColor: Color(0xFF8E6CEE),
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Product Images',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (widget.product.mainImage != null)
                              _buildImagePreview(widget.product.mainImage!, isMain: true),
                            if (existingSubImages.isNotEmpty)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: existingSubImages
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) => _buildImagePreview(
                                          entry.value,
                                          onRemove: () {
                                            setState(() {
                                              existingSubImages.removeAt(entry.key);
                                            });
                                          },
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: productName,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                      onSaved: (value) => productName = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: productPrice.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixText: '₦',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onSaved: (value) => productPrice = double.parse(value!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                        border: OutlineInputBorder(),
                      ),
                      value: brands.any((brand) => brand.brandId == productBrand) ? productBrand : null,
                      items: brands.map((brand) {
                        return DropdownMenuItem(
                          value: brand.brandId,
                          child: Text(brand.brandName),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a brand';
                        }
                        return null;
                      },
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            productBrand = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      value: categories.any((category) => category.categoryId == productCategory) ? productCategory : null,
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category.categoryId,
                          child: Text(category.categoryName),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            productCategory = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: productDescription,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                      onSaved: (value) => productDescription = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: productQuantity.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onSaved: (value) => productQuantity = int.parse(value!),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Featured Product'),
                      value: isProductFeatured,
                      onChanged: (bool value) {
                        setState(() {
                          isProductFeatured = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Special Deal'),
                      value: isProductSpecialDeals,
                      onChanged: (bool value) {
                        setState(() {
                          isProductSpecialDeals = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Update Product',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
