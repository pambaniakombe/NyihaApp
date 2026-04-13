import 'package:flutter/material.dart';

/// Design tokens — gold/earth for dark theme; white + [#5372F0] for light theme.
abstract final class NyihaColors {
  static const Color gold = Color(0xFFD4A017);
  static const Color goldLight = Color(0xFFF0C94A);
  static const Color goldDark = Color(0xFFB8890F);
  static const Color goldMuted = Color(0xFF9A7B2E);

  /// Light theme primary (user brand blue).
  static const Color lightPrimary = Color(0xFF5372F0);
  static const Color lightPrimaryDark = Color(0xFF3E5BD8);
  static const Color lightPrimaryLight = Color(0xFF7B94F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF5F7FF);
  static const Color lightSurfaceElevated = Color(0xFFEEF1FF);
  static const Color lightOnSurface = Color(0xFF1A1D2E);
  static const Color lightOnSurfaceMuted = Color(0xFF5C6378);

  static const Color earth950 = Color(0xFF0A0603);
  static const Color earth900 = Color(0xFF0F0A04);
  static const Color earth850 = Color(0xFF151008);
  static const Color earth800 = Color(0xFF1C1309);
  static const Color earth700 = Color(0xFF251808);
  static const Color earth600 = Color(0xFF3A2510);
  static const Color earth500 = Color(0xFF4D3214);

  static const Color cream = Color(0xFFFEF3DC);
  static const Color creamDark = Color(0xFFE8D4B0);
  static const Color ivory = Color(0xFFFFFBF5);
  static const Color parchment = Color(0xFFF5E6CC);

  static const Color amberMid = Color(0xFFC45E1A);
  static const Color greenAccent = Color(0xFF2D8A4E);
  static const Color blueAccent = Color(0xFF1A5FA8);

  static const LinearGradient goldButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldDark, gold, goldLight],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient lightPrimaryButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightPrimaryDark, lightPrimary, lightPrimaryLight],
    stops: [0.0, 0.45, 1.0],
  );

  /// Primary CTA gradient — gold (dark) or blue (light).
  static LinearGradient primaryButtonGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? goldButton : lightPrimaryButton;
  }

  /// Text/icon on primary filled buttons.
  static Color onPrimaryButton(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? earth900 : Colors.white;
  }

  /// Accent for icons, borders, labels that follow brand (gold vs blue).
  static Color accent(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? gold : lightPrimary;
  }

  /// Rich hero gradient (splash, auth) — dark only; light uses [pageLight].
  static const LinearGradient splashBg = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      earth950,
      earth900,
      earth850,
      earth800,
      earth700,
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  static const LinearGradient headerHome = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [earth850, earth700, earth600],
    stops: [0.0, 0.55, 1.0],
  );

  /// Light-mode page: white → soft blue wash.
  static const LinearGradient pageLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      lightSurface,
      lightSurfaceMuted,
      Color(0xFFE8EDFF),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  static Color scrim(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? earth900.withOpacity(0.65)
          : lightOnSurface.withOpacity(0.35);

  static Color onSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? cream : lightOnSurface;

  static Color onSurfaceMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? cream.withOpacity(0.55)
          : lightOnSurfaceMuted;

  static Color cardBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? gold.withOpacity(0.14)
          : lightPrimary.withOpacity(0.14);

  static Color cardFill(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.045)
          : Colors.white.withOpacity(0.98);
}

/// Page backgrounds and shared box decorations.
abstract final class NyihaDecorations {
  static BoxDecoration pageGradient(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: dark ? NyihaColors.splashBg : NyihaColors.pageLight,
    );
  }

  /// Home / profile hero band.
  static BoxDecoration homeHeader(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: dark
          ? NyihaColors.headerHome
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                NyihaColors.lightSurface,
                NyihaColors.lightSurfaceMuted,
                NyihaColors.lightSurfaceElevated,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
    );
  }

  /// Community / duka tab top chrome.
  static BoxDecoration communityHeader(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: dark
          ? NyihaColors.splashBg
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                NyihaColors.lightSurface,
                NyihaColors.lightSurfaceMuted,
              ],
            ),
    );
  }

  static BoxDecoration subtleRadialAccent(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(0.85, -0.35),
        radius: 1.15,
        colors: dark
            ? [
                NyihaColors.gold.withOpacity(0.09),
                Colors.transparent,
              ]
            : [
                NyihaColors.lightPrimary.withOpacity(0.07),
                Colors.transparent,
              ],
      ),
    );
  }
}
