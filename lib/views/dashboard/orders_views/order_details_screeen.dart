import 'package:flutter/material.dart';
import 'package:BabyShop/utils/app_colors.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailsScreen({
    super.key,
    required this.orderData,
  });

  // Helper function to format price
  String formatPrice(dynamic value) {
    if (value == null) return '0.00';
    if (value is num) return value.toStringAsFixed(2);
    if (value is String) {
      final numericValue = double.tryParse(value.replaceAll('₦', '')) ?? 0;
      return numericValue.toStringAsFixed(2);
    }
    return '0.00';
  }

  // Calculate totals from items
  double calculateSubtotal() {
    double subtotal = 0;
    final items = orderData['items'] as List;
    for (var item in items) {
      double price = 0;
      if (item['price'] is num) {
        price = (item['price'] as num).toDouble();
      } else if (item['price'] is String) {
        price = double.tryParse(item['price'].toString().replaceAll('₦', '')) ?? 0;
      }
      int quantity = item['quantity'] as int? ?? 1;
      subtotal += price * quantity;
    }
    return subtotal;
  }

  // Get shipping cost
  double getShippingCost() {
    if (orderData['shippingCost'] is num) {
      return (orderData['shippingCost'] as num).toDouble();
    } else if (orderData['shippingCost'] is String) {
      return double.tryParse(orderData['shippingCost'].toString().replaceAll('₦', '')) ?? 0;
    }
    return 0;
  }

  // Get tax amount
  double getTaxAmount() {
    if (orderData['tax'] is num) {
      return (orderData['tax'] as num).toDouble();
    } else if (orderData['tax'] is String) {
      return double.tryParse(orderData['tax'].toString().replaceAll('₦', '')) ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Order ${orderData['orderId']}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderStatus(),
              const SizedBox(height: 24),
              _buildOrderItems(),
              const SizedBox(height: 24),
              _buildShippingDetails(),
              const SizedBox(height: 24),
              _buildPaymentDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF272727),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                Icons.local_shipping,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                orderData['status'] ?? 'Processing',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems() {
    final items = orderData['items'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Items',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF272727),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(item['image'] ?? ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₦${formatPrice(item['price'])}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quantity: ${item['quantity']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildShippingDetails() {
    final shipping = orderData['shipping'] as Map<String, dynamic>?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF272727),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                shipping?['name'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                shipping?['address'] ?? '',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                shipping?['phone'] ?? '',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    final payment = orderData['payment'] as Map<String, dynamic>?;
    
    // Calculate values
    final subtotal = calculateSubtotal();
    final shipping = getShippingCost();
    final tax = getTaxAmount();
    final total = subtotal + shipping + tax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF272727),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Card Number',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    payment?['cardNumber'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cardholder',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    payment?['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expires',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    payment?['exp'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    '₦${subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shipping',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    '₦${shipping.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tax',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    '₦${tax.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₦${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
