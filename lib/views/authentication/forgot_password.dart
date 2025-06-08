import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:BabyShop/views/authentication/password_reset_email_sent.dart';
import 'package:BabyShop/utils/app_colors.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _isButtonEnabled = false;

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateButtonState);
    _emailController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _emailController.text.trim().isNotEmpty;
    });
  }

  Future<void> _resetPassword() async {
    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage("Please enter your email address", isError: true);
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Sending reset email...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // ignore: use_build_context_synchronously
      Navigator.pop(context); // Close loading dialog

      _showMessage("Password reset email sent successfully!");

      // Delay navigation for 2 seconds
      await Future.delayed(Duration(seconds: 2));

      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => PasswordReset()),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context); // Close loading dialog
      _showMessage("Error: ${e.toString()}", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                // Back Button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF272727)),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(height: 20),
                // Title
                Text(
                  'Forgot\npassword?',
                  style: TextStyle(
                    color: Color(0xFF272727),
                    fontSize: 32,
                    fontFamily: 'Circular Std',
                    fontWeight: FontWeight.w700,
                    height: 1.08,
                    letterSpacing: -0.41,
                  ),
                ),
                SizedBox(height: 40),
                // Email Input
                Container(
                  width: screenWidth * 0.9,
                  decoration: BoxDecoration(
                    color: Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your email address',
                      hintStyle: TextStyle(
                        color: Color(0x7F272727),
                        fontSize: 16,
                        fontFamily: 'Circular Std',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.41,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 19),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Info Text
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          color: Color(0xFF570E6C),
                          fontSize: 12,
                          fontFamily: 'Circular Std',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' We will send you a message to set or reset your new password',
                        style: TextStyle(
                          color: Color(0xFF272727),
                          fontSize: 12,
                          fontFamily: 'Circular Std',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                // Submit Button
                Container(
                  width: screenWidth * 0.9,
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    color: _isButtonEnabled ? AppColors.primary : Colors.grey,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: TextButton(
                    onPressed: _isButtonEnabled ? _resetPassword : null,
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Circular Std',
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.50,
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
