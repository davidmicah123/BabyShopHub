import 'package:flutter/material.dart';
import 'package:BabyShop/utils/cart_provider.dart';
import 'package:provider/provider.dart';
import '../../../utils/cart_functionalities.dart';
import '../profile_views/address_page.dart';
import '../profile_views/payment_page.dart';
import 'checkout_sucess.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Checkout extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double shippingCost;
  final double tax;

  const Checkout({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
  });

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  Map<String, dynamic>? selectedAddress;
  Map<String, dynamic>? selectedPayment;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });
    await Future.wait([
      _loadDefaultAddress(),
      _loadDefaultPayment(),
    ]);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadDefaultAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressStrings = prefs.getStringList('userAddresses') ?? [];
      if (addressStrings.isNotEmpty) {
        if (mounted) {
          setState(() {
            selectedAddress = json.decode(addressStrings.first);
          });
        }
      }
    } catch (e) {
      print('Error loading default address: $e');
    }
  }

  Future<void> _loadDefaultPayment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardStrings = prefs.getStringList('userCards') ?? [];
      if (cardStrings.isNotEmpty) {
        if (mounted) {
          setState(() {
            selectedPayment = json.decode(cardStrings.first);
          });
        }
      }
    } catch (e) {
      print('Error loading default payment: $e');
    }
  }

  Future<void> _navigateToAddressPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressPage()),
    );
    if (result != null) {
      setState(() {
        selectedAddress = result;
      });
    } else {
      // If no result but we should check for updates
      await _loadDefaultAddress();
    }
  }

  Future<void> _navigateToPaymentPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentPage()),
    );
    if (result != null) {
      setState(() {
        selectedPayment = result;
      });
    } else {
      // If no result but we should check for updates
      await _loadDefaultPayment();
    }
  }

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
              'Checkout',
              style: TextStyle(
                color: Color(0xFF272727),
                fontSize: 20,
                fontFamily: 'Circular Std',
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            'Shipping Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF272727),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Shipping Address Container
                          GestureDetector(
                            onTap: _navigateToAddressPage,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F4F4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selectedAddress == null ? Colors.red : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Shipping Address',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF272727),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8E6CEE),
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (selectedAddress != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${selectedAddress!['street']}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF272727),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${selectedAddress!['city']}, ${selectedAddress!['state']} ${selectedAddress!['zip']}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF272727),
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Text(
                                      'Add shipping address',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF272727),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Payment Method Container
                          GestureDetector(
                            onTap: _navigateToPaymentPage,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F4F4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selectedPayment == null ? Colors.red : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Payment Details',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF272727),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8E6CEE),
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (selectedPayment != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.credit_card, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          '**** ${selectedPayment!['cardNumber'].toString().substring(selectedPayment!['cardNumber'].toString().length - 4)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF272727),
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Text(
                                      'Add payment method',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Order Items',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF272727),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Cart Items
                          ...widget.cartItems.map((item) => Column(
                            children: [
                              _buildCartItem(
                                image: item['image'] ?? '',
                                name: item['name'] ?? '',
                                price: item['price'] ?? '',
                                size: item['size'] ?? 'M',
                                color: item['color'] ?? 'Default',
                                productId: item['product_id'] ?? '',
                                quantity: item['quantity'] ?? 1,
                              ),
                              const SizedBox(height: 16),
                            ],
                          )).toList(),
                          const SizedBox(height: 24),
                          _buildOrderSummary(
                            widget.subtotal,
                            widget.shippingCost,
                            widget.tax,
                          ),
                          const SizedBox(height: 16),
                          _buildCouponField(),
                          const SizedBox(height: 24),
                          _buildPlaceOrderButton(context, cartProvider),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildAddressCard({
    required String address,
    required String name,
    required String phone,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              address,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              phone,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
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
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              image,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
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

  Widget _buildOrderSummary(double subtotal, double shipping, double tax) {
    // Calculate subtotal by summing up (price * quantity) for each item
    double calculatedSubtotal = 0;
    for (var item in widget.cartItems) {
      double price = 0;
      if (item['price'] is num) {
        price = (item['price'] as num).toDouble();
      } else if (item['price'] is String) {
        // Remove the ₦ symbol and convert to double
        price = double.tryParse(item['price'].toString().replaceAll('₦', '')) ?? 0;
      }
      int quantity = item['quantity'] ?? 1;
      calculatedSubtotal += price * quantity;
    }

    final total = calculatedSubtotal + shipping + tax;
    return Column(
      children: [
        _buildSummaryRow("Subtotal", "₦${calculatedSubtotal.toStringAsFixed(2)}"),
        _buildSummaryRow("Shipping Cost", "₦${shipping.toStringAsFixed(2)}"),
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

  Widget _buildPlaceOrderButton(
      BuildContext context, CartProvider cartProvider) {
    // Calculate total amount
    double totalAmount = widget.subtotal + widget.shippingCost + widget.tax;

    return GestureDetector(
      onTap: () async {
        if (selectedAddress == null || selectedPayment == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Please select both shipping address and payment method')),
          );
          return;
        }

        // Create order data with proper structure
        final orderData = {
          'orderId': '#${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          'items': widget.cartItems.map((item) {
            double price = 0;
            if (item['price'] is num) {
              price = (item['price'] as num).toDouble();
            } else if (item['price'] is String) {
              price = double.tryParse(item['price'].toString().replaceAll('₦', '')) ?? 0;
            }
            return {
              'name': item['name'],
              'price': price,
              'quantity': item['quantity'],
              'image': item['image'],
              'size': item['size'],
              'color': item['color'],
              'product_id': item['product_id'],
            };
          }).toList(),
          'subtotal': widget.subtotal,
          'shippingCost': widget.shippingCost,
          'tax': widget.tax,
          'total': totalAmount,
          'shipping': {
            'name': selectedAddress!['name'],
            'address': '${selectedAddress!['street']}, ${selectedAddress!['city']}, ${selectedAddress!['state']} ${selectedAddress!['zip']}',
            'phone': selectedAddress!['phone'],
          },
          'payment': {
            'cardNumber': '**** ${selectedPayment!['cardNumber'].toString().substring(selectedPayment!['cardNumber'].toString().length - 4)}',
            'name': selectedPayment!['name'],
            'exp': selectedPayment!['exp'],
            'subtotal': widget.subtotal,
            'shipping': widget.shippingCost,
            'tax': widget.tax,
            'total': totalAmount,
          },
          'status': 'Processing',
          'date': DateTime.now().toString(),
        };

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        List<String> orders = prefs.getStringList('orders') ?? [];
        orders.add(json.encode(orderData));
        await prefs.setStringList('orders', orders);

        // Add notification
        List<String> notifications = prefs.getStringList('notifications') ?? [];
        notifications.insert(
            0,
            json.encode({
              'icon': 'notifications_active',
              'text': 'Your order ${orderData['orderId']} has been placed successfully.',
              'date': DateTime.now().toString(),
              'isRead': false,
            }));
        await prefs.setStringList('notifications', notifications);

        // Clear the cart
        cartProvider.clearCart();

        // Navigate to success page
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => OrderSuccessful(orderData: orderData),
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
          'Place Order',
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
  }
}

class InputField extends StatelessWidget {
  final String label;

  const InputField({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 18)),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter $label',
              border: OutlineInputBorder(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Add functionality here for the button
            },
            child: Text('Add $label'),
          ),
        ],
      ),
    );
  }
}

// Main method to run the app
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(), // Ensure CartProvider is initialized
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // Disable debug banner
        home: const Checkout(
          cartItems: [],
          subtotal: 0.0,
          shippingCost: 8.00,
          tax: 0.00,
        ),
      ),
    ),
  );
}

