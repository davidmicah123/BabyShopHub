import 'package:flutter/material.dart';
import '../authentication/sign_in.dart';
import 'dart:async';
import 'package:BabyShop/utils/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 4), () {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignIn()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(seconds: 2),
          child: Image.asset(
            'assets/logo.png', // Make sure to add your logo to assets
            width: 225, // Increased by 50% from 150
            height: 225, // Increased by 50% from 150
          ),
        ),
      ),
    );
  }
}
