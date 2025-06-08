import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import 'admin_dashboard.dart';
import '../../utils/app_colors.dart';

class AdminSignIn extends StatefulWidget {
  const AdminSignIn({super.key});

  @override
  State<AdminSignIn> createState() => _AdminSignInState();
}

class _AdminSignInState extends State<AdminSignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final AdminService _adminService = AdminService();

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _signInAdmin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showMessage("Please enter both email and password", isError: true);
      return;
    }

    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

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
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Signing in...',
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

      if (email != 'admin@admin.com') {
        Navigator.of(context).pop(); // Close loading dialog
        _showMessage("Access denied: Invalid admin email!", isError: true);
        return;
      }

      final result = await _adminService.signInAdmin(email, password);
      
      // Make sure context is still valid
      if (!mounted) return;
      
      Navigator.of(context).pop(); // Close loading dialog

      if (result != null && result['user'] != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AdminDashboard(),
          ),
        );
      } else {
        _showMessage("Access denied: Invalid admin credentials!", isError: true);
      }
    } catch (e) {
      // Make sure context is still valid
      if (!mounted) return;
      
      Navigator.of(context).pop(); // Close loading dialog
      _showMessage("Error: Unable to sign in. Please try again.", isError: true);
      print('Sign in error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.05),
                Center(
                  child: Image.asset(
                    'assets/logo.png',
                    width: 225,
                    height: 225,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Admin Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF272727),
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                _buildInputField(
                  controller: _emailController,
                  hintText: 'Admin Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                _buildInputField(
                  controller: _passwordController,
                  hintText: 'Admin Password',
                  obscureText: _obscurePassword,
                  togglePasswordVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: screenWidth * 0.9,
                  child: ElevatedButton(
                    onPressed: _signInAdmin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Login as Admin',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Function? togglePasswordVisibility,
  }) {
    return Material(
      color: Color(0xFFF4F4F4),
      borderRadius: BorderRadius.circular(4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Color(0x7F272727)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 19),
          border: InputBorder.none,
          suffixIcon: togglePasswordVisibility != null
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => togglePasswordVisibility(),
                )
              : null,
        ),
      ),
    );
  }
}
