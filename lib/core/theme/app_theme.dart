import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // 🎨 MASTER THEME PALETTE

  // -- CURRENT THEME: EMERALD GREEN --
  // static const _themePrimary = Color(0xFF00DC82);
  // static const _themePrimaryDark = Color(0xFF00B36B);
  // static const _themeAccent = Color(0xFF34D399);
  // static const _themeGlow = Color.fromARGB(255, 200, 251, 60);

  // -- ALTERNATIVE THEME: OCEAN BLUE (Example, uncomment to switch) --
  // static const _themePrimary = Color(0xFF3B82F6);
  // static const _themePrimaryDark = Color(0xFF2563EB);
  // static const _themeAccent = Color(0xFF60A5FA);
  // static const _themeGlow = Color(0xFF93C5FD);

  ///-- ALTERNATIVE THEME: SUNSET CORAL (Uncomment to switch) --
  static const _themePrimary =
      Color(0xFFE07A5F); // Warm Terracotta (Orangey-Brown)
  static const _themePrimaryDark = Color(0xFFB85942); // Deep Rust / Brown
  static const _themeAccent = Color(0xFFF4A261); // Sandy Orange Accent
  static const _themeGlow = Color(0xFFFFD6BA); // Warm Peach Glow

  // -- ALTERNATIVE THEME: ROYAL AMETHYST (Premium / Expensive Look) --
  // static const _themePrimary = Color(0xFF8B5CF6); // Rich elegant Violet
  // static const _themePrimaryDark = Color(0xFF5B21B6); // Deep premium Amethyst
  // static const _themeAccent = Color(0xFFA78BFA); // Soft glowing Purple
  // static const _themeGlow = Color(0xFFC4B5FD); // Ethereal Purple Glow

  ///-- ALTERNATIVE THEME: MIDNIGHT GOLD (Executive / Fintech Vibe) --
  // static const _themePrimary = Color(0xFFD4AF37); // Metallic Gold
  // static const _themePrimaryDark = Color(0xFF996515); // Deep Antique Gold
  // static const _themeAccent = Color(0xFFF3E5AB); // Vanilla / Light Gold
  // static const _themeGlow = Color(0xFFFFD700); // Bright Gold Glow

  ///-- ALTERNATIVE THEME: CYBER AQUA (Modern AI / Tech Startup) --
  // static const _themePrimary = Color(0xFF00E5FF); // Electric Cyan
  // static const _themePrimaryDark = Color(0xFF00B8D4); // Deep Aqua
  // static const _themeAccent = Color(0xFF18FFFF); // Bright Neon Cyan
  // static const _themeGlow = Color(0xFF84FFFF); // Soft Cyan Glow

  ///-- ALTERNATIVE THEME: DEEP SAPPHIRE (High-end Automotive / Corporate) --
  // static const _themePrimary = Color(0xFF0F52BA); // Sapphire Blue
  // static const _themePrimaryDark = Color(0xFF082567); // Midnight Sapphire
  // static const _themeAccent = Color(0xFFE5E4E2); // Platinum Accent
  // static const _themeGlow = Color(0xFF8B9BB4); // Soft Steel Glow

  ///-- ALTERNATIVE THEME: TITANIUM & NEON AMBER (Nothing OS / Hyper-Modern Tech) --
  // static const _themePrimary = Color(0xFFFF4500); // Electric Orange/Amber
  // static const _themePrimaryDark = Color(0xFFCC3700); // Deep Burnt Orange
  // static const _themeAccent = Color(0xFFFF8C00); // Dark Orange Accent
  // static const _themeGlow = Color(0xFFFFDAB9); // Soft Peach Glow

  ///-- ALTERNATIVE THEME: DEEP JADE & CHAMPAGNE (Wealth Management / Banking) --
  // static const _themePrimary = Color(0xFF00A86B); // Rich Jade Green
  // static const _themePrimaryDark = Color(0xFF00754B); // Deep Forest Jade
  // static const _themeAccent = Color(0xFFF7E7CE); // Soft Champagne Gold
  // static const _themeGlow = Color(0xFFC1D5D0); // Ethereal Silver-Green Glow

  ///-- ALTERNATIVE THEME: CHARCOAL & FROST BLUE (Luxury EV / Polestar UI) --
  // static const _themePrimary = Color(0xFF8AB4F8); // Crisp Frost Blue
  // static const _themePrimaryDark = Color(0xFF4285F4); // Deep Cobalt
  // static const _themeAccent = Color(0xFFD2E3FC); // Icy White Accent
  // static const _themeGlow = Color(0xFFE8F0FE); // Soft Frost Glow

  // -- ALTERNATIVE THEME: MUTED SAGE & SAND (Calm / Organic Minimalist) --
  // static const _themePrimary = Color(0xFF8A9A86); // Muted Sage Green
  // static const _themePrimaryDark = Color(0xFF5E6D5A); // Deep Sage
  // static const _themeAccent = Color(0xFFD4CBBB); // Soft Sand Beige
  // static const _themeGlow = Color(0xFFE8E5E1); // Very Soft Organic Glow

  // -- ALTERNATIVE THEME: DUSTY BLUE & WARM GREY (Corporate Clean / Subtle) --
  // static const _themePrimary = Color(0xFF6C8EBF); // Dusty Corporate Blue
  // static const _themePrimaryDark = Color(0xFF4A6B9C); // Deep Dusty Blue
  // static const _themeAccent = Color(0xFFB0B7C6); // Warm Grey Accent
  // static const _themeGlow = Color(0xFFD8DCE6); // Soft Blue-Grey Glow

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
