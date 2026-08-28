import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Shared visual language for Expense Tracker (Material 3).
class AppTheme {
  static const double radius = 12;

  static ThemeData light() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.lightSurfaceAccent,
      onPrimaryContainer: AppColors.lightTextPrimary,
      secondary: const Color(0xFF3D5C58),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFD7EFEB),
      onSecondaryContainer: AppColors.lightTextPrimary,
      tertiary: const Color(0xFF7C3AED),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFEDE9FE),
      onTertiaryContainer: const Color(0xFF2E1065),
      error: const Color(0xFFDC2626),
      onError: Colors.white,
      errorContainer: const Color(0xFFFEE2E2),
      onErrorContainer: const Color(0xFF7F1D1D),
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,
      surfaceContainerHigh: AppColors.lightSurface,
      surfaceContainerHighest: AppColors.lightSurfaceAccent,
      outline: AppColors.lightBorder,
      outlineVariant: const Color(0xFFBFDCD7),
      shadow: Colors.black54,
      scrim: Colors.black54,
      inverseSurface: AppColors.darkSurface,
      onInverseSurface: AppColors.darkTextPrimary,
      inversePrimary: AppColors.accent,
    );

    return _base(
      colorScheme,
      sectionColor: AppColors.lightSurface,
      elevatedSectionColor: AppColors.lightSurfaceElevated,
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.accent,
      onPrimary: const Color(0xFF003731),
      primaryContainer: const Color(0xFF115E59),
      onPrimaryContainer: const Color(0xFFCCFBF1),
      secondary: const Color(0xFF94A3B8),
      onSecondary: const Color(0xFF0F172A),
      secondaryContainer: const Color(0xFF334155),
      onSecondaryContainer: const Color(0xFFE2E8F0),
      tertiary: const Color(0xFFC4B5FD),
      onTertiary: const Color(0xFF1E1B4B),
      tertiaryContainer: const Color(0xFF3B3560),
      onTertiaryContainer: const Color(0xFFE9E5FF),
      error: const Color(0xFFF87171),
      onError: const Color(0xFF450A0A),
      errorContainer: const Color(0xFF7F1D1D),
      onErrorContainer: const Color(0xFFFEE2E2),
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      surfaceContainerHigh: AppColors.darkSurface,
      surfaceContainerHighest: AppColors.darkSurfaceHigh,
      outline: AppColors.darkBorder,
      outlineVariant: const Color(0xFF3A3E4F),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.lightSurface,
      onInverseSurface: AppColors.lightTextPrimary,
      inversePrimary: AppColors.primary,
    );

    return _base(
      colorScheme,
      sectionColor: AppColors.darkSurface,
      elevatedSectionColor: AppColors.darkSurfaceHigh,
    );
  }

  static ThemeData _base(
    ColorScheme colorScheme, {
    required Color sectionColor,
    required Color elevatedSectionColor,
  }) {
    final shapes = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    final textTheme = AppTypography.bodyTextTheme(colorScheme);
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      dividerColor: colorScheme.outlineVariant,
      disabledColor: colorScheme.onSurface.withValues(alpha: 0.38),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.96),
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: elevatedSectionColor,
        shape: shapes.copyWith(
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.65)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedSectionColor,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: colorScheme.primary),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: sectionColor,
        selectedColor: colorScheme.primaryContainer,
        disabledColor: colorScheme.surfaceContainerHighest,
        secondarySelectedColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        secondaryLabelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: shapes,
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          disabledBackgroundColor:
              colorScheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor:
              colorScheme.onSurface.withValues(alpha: 0.38),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(88, 44),
          shape: shapes,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(48, 44),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: shapes,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDark ? AppColors.darkSurfaceHigh : const Color(0xFF1E293B),
        contentTextStyle: const TextStyle(color: AppColors.darkTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: elevatedSectionColor,
        shape: shapes,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: elevatedSectionColor,
        shape: shapes,
        textStyle: TextStyle(color: colorScheme.onSurface),
      ),
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: colorScheme.tertiaryContainer,
        contentTextStyle: TextStyle(color: colorScheme.onTertiaryContainer),
      ),
    );
  }
}
