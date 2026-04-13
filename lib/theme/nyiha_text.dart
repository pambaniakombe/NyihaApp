import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'nyiha_colors.dart';

TextStyle nyihaCinzel(
  BuildContext context, {
  double size = 16,
  FontWeight weight = FontWeight.w700,
  Color? color,
}) {
  final on = color ?? NyihaColors.onSurface(context);
  return GoogleFonts.cinzel(
    fontSize: size,
    fontWeight: weight,
    color: on,
    letterSpacing: 0.25,
  );
}

TextStyle nyihaNunito(
  BuildContext context, {
  double size = 14,
  FontWeight weight = FontWeight.w500,
  Color? color,
  double? height,
  double? letterSpacing,
}) {
  final on = color ?? NyihaColors.onSurface(context).withOpacity(0.88);
  return GoogleFonts.nunito(
    fontSize: size,
    fontWeight: weight,
    color: on,
    height: height,
    letterSpacing: letterSpacing,
  );
}

/// Small caps section label (e.g. VITENDO VYA HARAKA).
TextStyle nyihaSectionLabel(BuildContext context) {
  return GoogleFonts.nunito(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.35,
    color: NyihaColors.onSurfaceMuted(context),
  );
}

TextStyle nyihaFieldLabel(BuildContext context) {
  return GoogleFonts.nunito(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: NyihaColors.accent(context),
  );
}
