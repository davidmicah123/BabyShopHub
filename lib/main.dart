import 'package:flutter/material.dart';
import 'package:BabyShop/views/onboarding/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'services/cloudinary_service.dart';
import 'services/admin_service.dart';
import 'utils/cart_functionalities.dart' as cart_func;
import 'utils/cart_provider.dart';
import 'utils/wishlist_functionalities.dart';
import 'dart:io';
import 'utils/product_status_provider.dart';
import 'package:BabyShop/views/dashboard/dashboard_screen.dart';
import 'utils/app_colors.dart';

void main() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();
    
    print('Loading environment variables...');
    // Load environment variables
    try {
      await dotenv.load(fileName: ".env");
      print('Environment variables loaded successfully');
    } catch (e) {
      print('Warning: Could not load .env file: $e');
      print('Continuing without environment variables...');
    }
    
    print('Initializing Firebase...');
    // Initialize Firebase
    try {
      await Firebase.initializeApp();
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
      // Show error screen if Firebase fails to initialize
      runApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to initialize Firebase',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      return;
    }

    print('Initializing admin account...');
    // Initialize admin account
    final adminService = AdminService();
    try {
      await adminService.initializeAdminAccount();
      print('Admin account initialized successfully');
    } catch (e) {
      print('Error initializing admin account: $e');
      // Continue app execution even if admin initialization fails
    }

    print('Starting app...');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => WishlistProvider()),
          ChangeNotifierProxyProvider2<CartProvider, WishlistProvider,
              ProductStatusProvider>(
            create: (context) => ProductStatusProvider(
              Provider.of<CartProvider>(context, listen: false),
              Provider.of<WishlistProvider>(context, listen: false),
            ),
            update: (_, cartProvider, wishlistProvider, productStatusProvider) =>
                productStatusProvider!
                  ..updateProviders(cartProvider, wishlistProvider),
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Fatal error during app initialization: $e');
    // Show a more detailed error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to initialize app',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laptop Harbor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: AppColors.primarySwatch,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}
