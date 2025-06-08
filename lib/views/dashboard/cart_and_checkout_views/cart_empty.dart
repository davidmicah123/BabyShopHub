import 'package:flutter/material.dart';

class EmptyCart extends StatelessWidget {
  const EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: Color(0xFF272727),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cart',
          style: TextStyle(
            color: Color(0xFF272727),
            fontSize: 20,
            fontFamily: 'Circular Std',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth,
            height: screenHeight * 0.8,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Empty cart illustration
                Container(
                  width: screenWidth * 0.4,
                  height: screenWidth * 0.4,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: NetworkImage(
                        "https://images.unsplash.com/photo-1585928634767-4c5dde5c6b73?w=400&q=80", // Empty cart illustration from Unsplash
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 24),

                // Empty cart text
                const Text(
                  'Your Cart is Empty',
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
                  'Browse our categories and discover our best deals!',
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
                      color: const Color(0xFF8E6CEE),
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
      ),
    );
  }
}
