import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Material 3 World-Class Light & Dark Theme Configuration
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.cardLight,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold, fontSize: 32),
        displayMedium: GoogleFonts.poppins(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold, fontSize: 28),
        headlineMedium: GoogleFonts.poppins(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold, fontSize: 24),
        titleLarge: GoogleFonts.poppins(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w700, fontSize: 20),
        titleMedium: GoogleFonts.inter(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: GoogleFonts.inter(color: AppColors.textPrimaryLight, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: AppColors.textSecondaryLight, fontSize: 14),
        labelLarge: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.cardDark,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold, fontSize: 32),
        displayMedium: GoogleFonts.poppins(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold, fontSize: 28),
        headlineMedium: GoogleFonts.poppins(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold, fontSize: 24),
        titleLarge: GoogleFonts.poppins(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w700, fontSize: 20),
        titleMedium: GoogleFonts.inter(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: GoogleFonts.inter(color: AppColors.textPrimaryDark, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: AppColors.textSecondaryDark, fontSize: 14),
        labelLarge: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryDark,
      ),
    );
  }
}
