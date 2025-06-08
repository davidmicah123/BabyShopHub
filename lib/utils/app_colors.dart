import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF570E6C);
  
  // MaterialColor implementation with proper opacity values
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF570E6C,
    <int, Color>{
      50: Color(0xFFF0E6F2),
      100: Color(0xFFD9C0E0),
      200: Color(0xFFC097CD),
      300: Color(0xFFA76EBA),
      400: Color(0xFF944FA7),
      500: Color(0xFF570E6C), // Primary color
      600: Color(0xFF4F0C64),
      700: Color(0xFF450A59),
      800: Color(0xFF3C084F),
      900: Color(0xFF2B053A),
    },
  );
} 