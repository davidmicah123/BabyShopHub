import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class CartFunctionalities {
  static void addToCart(BuildContext context, Map<String, dynamic> product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addToCart(product);
  }

  static void removeFromCart(BuildContext context, String productId) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.removeFromCart(productId);
  }

  static void updateQuantity(BuildContext context, String productId, int change) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.updateQuantity(productId, change);
  }

  static void clearCart(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.clearCart();
  }
}
