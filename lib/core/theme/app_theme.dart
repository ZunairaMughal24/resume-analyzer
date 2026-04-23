import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF080810);
  static const surface = Color(0xFF10101C);
  static const surfaceElevated = Color(0xFF18182A);
  static const cardBg = Color(0xFF13131E);
  static const primary = Color(0xFF7C6FF7);
  static const primaryDark = Color(0xFF5A4EE8);
  static const accent = Color(0xFF00E5C0);
  static const accentWarm = Color(0xFFFF7070);
  static const accentGold = Color(0xFFFFCC55);
  static const textPrimary = Color(0xFFF2F2FF);
  static const textSecondary = Color(0xFF9090B8);
  static const textMuted = Color(0xFF505070);
  static const border = Color(0xFF22223A);
  static const borderLight = Color(0xFF33335A);
  static const success = Color(0xFF00E5C0);
  static const warning = Color(0xFFFFCC55);
  static const error = Color(0xFFFF7070);

  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFF7C6FF7), Color(0xFF5A4EE8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientAccent = LinearGradient(
    colors: [Color(0xFF00E5C0), Color(0xFF00B8D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.textPrimary, fontSize: 48,
          fontWeight: FontWeight.w800, letterSpacing: -2,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          color: AppColors.textPrimary, fontSize: 36,
          fontWeight: FontWeight.w700, letterSpacing: -1,
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.textPrimary, fontSize: 26,
          fontWeight: FontWeight.w700, letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          color: AppColors.textPrimary, fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.textPrimary, fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.spaceGrotesk(
          color: AppColors.textPrimary, fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.textSecondary, fontSize: 16, height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.textSecondary, fontSize: 14, height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          color: AppColors.textMuted, fontSize: 12, height: 1.4,
        ),
        labelLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.textPrimary, fontSize: 13,
          fontWeight: FontWeight.w600, letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border, thickness: 1,
      ),
    );
  }
}
