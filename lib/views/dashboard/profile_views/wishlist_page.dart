import 'package:flutter/material.dart';
import '../../../utils/wishlist_functionalities.dart';
import 'wishlist_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:BabyShop/utils/app_colors.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final wishlistItems =
        wishlistProvider.wishlistItems; // Use the correct getter name

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Wishlist"),
        centerTitle: true,
      ),
      body: wishlistItems.isEmpty
          ? _buildEmptyWishlist(context)
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  final item = wishlistItems[index];
                  return WishlistItem(
                    title: item['name'] ?? 'Unknown Product',
                    subtitle: item['category'] ?? 'No Category',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WishlistDetailPage(
                            product: item,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyWishlist(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          height: screenHeight * 0.8,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Empty wishlist illustration
              Container(
                width: screenWidth * 0.4,
                height: screenWidth * 0.4,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: NetworkImage(
                      "https://images.unsplash.com/photo-1585928634767-4c5dde5c6b73?w=400&q=80", // Placeholder image
                    ),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 24),

              // Empty wishlist text
              const Text(
                'Your Wishlist is Empty',
                style: TextStyle(
                  color: Color(0xFF272727),
                  fontSize: 24,
                  fontFamily: 'Circular Std',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle text
              const Text(
                'Browse our categories and add items to your wishlist!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 16,
                  fontFamily: 'Circular Std',
                ),
              ),
              const SizedBox(height: 32),

              // Explore button
              InkWell(
                onTap: () {
                  // Navigate to categories
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: ShapeDecoration(
                    color: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Start Shopping',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Circular Std',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WishlistItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const WishlistItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.favorite_border),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
