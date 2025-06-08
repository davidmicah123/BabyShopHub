import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WishlistProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _wishlistItems = [];
  static const String _wishlistKey = 'wishlist_items';

  WishlistProvider() {
    _loadWishlistItems();
  }

  List<Map<String, dynamic>> get wishlistItems => _wishlistItems;

  Future<void> _loadWishlistItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getString(_wishlistKey);
      if (wishlistJson != null) {
        final List<dynamic> decodedWishlist = json.decode(wishlistJson);
        _wishlistItems = decodedWishlist.cast<Map<String, dynamic>>();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading wishlist items: $e');
    }
  }

  Future<void> _saveWishlistItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = json.encode(_wishlistItems);
      await prefs.setString(_wishlistKey, wishlistJson);
    } catch (e) {
      print('Error saving wishlist items: $e');
    }
  }

  Future<void> addToWishlist(Map<String, dynamic> product) async {
    if (!_wishlistItems.any((item) => item['product_id'] == product['product_id'])) {
      _wishlistItems.add(product);
      await _saveWishlistItems();
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    _wishlistItems.removeWhere((item) => item['product_id'] == productId);
    await _saveWishlistItems();
    notifyListeners();
  }

  bool isItemInWishlist(String productId) {
    return _wishlistItems.any((item) => item['product_id'] == productId);
  }
}
