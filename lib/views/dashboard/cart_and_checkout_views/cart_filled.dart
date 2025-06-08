import 'package:flutter/material.dart';
import 'package:BabyShop/utils/cart_provider.dart';
import 'package:provider/provider.dart';
import '../../../utils/cart_functionalities.dart';
import 'checkout.dart';

class CartFilled extends StatelessWidget {
  const CartFilled({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final screenWidth = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: Color(0xFF272727),
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Cart',
              style: TextStyle(
                color: Color(0xFF272727),
                fontSize: 20,
                fontFamily: 'Circular Std',
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Show confirmation dialog before removing all items
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Remove All Items'),
                        content: const Text('Are you sure you want to remove all items from your cart?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              cartProvider.clearCart();
                              Navigator.pop(context);
                            },
                            child: const Text('Remove All'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text(
                  'Remove All',
                  style: TextStyle(
                    color: Color(0xFF272727),
                    fontSize: 16,
                    fontFamily: 'Circular Std',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    ...cartProvider.cartItems
                        .map((item) => Column(
                              children: [
                                _buildCartItem(
                                  image: item['image'] ?? '',
                                  name: item['name'] ?? '',
                                  price: item['price'] is num 
                                      ? '₦${(item['price'] as num).toStringAsFixed(2)}'
                                      : item['price']?.toString() ?? '₦0.00',
                                  size: 'M',
                                  color: 'Default',
                                  productId: item['product_id'] ?? '',
                                  quantity: item['quantity'] ?? 1,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ))
                        .toList(),
                    _buildOrderSummary(cartProvider),
                    const SizedBox(height: 16),
                    _buildCouponField(),
                    const SizedBox(height: 24),
                    _buildCheckoutButton(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartItem({
    required String image,
    required String name,
    required String price,
    required String size,
    required String color,
    required String productId,
    required int quantity,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              image,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Color(0xFF272727),
                          fontSize: 12,
                          fontFamily: 'Circular Std',
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      price,
                      style: const TextStyle(
                        color: Color(0xFF272727),
                        fontSize: 12,
                        fontFamily: 'Gabarito',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildItemDetail("Size", size),
                        const SizedBox(width: 12),
                        _buildItemDetail("Color", color),
                      ],
                    ),
                    _buildQuantityControls(productId, quantity),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetail(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0x7F272727),
            fontSize: 12,
            fontFamily: 'Circular Std',
            fontWeight: FontWeight.w400,
          ),
        ),
        const Text(" - "),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF272727),
            fontSize: 12,
            fontFamily: 'Gabarito',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls(String productId, int quantity) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Row(
          children: [
            InkWell(
              onTap: () => cartProvider.updateQuantity(productId, -1),
              child: _buildQuantityButton(Icons.remove),
            ),
            const SizedBox(width: 8),
            Text(quantity.toString()),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => cartProvider.updateQuantity(productId, 1),
              child: _buildQuantityButton(Icons.add),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuantityButton(IconData icon) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFF8E6CEE),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    // Calculate subtotal by summing up (price * quantity) for each item
    double subtotal = 0;
    for (var item in cartProvider.cartItems) {
      double price = 0;
      if (item['price'] is num) {
        price = (item['price'] as num).toDouble();
      } else if (item['price'] is String) {
        // Remove the ₦ symbol and convert to double
        price = double.tryParse(item['price'].toString().replaceAll('₦', '')) ?? 0;
      }
      int quantity = item['quantity'] ?? 1;
      subtotal += price * quantity;
    }

    final shippingCost = 8.00;
    final tax = 0.00;
    final total = subtotal + shippingCost + tax;

    return Column(
      children: [
        _buildSummaryRow("Subtotal", "₦${subtotal.toStringAsFixed(2)}"),
        _buildSummaryRow("Shipping Cost", "₦${shippingCost.toStringAsFixed(2)}"),
        _buildSummaryRow("Tax", "₦${tax.toStringAsFixed(2)}"),
        _buildSummaryRow("Total", "₦${total.toStringAsFixed(2)}", isTotal: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              // ignore: deprecated_member_use
              color: const Color(0xFF272727).withOpacity(0.5),
              fontSize: 16,
              fontFamily: 'Circular Std',
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: const Color(0xFF272727),
              fontSize: 16,
              fontFamily: isTotal ? 'Gabarito' : 'Circular Std',
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8E6CEE),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(Icons.local_offer, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          const Text(
            'Enter Coupon Code',
            style: TextStyle(
              color: Color(0x7F272727),
              fontSize: 12,
              fontFamily: 'Circular Std',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return GestureDetector(
          onTap: () {
            if (cartProvider.cartItems.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Your cart is empty')),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Checkout(
                  cartItems: cartProvider.cartItems,
                  subtotal: cartProvider.totalAmount,
                  shippingCost: 8.00,
                  tax: 0.00,
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF8E6CEE),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text(
              'Checkout',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Circular Std',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      },
    );
  }
}
