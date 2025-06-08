import 'package:flutter/material.dart';
import 'cart_provider.dart';
import 'wishlist_functionalities.dart';

class ProductStatusProvider extends ChangeNotifier {
  final CartProvider cartProvider;
  final WishlistProvider wishlistProvider;

  ProductStatusProvider(this.cartProvider, this.wishlistProvider);

  void updateProviders(CartProvider cartProvider, WishlistProvider wishlistProvider) {
    notifyListeners();
  }

  bool isItemInCart(String productId) {
    return cartProvider.isItemInCart(productId);
  }

  bool isItemInWishlist(String productId) {
    return wishlistProvider.isItemInWishlist(productId);
  }
} 