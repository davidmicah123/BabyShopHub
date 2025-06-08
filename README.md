Baby Shop Hub
A complete mobile application built with Flutter, designed to connect parents with a wide range of baby products. Baby Shop Hub offers a seamless shopping experience for users and a robust administration panel for efficient product management.
Table of Contents
 * About Baby Shop Hub
 * Features
   * User App Features
   * Admin Panel Features
 * Screenshots
 * Getting Started
   * Prerequisites
   * Installation
  
About Baby Shop Hub
Baby Shop Hub is a dual-interface mobile application aimed at simplifying the process of buying and selling baby products. The user-facing application provides a smooth, intuitive e-commerce experience, allowing customers to browse, search, and purchase items. The admin panel empowers store owners or managers to effortlessly add new products, update existing ones, manage orders, and oversee the inventory. Built with Flutter, Baby Shop Hub is designed to be performant, visually appealing, and cross-platform compatible.
Features
User App Features
 * Product Browse: Explore a wide variety of baby products categorized for easy navigation.
 * Product Search: Quickly find specific items using the powerful search functionality.
 * Product Details: View comprehensive details about each product, including descriptions, images, prices, and available variations.
 * Shopping Cart: Add desired products to a persistent shopping cart.
 * Secure Checkout: A streamlined and secure checkout process (integrates with payment gateway - mention if you have one, e.g., Stripe, Paystack, Flutterwave).
 * Order History: Users can view their past orders and track their status.
 * User Authentication: Secure user registration and login.
 * User Profiles: Manage personal information and shipping addresses.
 * Wishlist (Optional/Future): Save favorite products for later purchase.
 * Product Reviews & Ratings (Optional/Future): Allow users to review purchased items.
Admin Panel Features
 * Dashboard: An overview of sales, orders, and product statistics.
 * Product Management:
   * Add new products with detailed information (name, description, price, images, categories, stock, etc.).
   * Edit existing product details.
   * Delete products.
   * Manage product categories.
   * Control product visibility.
 * Order Management:
   * View all incoming orders.
   * Update order statuses (e.g., Pending, Processing, Shipped, Delivered, Canceled).
   * View order details, including customer information and purchased items.
 * User Management (Optional/Future): View and manage registered users.
 * Sales Reports (Optional/Future): Generate reports on sales performance.



Before you begin, ensure you have the following installed:
 * Flutter SDK: Install Flutter
 * Dart SDK: (Comes with Flutter)
 * Git: Install Git
 * IDE: Visual Studio Code with Flutter and Dart plugins, or Android Studio with Flutter and Dart plugins.
    * If using Firebase: Ensure you have a Firebase project set up and have configured your google-services.json (Android) and GoogleService-Info.plist (iOS) files.
   
 * Clone the repository:
   git clone https://github.com/your-username/baby-shop-hub.git
cd baby-shop-hub

 * Install dependencies:
   flutter pub get

 * Configure your backend:
   * For Firebase:
     * Place your google-services.json file in android/app/.
     * Place your GoogleService-Info.plist file in ios/Runner/.
     * Ensure your Firebase project is properly set up with Firestore, Authentication, Storage (if used for images), etc.
   