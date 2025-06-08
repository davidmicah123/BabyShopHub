import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/cloudinary_service.dart';
import '../authentication/sign_in.dart';
import 'add_product.dart';
import 'edit_product.dart';
import '../../models/category_model.dart';
import '../../services/category_service.dart';
import '../../models/brand_model.dart';
import '../../services/brand_service.dart';
import '../../utils/app_colors.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final BrandService _brandService = BrandService();  final FirebaseAuth _auth = FirebaseAuth.instance;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    try {
      await _auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SignIn()),
        (route) => false,
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }  Future<void> _addCategory() async {
    final formKey = GlobalKey<FormState>();
    final textController = TextEditingController();
    final _picker = ImagePicker();
    bool isLoading = false;
    File? selectedImage;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Category'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                    hintText: 'Enter category name',
                    prefixIcon: Icon(Icons.category),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: selectedImage == null
                      ? Center(
                          child: IconButton(
                            icon: const Icon(Icons.add_photo_alternate, size: 50),
                            onPressed: () async {
                              final XFile? image = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                setState(() {
                                  selectedImage = File(image.path);
                                });
                              }
                            },
                          ),
                        )
                      : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                selectedImage!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    selectedImage = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        if (selectedImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select an image'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          isLoading = true;
                        });
                        
                        try {
                          // Upload image to Cloudinary
                          final imageUrl = await CloudinaryService.uploadImage(selectedImage!);
                          
                          await _categoryService.addCategory(Category(
                            categoryId: '',
                            categoryName: textController.text,
                            categoryBannerImage: imageUrl,
                          ));
                          
                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Category added successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error adding category: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  const Text('Add Category', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _addBrand() async {
    final formKey = GlobalKey<FormState>();
    final textController = TextEditingController();
    bool isLoading = false;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Brand'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Brand Name',
                border: OutlineInputBorder(),
                hintText: 'Enter brand name',
                prefixIcon: Icon(Icons.branding_watermark),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a brand name';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });

                        try {
                          await _brandService.addBrand(textController.text);
                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Brand added successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error adding brand: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  const Text('Add Brand', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,        bottom: TabBar(
          controller: _tabController!,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Products'),
            Tab(text: 'Categories'),
            Tab(text: 'Brands'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
          ),
        ],
      ),      body: TabBarView(
        controller: _tabController!,
        children: [
          // Products Tab
          StreamBuilder<List<Product>>(
            stream: _productService.getAllProducts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final products = snapshot.data ?? [];

              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: product.mainImage != null
                          ? Image.network(
                              product.mainImage!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.image_not_supported);
                              },
                            )
                          : Icon(Icons.laptop),
                      title: Text(product.productName),
                      subtitle: Text('₦${product.productPrice.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProduct(product: product),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              bool confirm = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Delete Product'),
                                  content: Text('Are you sure you want to delete this product?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              ) ?? false;

                              if (confirm) {
                                await _productService.deleteProduct(product.uid!);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Categories Tab
          StreamBuilder<List<Category>>(
            stream: _categoryService.getAllCategories(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final categories = snapshot.data ?? [];

              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: category.categoryBannerImage.isNotEmpty
                          ? Image.network(
                              category.categoryBannerImage,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.category);
                              },
                            )
                          : Icon(Icons.category),
                      title: Text(category.categoryName),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          bool confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Category'),
                              content: Text('Are you sure you want to delete this category?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ) ?? false;

                          if (confirm) {
                            await _categoryService.deleteCategory(category.categoryId);
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Brands Tab
          StreamBuilder<List<Brand>>(
            stream: _brandService.getAllBrands(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final brands = snapshot.data ?? [];

              return ListView.builder(
                itemCount: brands.length,
                itemBuilder: (context, index) {
                  final brand = brands[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.branding_watermark),
                      title: Text(brand.brandName),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          bool confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Brand'),
                              content: Text('Are you sure you want to delete this brand?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ) ?? false;

                          if (confirm) {
                            await _brandService.deleteBrand(brand.brandId);
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          if (_tabController == null) return;
          switch (_tabController!.index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProduct()),
              );
              break;
            case 1:
              _addCategory();
              break;
            case 2:
              _addBrand();
              break;
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
