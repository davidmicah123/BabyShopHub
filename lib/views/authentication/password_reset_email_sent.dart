import 'package:flutter/material.dart';
import 'package:BabyShop/views/authentication/sign_in.dart';
import 'package:BabyShop/utils/app_colors.dart';

class PasswordReset extends StatelessWidget {
  const PasswordReset({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth,
            height: screenHeight,
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset(
                    'assets/mail_sent.gif',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'We Sent you an Email to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF272727),
                    fontSize: 24,
                    fontFamily: 'Circular Std',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  width: screenWidth * 0.9,
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Return to Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Circular Std',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
