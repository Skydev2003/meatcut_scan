import 'package:flutter/material.dart';

/// Application theme configuration - Premium Red & Black Theme
class AppTheme {
  // Primary Colors - Red & Black
  static const Color primaryColor = Color(0xFFDC2626); // Vibrant Red
  static const Color primaryLight = Color(0xFFEF4444);
  static const Color primaryDark = Color(0xFF991B1B);

  // Accent Colors
  static const Color accentColor = Color(0xFFFF6B6B); // Bright Red
  static const Color accentGold = Color(0xFFFFD700); // Gold accent

  // Dark Colors
  static const Color darkBackground = Color(0xFF0F0F0F); // Almost Black
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF262626);

  // Secondary Colors
  static const Color secondaryColor = Color(0xFFFF6B6B);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color warningColor = Color(0xFFFB923C);
  static const Color successColor = Color(0xFF10B981);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFD1D5DB);
  static const Color textMuted = Color(0xFF9CA3AF);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: darkSurface,
        background: darkBackground,
      ),
      scaffoldBackgroundColor: darkBackground,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: darkSurface,
        foregroundColor: textPrimary,
        shadowColor: primaryColor.withOpacity(0.3),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: primaryColor.withOpacity(0.2),
        color: darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primaryColor.withOpacity(0.2), width: 1),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          elevation: 8,
          shadowColor: primaryColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          side: BorderSide(color: primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textMuted),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: primaryColor, size: 24),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: textSecondary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: textMuted, fontSize: 12),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: primaryColor.withOpacity(0.2),
        thickness: 1,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
    );
  }

  // Gradient for premium look
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primaryDark, primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get darkGradient => LinearGradient(
    colors: [darkBackground, darkSurface, darkCard],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shimmer effect colors
  static LinearGradient get shimmerGradient => LinearGradient(
    colors: [
      primaryColor.withOpacity(0.1),
      primaryColor.withOpacity(0.3),
      primaryColor.withOpacity(0.1),
    ],
    stops: const [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
