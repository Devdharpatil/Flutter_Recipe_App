import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF4CAF50); // Sage Green
  static const Color primaryDarkColor = Color(0xFF3A8A3F);
  static const Color primaryLightColor = Color(0xFFA5D6A7);
  
  static const Color backgroundColorLight = Color(0xFFFFFFFF);
  static const Color backgroundColorDark = Color(0xFF1A1D1F);
  
  static const Color primaryTextColorLight = Color(0xFF1A1D1F);
  static const Color primaryTextColorDark = Color(0xFFF5F7FA);
  
  static const Color secondaryTextColorLight = Color(0xFF4F585E);
  static const Color secondaryTextColorDark = Color(0xFFA0AAB3);

  // Typography
  static const String fontFamily = 'Poppins';

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: primaryTextColorLight,
      ),
      scaffoldBackgroundColor: backgroundColorLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryTextColorLight),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: primaryTextColorLight,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorLight,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorLight,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorLight,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorLight,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorLight,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorLight,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorLight,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorLight,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorLight,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorLight,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          color: secondaryTextColorLight,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          color: secondaryTextColorLight,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorLight,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          color: secondaryTextColorLight,
        ),
        hintStyle: const TextStyle(
          fontFamily: fontFamily,
          color: secondaryTextColorLight,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryTextColorLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primaryLightColor,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor);
          }
          return const IconThemeData(color: secondaryTextColorLight);
        }),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryLightColor,
        onPrimary: Colors.white,
        surface: const Color(0xFF23272A),
        onSurface: primaryTextColorDark,
      ),
      scaffoldBackgroundColor: backgroundColorDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryTextColorDark),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: primaryTextColorDark,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorDark,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorDark,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorDark,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorDark,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorDark,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorDark,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorDark,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorDark,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorDark,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorDark,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          color: secondaryTextColorDark,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          color: secondaryTextColorDark,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          color: primaryTextColorDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLightColor,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLightColor,
          side: const BorderSide(color: primaryLightColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF23272A),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          color: secondaryTextColorDark,
        ),
        hintStyle: const TextStyle(
          fontFamily: fontFamily,
          color: secondaryTextColorDark,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF23272A),
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryTextColorDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF23272A),
        indicatorColor: primaryDarkColor,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor);
          }
          return const IconThemeData(color: secondaryTextColorDark);
        }),
      ),
    );
  }
} 