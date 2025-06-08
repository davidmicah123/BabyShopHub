// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';
import '../authentication/account_set_up.dart';
import '../authentication/sign_up.dart';
import '../admin/admin_signin.dart';
import '../../views/dashboard/dashboard_screen.dart';
import 'package:BabyShop/utils/app_colors.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  // ignore: unused_field
  String _firstName = 'User';
  String? _userId;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
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

  @override
  void initState() {
    super.initState();
    _checkUserExists();
  }

  Future<void> _checkUserExists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');
      if (_userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            _firstName = userDoc['firstName'];
          });
        }
      }
    } catch (e) {
      // Log the error
    }
  }

  Future<void> _signIn() async {
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

      final user = await _userService.signInUser(email, password);
      if (user != null) {
        // Store credentials for biometric login
        await _secureStorage.write(key: 'userId', value: user.uid);
        await _secureStorage.write(key: 'userEmail', value: email);
        await _secureStorage.write(key: 'userPassword', value: password);

        _showMessage("Login successful!");

        // Check if user has preferences
        final prefs = await SharedPreferences.getInstance();
        final hasPreference = prefs.getBool('has_preference') ?? false;

        Navigator.of(context).pop(); // Close loading dialog

        // Navigate to appropriate screen based on preferences
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                hasPreference ? DashboardScreen() : AccountSetUp(),
          ),
        );
      } else {
        Navigator.of(context).pop(); // Close loading dialog
        _showMessage("Invalid email or password!", isError: true);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showMessage("Error: ${e.toString()}", isError: true);
    }
  }

  Future<void> _authenticateUser(BuildContext context) async {
    try {
      // Check if biometrics are available first
      bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      bool canAuthenticate = await _localAuth.isDeviceSupported();

      if (!canAuthenticateWithBiometrics || !canAuthenticate) {
        Navigator.pop(context);
        _showMessage("Biometric authentication is not available on this device", isError: true);
        return;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to sign in',
        options: const AuthenticationOptions(
          stickyAuth: true, // Keep authentication active
          biometricOnly: true,
        ),
      );

      if (isAuthenticated) {
        // Get stored credentials
        final userId = await _secureStorage.read(key: 'userId');
        final storedEmail = await _secureStorage.read(key: 'userEmail');
        final storedPassword = await _secureStorage.read(key: 'userPassword');

        if (userId == null || storedEmail == null || storedPassword == null) {
          Navigator.pop(context);
          _showMessage("Please sign in with password first to enable fingerprint login", isError: true);
          return;
        }

        try {
          final userCredential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: storedEmail,
            password: storedPassword,
          );

          if (userCredential.user != null) {
            // Store credentials for biometric login
            await _secureStorage.write(
                key: 'userId', value: userCredential.user!.uid);
            await _secureStorage.write(key: 'userEmail', value: storedEmail);
            await _secureStorage.write(
                key: 'userPassword', value: storedPassword);

            _showMessage("Login successful!");

            // Check if user has preferences
            final prefs = await SharedPreferences.getInstance();
            final hasPreference = prefs.getBool('has_preference') ?? false;

            Navigator.pop(context); // Close biometric dialog

            // Navigate to appropriate screen based on preferences
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    hasPreference ? DashboardScreen() : AccountSetUp(),
              ),
            );
          }
        } catch (e) {
          Navigator.pop(context);
          _showMessage("Authentication failed: Invalid credentials", isError: true);
        }
      } else {
        Navigator.pop(context);
        _showMessage("Biometric authentication failed", isError: true);
      }
    } catch (e) {
      // ignore: duplicate_ignore
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      _showMessage("Authentication error: ${e.toString()}", isError: true);
    }
  }

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
                  'Welcome Back!',
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
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                _buildInputField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: _obscurePassword,
                  togglePasswordVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => AdminSignIn()),
                      );
                    },
                    child: Text(
                      'Login as Admin',
                      style: TextStyle(
                        color: Color(0xFF570E6C),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: screenWidth * 0.9,
                  child: ElevatedButton(
                    onPressed: () => _signIn(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF570E6C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  child:
                      Text("Don't have an account? Click here to create one."),
                ),
                TextButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        // Start authentication immediately
                        _authenticateUser(context);

                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Platform.isAndroid
                                      ? Icons.fingerprint
                                      : Icons.face,
                                  size: 70,
                                  color: Color(0xFF570E6C),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'Authenticating...',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 24),
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF570E6C)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    "Click here to login with fingerprint",
                    style: TextStyle(color: Color(0xFF570E6C)),
                  ),
                ),
                SizedBox(height: 20),
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
