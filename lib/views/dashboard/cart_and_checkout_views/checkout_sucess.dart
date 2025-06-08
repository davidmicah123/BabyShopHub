import 'package:flutter/material.dart';
import '../dashboard_screen.dart';

class OrderSuccessful extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderSuccessful({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Order Successful',
          style: TextStyle(
            color: Color(0xFF272727),
            fontSize: 20,
            fontFamily: 'Circular Std',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Order ${orderData['orderId']} has been placed!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF272727),
                ),
              ),
              const SizedBox(height: 16),
              _buildOrderSummary(),
              const SizedBox(height: 24),
              _buildShippingDetails(),
              const SizedBox(height: 24),
              _buildPaymentDetails(),
              const SizedBox(height: 32),
              _buildContinueShoppingButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    // Calculate total amount by summing up (price * quantity) for each item
    double totalAmount = 0;
    for (var item in orderData['items']) {
      double price = 0;
      if (item['price'] is num) {
        price = (item['price'] as num).toDouble();
      } else if (item['price'] is String) {
        // Remove the ₦ symbol and convert to double
        price = double.tryParse(item['price'].toString().replaceAll('₦', '')) ?? 0;
      }
      int quantity = item['quantity'] ?? 1;
      totalAmount += price * quantity;
    }

    // Add shipping and tax
    totalAmount += (orderData['shippingCost'] as num).toDouble();
    totalAmount += (orderData['tax'] as num).toDouble();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF272727),
              ),
            ),
            const SizedBox(height: 10),
            ...(orderData['items'] as List).map((item) {
              double itemPrice = 0;
              if (item['price'] is num) {
                itemPrice = (item['price'] as num).toDouble();
              } else if (item['price'] is String) {
                itemPrice = double.tryParse(item['price'].toString().replaceAll('₦', '')) ?? 0;
              }
              int quantity = item['quantity'] ?? 1;
              double itemTotal = itemPrice * quantity;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item['name']} (x$quantity)'),
                    Text('₦${itemTotal.toStringAsFixed(2)}'),
                  ],
                ),
              );
            }).toList(),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text('₦${(totalAmount - (orderData['shippingCost'] as num).toDouble() - (orderData['tax'] as num).toDouble()).toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Shipping'),
                Text('₦${(orderData['shippingCost'] as num).toDouble().toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tax'),
                Text('₦${(orderData['tax'] as num).toDouble().toStringAsFixed(2)}'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '₦${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingDetails() {
    // Implementation of _buildShippingDetails method
    return Text('Shipping Details');
  }

  Widget _buildPaymentDetails() {
    // Implementation of _buildPaymentDetails method
    return Text('Payment Details');
  }

  Widget _buildContinueShoppingButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8E6CEE),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        'Continue Shopping',
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
