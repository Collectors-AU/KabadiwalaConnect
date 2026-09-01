import 'package:flutter/material.dart';

class AppConstants {
  // E-waste categories
  static const List<String> eWasteCategories = [
    'CRT',
    'LCD',
    'PCB_HIGH',
    'PCB_MED',
    'CABLE',
    'BATTERY',
    'MOTOR',
    'PLASTIC'
  ];

  // Baseline local scrap prices (per kg or per piece depending on category)
  static const Map<String, double> baselinePrices = {
    'CRT': 150.0,
    'LCD': 200.0,
    'PCB_HIGH': 450.0,
    'PCB_MED': 250.0,
    'CABLE': 120.0,
    'BATTERY': 80.0,
    'MOTOR': 60.0,
    'PLASTIC': 15.0,
  };

  // Supported Locales
  static const Map<String, String> supportedLocales = {
    'hi_IN': 'Hindi',
    'mr_IN': 'Marathi',
    'en_IN': 'English',
  };

  // Visual Color Tokens
  static const Color primaryBlue = Color(0xFF1B3B86);
  static const Color offWhite = Color(0xFFF3F0E6);
  static const Color lightGrey = Color(0xFFF0F0F0);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE53935);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
}
