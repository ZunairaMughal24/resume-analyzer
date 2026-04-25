import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // 🎨 MASTER THEME PALETTE

  // -- CURRENT THEME: EMERALD GREEN --
  static const _themePrimary = Color(0xFF00DC82);
  static const _themePrimaryDark = Color(0xFF00B36B);
  static const _themeAccent = Color(0xFF34D399);
  static const _themeGlow = Color.fromARGB(255, 200, 251, 60);

  // -- ALTERNATIVE THEME: OCEAN BLUE (Example, uncomment to switch) --
  // static const _themePrimary = Color(0xFF3B82F6);
  // static const _themePrimaryDark = Color(0xFF2563EB);
  // static const _themeAccent = Color(0xFF60A5FA);
  // static const _themeGlow = Color(0xFF93C5FD);
  // =========================================================

  static const background = Color(0xFF0F1115);
  static const surface = Color(0xFF181A1F);
  static const surfaceElevated = Color(0xFF21242C);
  static const cardBg = Color(0xFF1C1F26);

  // Semantic colors linked to the Master Palette
  static const primary = _themePrimary;
  static const primaryDark = _themePrimaryDark;
  static const accent = _themeAccent;
  static const primaryGlow = _themeGlow;

  static const accentWarm = Color(0xFFFB923C);
  static const accentGold = Color(0xFFFACC15);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color.fromARGB(255, 204, 206, 209);
  static const textMuted = Color(0xFF64748B);
  static const border = Color(0xFF2D333F);
  static const borderLight = Color(0xFF3F4756);
  static const success = Color(0xFF00DC82);
  static const warning = Color(0xFFFACC15);
  static const error = Color(0xFFF87171);

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
    // final textTheme = GoogleFonts.nunitoTextTheme(base.textTheme);

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
          color: AppColors.textPrimary,
          fontSize: 48,
          fontWeight: FontWeight.w800,
          letterSpacing: -2,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          color: AppColors.textPrimary,
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.spaceGrotesk(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 16,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 12,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w600,
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
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );
  }

  static TextStyle mono({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.geologica(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
