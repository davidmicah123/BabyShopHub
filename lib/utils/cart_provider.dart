import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];
  static const String _cartKey = 'cart_items';

  CartProvider() {
    _loadCartItems();
  }

  List<Map<String, dynamic>> get cartItems => _cartItems;

  Future<void> _loadCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      if (cartJson != null) {
        final List<dynamic> decodedCart = json.decode(cartJson);
        _cartItems = decodedCart.cast<Map<String, dynamic>>();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cart items: $e');
    }
  }

  Future<void> _saveCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(_cartItems);
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      print('Error saving cart items: $e');
    }
  }

  Future<void> addToCart(Map<String, dynamic> product) async {
    final existingIndex = _cartItems.indexWhere(
      (item) => item['product_id'] == product['product_id'],
    );

    if (existingIndex != -1) {
      _cartItems[existingIndex]['quantity'] = 
          (_cartItems[existingIndex]['quantity'] as int) + 1;
    } else {
      _cartItems.add(product);
    }

    await _saveCartItems();
    notifyListeners();
  }

  Future<void> removeFromCart(String productId) async {
    _cartItems.removeWhere((item) => item['product_id'] == productId);
    await _saveCartItems();
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int change) async {
    final index = _cartItems.indexWhere(
      (item) => item['product_id'] == productId,
    );

    if (index != -1) {
      final newQuantity = (_cartItems[index]['quantity'] as int) + change;
      if (newQuantity > 0) {
        _cartItems[index]['quantity'] = newQuantity;
      } else {
        _cartItems.removeAt(index);
      }
      await _saveCartItems();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    await _saveCartItems();
    notifyListeners();
  }

  double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) {
      final price = double.tryParse(
        item['price'].toString().replaceAll('₦', ''),
      ) ?? 0.0;
      final quantity = item['quantity'] as int? ?? 1;
      return sum + (price * quantity);
    });
  }

  bool isItemInCart(String productId) {
    return _cartItems.any((item) => item['product_id'] == productId);
  }
}
