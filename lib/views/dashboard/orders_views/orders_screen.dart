import 'package:flutter/material.dart';
import 'package:BabyShop/views/dashboard/orders_views/order_details_screeen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:BabyShop/utils/app_colors.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Changed to 2 tabs
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final orderStrings = prefs.getStringList('orders') ?? [];
    setState(() {
      orders = orderStrings
          .map((str) => json.decode(str) as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Orders",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: TabBar(
            controller: _tabController,
            isScrollable: true, // Make tabs scrollable
            labelColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            labelPadding: const EdgeInsets.symmetric(horizontal: 40),
            unselectedLabelColor: Colors.black54,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.primary,
            ),
            indicatorSize: TabBarIndicatorSize
                .tab, // Ensure the indicator covers the entire tab
            tabs: const [
              Tab(text: "Processing"),
              Tab(text: "Shipped"),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(2, (index) => _buildOrderList(context)),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context) {
    final filteredOrders = orders.where((order) {
      final status = order['status'] as String;
      switch (_tabController.index) {
        case 0:
          return status == 'Processing';
        case 1:
          return status == 'Shipped';
        default:
          return false;
      }
    }).toList();

    return filteredOrders.isEmpty
        ? SafeArea(
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Orders Yet',
                      style: TextStyle(
                        color: Color(0xFF272727),
                        fontSize: 24,
                        fontFamily: 'Circular Std',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your orders will appear here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 16,
                        fontFamily: 'Circular Std',
                      ),
                    ),
                    const SizedBox(height: 32),
                    InkWell(
                      onTap: () => _loadOrders(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: ShapeDecoration(
                          color: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Refresh',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Circular Std',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsScreen(
                        orderData: order,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_long, size: 30),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Order ${order['orderId']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${(order['items'] as List).length} items",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
