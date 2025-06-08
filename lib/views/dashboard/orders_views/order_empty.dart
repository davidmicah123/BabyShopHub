import 'package:flutter/material.dart';
import 'package:BabyShop/views/dashboard/orders_views/orders_screen.dart';
import 'package:BabyShop/utils/app_colors.dart';

// class EmptyOrdersScreen extends StatelessWidget {
//   const EmptyOrdersScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF4F4F4),
//               borderRadius: BorderRadius.circular(100),
//             ),
//             child: const Icon(
//               Icons.arrow_back_ios,
//               size: 16,
//               color: Color(0xFF272727),
//             ),
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Orders',
//           style: TextStyle(
//             color: Color(0xFF272727),
//             fontSize: 20,
//             fontFamily: 'Circular Std',
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Container(
//             width: screenWidth,
//             height: screenHeight * 0.8,
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Empty orders illustration
//                 Container(
//                   width: screenWidth * 0.4,
//                   height: screenWidth * 0.4,
//                   decoration: BoxDecoration(
//                     image: const DecorationImage(
//                       image: NetworkImage(
//                         "https://images.unsplash.com/photo-1600880292203-757bb62b4baf?w=400&q=80", // Order box illustration
//                       ),
//                       fit: BoxFit.cover,
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // Empty orders text
//                 const Text(
//                   'No Orders Yet',
//                   style: TextStyle(
//                     color: Color(0xFF272727),
//                     fontSize: 24,
//                     fontFamily: 'Circular Std',
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 12),

//                 // Subtitle text
//                 const Text(
//                   'Start shopping and make your first order!',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Color(0xFF666666),
//                     fontSize: 16,
//                     fontFamily: 'Circular Std',
//                   ),
//                 ),
//                 const SizedBox(height: 32),

//                 // Start shopping button
//                 InkWell(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const OrdersScreen()),
//                     );
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 32,
//                       vertical: 16,
//                     ),
//                     decoration: ShapeDecoration(
//                       color: AppColors.primary,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(100),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Text(
//                           'Start Shopping',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontFamily: 'Circular Std',
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.arrow_forward,
//                             color: Colors.white,
//                             size: 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
