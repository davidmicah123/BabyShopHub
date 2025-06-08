import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../authentication/sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:BabyShop/utils/app_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final UserService _userService = UserService();

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool get _isButtonEnabled =>
      _firstNameController.text.isNotEmpty &&
      _lastNameController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty;

  Future<void> _signUp() async {
    final String email = _emailController.text.trim();

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
                    'Creating your account...',
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

      // Check if email exists
      final exists = await _userService.emailExists(email);
      if (exists) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context); // Close loading dialog
        _showMessage('Email already exists!', isError: true);
        return;
      }

      // Create new user
      UserModel newUser = UserModel(
        uid: '',
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: email,
        password: _passwordController.text,
      );

      final userCredential = await _userService.registerUser(newUser);
      if (userCredential != null) {
        // Save the user credentials securely
        final secureStorage = FlutterSecureStorage();
        await secureStorage.write(key: 'userId', value: userCredential.uid);
        await secureStorage.write(key: 'userEmail', value: email);
        await secureStorage.write(
            key: 'userPassword', value: _passwordController.text);

        _showMessage('Account created successfully!');

        // Delay navigation for 3 seconds
        await Future.delayed(Duration(seconds: 3));

        // ignore: use_build_context_synchronously
        Navigator.pop(context); // Close loading dialog
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pop(context); // Close loading dialog
        _showMessage('Failed to create account. Please try again.', isError: true);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context); // Close loading dialog
      _showMessage('Error: ${e.toString()}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 225,
                    height: 225,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Create Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF272727),
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 23, right: 23),
                child: Column(
                  children: [
                    _buildInputField(_firstNameController, 'First Name'),
                    const SizedBox(height: 16),
                    _buildInputField(_lastNameController, 'Last Name'),
                    const SizedBox(height: 16),
                    _buildInputField(_emailController, 'Email Address',
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _buildInputField(
                      _passwordController,
                      'Password',
                      isPassword: true,
                      togglePasswordVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: 40),
                    _buildContinueButton(),
                    const SizedBox(height: 20),
                    _buildLoginText(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text,
      bool isPassword = false,
      Function? togglePasswordVisibility}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword ? _obscurePassword : false,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Color(0x7F272727)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 19),
          border: InputBorder.none,
          suffixIcon: togglePasswordVisibility != null
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => togglePasswordVisibility(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color: _isButtonEnabled ? AppColors.primary : Colors.grey,
        borderRadius: BorderRadius.circular(100),
      ),
      child: TextButton(
        onPressed: _isButtonEnabled ? _signUp : null,
        child: const Text(
          'Continue',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoginText(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      },
      child: const Text(
        "Already have an account? Login instead.",
        style: TextStyle(color: AppColors.primary),
        textAlign: TextAlign.center,
      ),
    );
  }
}
