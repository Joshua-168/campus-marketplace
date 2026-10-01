import 'package:flutter/material.dart';

/// World-Class Design System Color Palette, Gradients & Surface Tokens
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF2563EB); // Royal Electric Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Secondary & Accent Colors
  static const Color secondary = Color(0xFF8B5CF6); // Deep Purple
  static const Color secondaryLight = Color(0xFFA78BFA);
  static const Color accent = Color(0xFF06B6D4); // Cyan
  static const Color accentLight = Color(0xFF2DD4BF);
  static const Color teal = Color(0xFF14B8A6);

  // Dark Mode Surface & Background Tokens
  static const Color backgroundDark = Color(0xFF0F172A); // Slate Dark
  static const Color cardDark = Color(0xFF1E293B); // Slate Surface
  static const Color cardDarkHover = Color(0xFF334155);
  static const Color glassDark = Color(0x331E293B);

  // Light Mode Surface & Background Tokens
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardLightHover = Color(0xFFF1F5F9);

  // Typography & Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Functional Status Colors
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color warning = Color(0xFFF59E0B); // Amber Gold
  static const Color error = Color(0xFFEF4444); // Coral Red
  static const Color info = Color(0xFF06B6D4); // Cyan Info

  // Shimmer Tokens
  static const Color shimmerBaseDark = Color(0xFF1E293B);
  static const Color shimmerHighlightDark = Color(0xFF334155);
  static const Color shimmerBaseLight = Color(0xFFE2E8F0);
  static const Color shimmerHighlightLight = Color(0xFFF1F5F9);

  // Premium Gradient Tokens
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
