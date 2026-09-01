import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryBlue = Color(0xFF1B3B86);
  static const Color offWhite = Color(0xFFF3F0E6);
  static const Color lightGrey = Color(0xFFF0F0F0);
  
  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: offWhite,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 36,
          color: primaryBlue,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: primaryBlue,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.grey[800],
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryBlue,
        background: offWhite,
      ),
    );
  }
}
