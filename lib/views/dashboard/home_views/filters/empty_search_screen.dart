import 'package:flutter/material.dart';
import '../../home_views/home_screen.dart'; // Import the HomeScreen
import 'package:BabyShop/utils/app_colors.dart';

class SearchResult extends StatelessWidget {
  const SearchResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Make it full-screen
      height: double.infinity, // Make it full-screen
      padding: EdgeInsets.all(16.0), // Add padding for responsiveness
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            "https://ng.jumia.is/unsafe/fit-in/150x150/filters:fill(white)/product/02/7905772/3.jpg?6040"),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 342,
                    child: Text(
                      'Sorry, we couldn\'t find any matching result for your Search.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF272727),
                        fontSize: 24,
                        fontFamily: 'Circular Std',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomeScreen()), // Navigate to HomeScreen
                      );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Explore Categories',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Circular Std',
                              fontWeight: FontWeight.w400,
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
        ],
      ),
    );
  }
}
