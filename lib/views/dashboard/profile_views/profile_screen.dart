// ignore_for_file: use_build_context_synchronously, empty_catches

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'address_page.dart';
import 'payment_page.dart';
import 'wishlist_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../authentication/sign_in.dart';
import 'add_address_page.dart';
import 'add_card_page.dart';
import 'help_page.dart';
import 'package:BabyShop/utils/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool showSignOutModal = true;
  String? firstName;
  String? lastName;
  String? email;
  String? profileImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadUserData();
    _loadProfileImage();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      showSignOutModal = prefs.getBool('showSignOutModal') ?? true;
      profileImagePath = prefs.getString('profileImagePath');
    });
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
            firstName = userDoc.data()?['firstName'];
            lastName = userDoc.data()?['lastName'];
            email = userDoc.data()?['email'] ?? user.email;
          });
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImagePath = prefs.getString('profileImagePath');
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImagePath', image.path);
        setState(() {
          profileImagePath = image.path;
        });
      }
    } catch (e) {}
  }

  Future<void> _showSignOutConfirmation() async {
    if (!showSignOutModal) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      }
      return;
    }

    bool dontShowAgain = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirm Sign Out',
            style: TextStyle(color: Colors.black)),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to sign out?',
                  style: TextStyle(color: Colors.black)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: dontShowAgain,
                    onChanged: (value) {
                      setState(() => dontShowAgain = value!);
                    },
                  ),
                  const Text("Don't show this again",
                      style: TextStyle(color: Colors.black)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      if (dontShowAgain) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('showSignOutModal', false);
      }
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 50),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: profileImagePath != null
                      ? FileImage(File(profileImagePath!))
                      : null,
                  child: profileImagePath == null
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${firstName ?? ''} ${lastName ?? ''}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            email ?? "",
            style: const TextStyle(color: Colors.grey),
          ),
          const Text(
            "121-224-7890",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          _buildProfileOption(context, "Address", () {}),
          _buildProfileOption(context, "Wishlist", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WishlistPage()),
            );
          }),
          _buildProfileOption(context, "Payment", () {}),
          _buildProfileOption(context, "Help & Support", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HelpPage()),
            );
          }),
          TextButton(
            onPressed: _showSignOutConfirmation,
            child: const Text(
              "Sign Out",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
      BuildContext context, String title, VoidCallback onTap) {
    if (title == "Address") {
      return ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          final hasAddress =
              prefs.getStringList('userAddresses')?.isNotEmpty ?? false;

          if (!hasAddress) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddAddressPage()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddressPage()),
            );
          }
        },
      );
    } else if (title == "Payment") {
      return ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          final hasCards =
              prefs.getStringList('userCards')?.isNotEmpty ?? false;

          if (!hasCards) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddCardPage()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaymentPage()),
            );
          }
        },
      );
    }

    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
