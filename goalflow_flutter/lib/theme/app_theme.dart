import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Base Warm Ivory Foundation
  static const Color bg = Color(0xFFF6F5F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFAF9F6);
  static const Color border = Color(0xFFEBE7DF);
  static const Color borderSubtle = Color(0xFFF0ECE4);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E2522);
  static const Color textSecondary = Color(0xFF5E6963);
  static const Color textMuted = Color(0xFF909B94);
  static const Color textLight = Color(0xFFB5BEB8);

  // Brand Forest Green
  static const Color primaryGreen = Color(0xFF385E46);
  static const Color primaryGreenLight = Color(0xFF4A755A);
  static const Color primaryGreenDark = Color(0xFF264632);
  static const Color greenBgSubtle = Color(0xFFEBF3ED);
  static const Color greenAccent = Color(0xFF437A55);

  // Warm Gold
  static const Color warmGold = Color(0xFFD6A856);
  static const Color goldBgSubtle = Color(0xFFFAF4E8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF466E54), Color(0xFF294935)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFAF9F6)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE5BE6C), Color(0xFFC7963E)],
  );

  // Category Colors
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return const Color(0xFF437A55);
      case 'learning':
        return const Color(0xFF3D6F9D);
      case 'fitness':
        return const Color(0xFFC25454);
      case 'career':
        return const Color(0xFF5256A8);
      case 'finance':
        return const Color(0xFFB38038);
      case 'personal':
      default:
        return const Color(0xFF874FA0);
    }
  }

  static Color getCategoryBg(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return const Color(0xFFEBF3ED);
      case 'learning':
        return const Color(0xFFEAF1F8);
      case 'fitness':
        return const Color(0xFFF9EBEB);
      case 'career':
        return const Color(0xFFECECF8);
      case 'finance':
        return const Color(0xFFF9F3EA);
      case 'personal':
      default:
        return const Color(0xFFF4EDF8);
    }
  }

  // Soft Claymorphic / Tactile Shadows
  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: Color(0x0C2B3830),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
        const BoxShadow(
          color: Color(0x05FFFFFF),
          blurRadius: 4,
          offset: Offset(-2, -2),
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        const BoxShadow(
          color: Color(0x28385E46),
          blurRadius: 14,
          offset: Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        const BoxShadow(
          color: Color(0x08000000),
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ];

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      primaryColor: primaryGreen,
      colorScheme: const ColorScheme.light(
        surface: surface,
        primary: primaryGreen,
        secondary: warmGold,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.8,
            height: 1.15,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.4,
          ),
          titleMedium: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: -0.2,
          ),
          bodyLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            height: 1.4,
          ),
          labelLarge: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textMuted,
            letterSpacing: 0.2,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: border, width: 1.1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(color: textLight, fontSize: 14, fontWeight: FontWeight.w400),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGreen, width: 1.6),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkBg = Color(0xFF141C18);
    const darkSurface = Color(0xFF1E2823);
    const darkBorder = Color(0xFF2C3933);
    const darkTextPrimary = Color(0xFFF0F5F2);
    const darkTextSecondary = Color(0xFFA2B5AA);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: primaryGreen,
      colorScheme: const ColorScheme.dark(
        surface: darkSurface,
        primary: primaryGreen,
        secondary: warmGold,
        onSurface: darkTextPrimary,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: darkBorder, width: 1.1),
        ),
      ),
    );
  }
}
