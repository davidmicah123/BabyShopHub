// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print

import 'dart:math';

import 'package:flutter/material.dart';
// ignore: unused_import
import '../dashboard/home_views/home_screen.dart';
import '../dashboard/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
// ignore: unnecessary_import
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class AccountSetUp extends StatefulWidget {
  const AccountSetUp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AccountSetUpState createState() => _AccountSetUpState();
}

class _AccountSetUpState extends State<AccountSetUp> {
  String _firstName = 'User';
  List<Map<String, dynamic>> categories = [];
  String? selectedCategory;
  String? selectedQuickNav;
  bool? hasPreference;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCategories();
    _checkPreference();
  }

  Future<void> _checkPreference() async {
    final prefs = await SharedPreferences.getInstance();
    hasPreference = prefs.getBool('has_preference') ?? false;
    if (hasPreference == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _firstName = userDoc['firstName'] ?? 'User';
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/prod_data.json');
      final data = json.decode(response);
      setState(() {
        categories = List<Map<String, dynamic>>.from(data['categories']);
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Widget buildCategoryBox(Map<String, dynamic> category) {
    bool isSelected = selectedCategory == category['category_id'];
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = isSelected ? null : category['category_id'];
          });
        },
        child: Container(
          height: MediaQuery.of(context).size.width * 0.25,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: NetworkImage(category['categorybannerimage']),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                isSelected
                    ? Colors.purple.withOpacity(0.3)
                    : Colors.black.withOpacity(0.5),
                BlendMode.overlay,
              ),
            ),
          ),
          child: Center(
            child: Text(
              category['categoryname'],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Circular Std',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildQuickNavBox(String title) {
    bool isSelected = selectedQuickNav == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedQuickNav = isSelected ? null : title;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF8E6CEE) : Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFF272727),
            fontSize: 14,
            fontFamily: 'Circular Std',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Future<void> showPreferenceDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Would you like to save your preferences?',
            style: TextStyle(
              color: Color(0xFF272727),
              fontFamily: 'Circular Std',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('has_preference', false);
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              },
              child: Text('No', style: TextStyle(color: Color(0xFF8E6CEE))),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('has_preference', true);
                await prefs.setString(
                    'selected_category', selectedCategory ?? '');
                await prefs.setString(
                    'selected_quick_nav', selectedQuickNav ?? '');
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              },
              child: Text('Yes', style: TextStyle(color: Color(0xFF8E6CEE))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  // ignore: unnecessary_brace_in_string_interps
                  'Welcome back ${_firstName},\nwhat would you like to purchase today?',
                  style: TextStyle(
                    color: Color(0xFF272727),
                    fontSize: 24,
                    fontFamily: 'Circular Std',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 40),
                // Category Grid
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (var i = 0; i < categories.length; i += 3)
                      Row(
                        children: [
                          for (var j = i;
                              j < min(i + 3, categories.length);
                              j++)
                            buildCategoryBox(categories[j]),
                          if (i + 3 > categories.length)
                            ...List.generate(3 - (categories.length - i),
                                (index) => Expanded(child: SizedBox())),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: 40),
                // Quick Navigation Section
                Text(
                  'Quick Navigate',
                  style: TextStyle(
                    color: Color(0xFF272727),
                    fontSize: 18,
                    fontFamily: 'Circular Std',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildQuickNavBox('Go to Cart'),
                    buildQuickNavBox('Go to Wishlist'),
                    buildQuickNavBox('View Orders'),
                  ],
                ),
                SizedBox(height: screenHeight * 0.1),
                // Action Buttons
                Container(
                  width: screenWidth * 0.9,
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    color: Color(0xFF8E6CEE),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: TextButton(
                    onPressed: showPreferenceDialog,
                    child: const Text(
                      'Finish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Circular Std',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: screenWidth * 0.9,
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    color: Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: TextButton(
                    onPressed: showPreferenceDialog,
                    child: const Text(
                      'Just Casually Browsing',
                      style: TextStyle(
                        color: Color(0xFF272727),
                        fontSize: 16,
                        fontFamily: 'Circular Std',
                        fontWeight: FontWeight.w400,
                      ),
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
