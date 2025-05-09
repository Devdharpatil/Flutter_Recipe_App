import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  // Primary color and shades
  static const MaterialColor primarySwatch = MaterialColor(
    _primaryValue,
    <int, Color>{
      50: Color(0xFFE9F3E4),
      100: Color(0xFFC8E0BC),
      200: Color(0xFFA3CC90),
      300: Color(0xFF7EB864),
      400: Color(0xFF62A842),
      500: Color(_primaryValue),
      600: Color(0xFF3E8F1C),
      700: Color(0xFF348418),
      800: Color(0xFF2C7A13),
      900: Color(0xFF1D680B),
    },
  );
  static const int _primaryValue = 0xFF459820;
  static const Color primary = Color(_primaryValue);
  
  // Secondary color
  static const Color secondary = Color(0xFFEF6C00);
  
  // Tertiary color for emphasis
  static const Color tertiary = Color(0xFF6200EA);
  
  // Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceMedium = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFFEEEEEE);
  
  // Dark theme colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDarkMode = Color(0xFF1E1E1E);
  static const Color surfaceDarkVariant = Color(0xFF2C2C2C);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFF9E9E9E);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  
  // Semantic colors for status and states
  static const Color success = Color(0xFF43A047);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFB300);
  static const Color info = Color(0xFF1976D2);
  
  // Divider and border colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);
  
  // Nutritional indicator colors
  static const Color carbs = Color(0xFF26A69A);
  static const Color protein = Color(0xFF7B1FA2);
  static const Color fat = Color(0xFFEF5350);
  static const Color calories = Color(0xFFFFA000);
  
  // Difficulty level colors
  static const Color easy = Color(0xFF66BB6A);
  static const Color medium = Color(0xFFFFB74D);
  static const Color hard = Color(0xFFE57373);

  // Private constructor to prevent instantiation
  const AppColors._();
} 