import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'nyiha_colors.dart';

ThemeData buildNyihaTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;

  final ColorScheme scheme = dark
      ? ColorScheme.fromSeed(
          seedColor: NyihaColors.gold,
          brightness: Brightness.dark,
          primary: NyihaColors.gold,
          surface: NyihaColors.earth850,
        ).copyWith(
          surface: NyihaColors.earth900,
          onSurface: NyihaColors.cream,
          primaryContainer: NyihaColors.earth700,
          outline: NyihaColors.gold.withOpacity(0.22),
          outlineVariant: NyihaColors.gold.withOpacity(0.12),
        )
      : ColorScheme.fromSeed(
          seedColor: NyihaColors.lightPrimary,
          brightness: Brightness.light,
          primary: NyihaColors.lightPrimary,
          surface: NyihaColors.lightSurface,
        ).copyWith(
          onSurface: NyihaColors.lightOnSurface,
          onSurfaceVariant: NyihaColors.lightOnSurfaceMuted,
          surface: NyihaColors.lightSurface,
          surfaceContainerHighest: NyihaColors.lightSurfaceMuted,
          primaryContainer: NyihaColors.lightSurfaceElevated,
          outline: NyihaColors.lightPrimary.withOpacity(0.28),
          outlineVariant: NyihaColors.lightPrimary.withOpacity(0.14),
        );

  final textTheme = TextTheme(
    displayLarge: GoogleFonts.cinzel(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: scheme.onSurface,
      letterSpacing: 0.5,
    ),
    titleLarge: GoogleFonts.cinzel(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: scheme.onSurface,
      letterSpacing: 0.3,
    ),
    titleMedium: GoogleFonts.cinzel(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    ),
    bodyLarge: GoogleFonts.nunito(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: scheme.onSurface,
      height: 1.45,
    ),
    bodyMedium: GoogleFonts.nunito(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: scheme.onSurface.withOpacity(0.88),
      height: 1.45,
    ),
    bodySmall: GoogleFonts.nunito(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: scheme.onSurface.withOpacity(0.62),
    ),
    labelLarge: GoogleFonts.nunito(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
      color: scheme.primary,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? NyihaColors.earth900 : NyihaColors.lightSurface,
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      titleTextStyle: textTheme.titleMedium,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: dark ? Colors.white.withOpacity(0.04) : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: dark ? NyihaColors.gold.withOpacity(0.14) : NyihaColors.lightPrimary.withOpacity(0.12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? Colors.white.withOpacity(0.06) : NyihaColors.lightSurfaceMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: dark ? NyihaColors.gold.withOpacity(0.22) : NyihaColors.lightPrimary.withOpacity(0.22),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      hintStyle: TextStyle(
        color: dark ? NyihaColors.gold.withOpacity(0.45) : NyihaColors.lightPrimary.withOpacity(0.45),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return scheme.primary;
        return null;
      }),
      checkColor: WidgetStateProperty.all(dark ? NyihaColors.earth900 : Colors.white),
      side: BorderSide(color: scheme.primary.withOpacity(0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: dark ? NyihaColors.earth850 : NyihaColors.lightSurface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: dark ? NyihaColors.earth850 : NyihaColors.lightSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    dividerTheme: DividerThemeData(
      color: dark ? NyihaColors.gold.withOpacity(0.12) : NyihaColors.lightPrimary.withOpacity(0.1),
    ),
  );
}
