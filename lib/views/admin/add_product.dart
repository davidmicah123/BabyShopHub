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

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final BrandService _brandService = BrandService();
  final ImagePicker _picker = ImagePicker();
  
  String productName = '';
  double productPrice = 0.0;
  String productBrand = '';
  String productCategory = '';
  String productDescription = '';
  int productQuantity = 0;
  bool isProductFeatured = false;
  bool isProductSpecialDeals = false;
  
  File? mainImage;
  List<File> subImages = [];
  bool isLoading = false;
  List<Category> categories = [];
  List<Brand> brands = [];

  @override
  void initState() {
    super.initState();
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
      
      if (mainImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a main image')),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        // Upload main image
        String mainImageUrl = await CloudinaryService.uploadImage(mainImage!);
        
        // Upload sub images if any
        List<String> subImageUrls = [];
        if (subImages.isNotEmpty) {
          subImageUrls = await CloudinaryService.uploadImages(subImages);
        }

        // Get brand and category names from their IDs
        String brandName = brands.firstWhere((brand) => brand.brandId == productBrand).brandName;
        String categoryName = categories.firstWhere((category) => category.categoryId == productCategory).categoryName;

        final product = Product(
          productName: productName,
          productPrice: productPrice,
          productBrand: brandName,  // Store the brand name instead of ID
          productCategory: categoryName,  // Store the category name instead of ID
          productDescription: productDescription,
          productQuantity: productQuantity,
          isProductFeatured: isProductFeatured,
          isProductSpecialDeals: isProductSpecialDeals,
          mainImage: mainImageUrl,
          subImages: subImageUrls,
        );

        final success = await _productService.addProduct(product);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully!')),
          );
          Navigator.pop(context);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add product')),
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

  Future<void> _pickMainImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          mainImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _pickSubImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          subImages.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  Widget _buildImagePreview(File image, {bool isMain = false, VoidCallback? onRemove}) {
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
            child: Image.file(
              image,
              fit: BoxFit.cover,
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
        title: const Text('Add New Product', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Upload Section
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
                            const SizedBox(height: 16),                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _pickMainImage,
                                  icon: const Icon(Icons.add_photo_alternate),
                                  label: const Text('Main Image', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _pickSubImages,
                                  icon: const Icon(Icons.add_photo_alternate),
                                  label: const Text('Sub Images', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (mainImage != null)
                              _buildImagePreview(mainImage!, isMain: true),
                            if (subImages.isNotEmpty)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: subImages
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) => _buildImagePreview(
                                          entry.value,
                                          onRemove: () {
                                            setState(() {
                                              subImages.removeAt(entry.key);
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
              const SizedBox(height: 16),              TextFormField(
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
                value: productBrand.isEmpty ? null : productBrand,
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
                  setState(() {
                    productBrand = newValue ?? '';
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                value: productCategory.isEmpty ? null : productCategory,
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
                  setState(() {
                    productCategory = newValue ?? '';
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
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
                  'Add Product',
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
