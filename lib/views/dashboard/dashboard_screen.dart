import 'package:flutter/material.dart';
import 'package:BabyShop/views/dashboard/home_views/home_screen.dart';
import 'package:BabyShop/views/dashboard/notification_views/notification_screen_filled.dart';
import 'package:BabyShop/views/dashboard/orders_views/orders_screen.dart';
import 'package:BabyShop/views/custom_widgets/bottom_nav.dart';
import 'package:BabyShop/views/dashboard/profile_views/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // List of screens to show based on bottom nav selection
  final List<Widget> _screens = [
    HomeScreen(),
    const NotificationListScreen(),
    const OrdersScreen(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
