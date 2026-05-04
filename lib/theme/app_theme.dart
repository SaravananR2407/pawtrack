import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Defines the visual theme for the PawTrack app.
class AppTheme {
  // Brand Colors 
  // Main brand color  used for primary buttons and accents
  static const Color primary = Color(0xFF1D9E75);

  // Light variant of primary used for subtle backgrounds
  static const Color primaryLight = Color(0xFFE1F5EE);

  // Darker shade of primary used for contrast (text, pressed states)
  static const Color primaryDark = Color(0xFF0F6E56);

  // Secondary warm accent (coral/orange tones)
  static const Color secondary = Color(0xFFF0997B);

  // Additional accent (yellow/gold)
  static const Color accent = Color(0xFFFAC775);

  // Deep green for high-contrast text (headlines)
  static const Color darkGreen = Color(0xFF04342C);

  // Muted green used for secondary decorative elements
  static const Color muted = Color(0xFF5DCAA5);

  // Global background color of screens
  static const Color background = Color(0xFFF7FDFB);

  // Card background white for clean surfaces
  static const Color cardBg = Color(0xFFFFFFFF);

  // Border color used in input fields and cards
  static const Color border = Color(0xFF9FE1CB);

  // Error color for warnings or destructive actions
  static const Color danger = Color(0xFFE24B4A);

  // Warning color for alerts 
  static const Color warning = Color(0xFFEF9F27);

  // Subtle text color for less important information
  static const Color textSecondary = Color(0xFF5F5E5A);

  /// Returns the complete light theme configuration for the app.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Color scheme generated from the primary seed color
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: cardBg,
      ),

      // Global scaffold background
      scaffoldBackgroundColor: background,

      // Text Theme 
      // Using Quicksand as the base font family, with Nunito for headers
      textTheme: GoogleFonts.quicksandTextTheme().copyWith(
        // Large headline 
        displayLarge: GoogleFonts.nunito(
          fontWeight: FontWeight.w800,
          color: darkGreen,
        ),
        // Medium headline
        headlineMedium: GoogleFonts.nunito(
          fontWeight: FontWeight.w800,
          color: darkGreen,
        ),
        // Section titles
        titleLarge: GoogleFonts.nunito(
          fontWeight: FontWeight.w700,
          color: darkGreen,
        ),
        // Body text for regular paragraphs
        bodyMedium: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
          color: darkGreen,
        ),
        // Small text for captions, secondary labels
        bodySmall: GoogleFonts.quicksand(
          color: textSecondary,
        ),
      ),

      // App Bar Theme 
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0, 
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),

      // Elevated Button Theme 
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52), // Full‑width, comfortable height
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.quicksand(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      //  Input Decoration Theme (TextFields) 
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        labelStyle: GoogleFonts.quicksand(
          color: primaryDark,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: GoogleFonts.quicksand(
          color: textSecondary,
          fontSize: 14,
        ),
      ),

      // Card Theme 
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
    );
  }
}