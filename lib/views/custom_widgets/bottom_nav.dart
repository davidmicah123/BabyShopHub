import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:BabyShop/views/dashboard/notification_views/notification_screen.dart';
// ignore: unused_import
import 'package:BabyShop/views/dashboard/orders_views/orders_screen.dart';
// Add import for ProfileScreen
// ignore: unused_import
import 'package:BabyShop/views/dashboard/profile_views/profile_screen.dart'; // New import

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNav({
    super.key,
    this.selectedIndex = 0,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: screenWidth,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.home_outlined, 'Home'),
                      _buildNavItem(
                          1, Icons.notifications_outlined, 'Notifications'),
                      _buildNavItem(2, Icons.receipt_long_outlined, 'Orders'),
                      _buildNavItem(3, Icons.person_outline, 'Profile'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = index == selectedIndex;
    return InkWell(
      onTap: () => onItemTapped(index),
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(8),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          color: isSelected
              // ignore: deprecated_member_use
              ? const Color(0xFF8E6CEE).withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF8E6CEE) : const Color(0xFF272727),
          size: 24,
        ),
      ),
    );
  }
}
