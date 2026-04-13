import 'package:flutter/material.dart';
import '../theme/nyiha_colors.dart';

/// Accent strip: kente-inspired (dark) or blue brand gradient (light).
class KenteStrip extends StatelessWidget {
  const KenteStrip({super.key, this.height = 5});

  final double height;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [
                  NyihaColors.gold,
                  NyihaColors.goldLight,
                  NyihaColors.amberMid,
                  NyihaColors.greenAccent,
                  NyihaColors.blueAccent,
                  NyihaColors.goldDark,
                ]
              : [
                  NyihaColors.lightPrimaryDark,
                  NyihaColors.lightPrimary,
                  NyihaColors.lightPrimaryLight,
                  NyihaColors.lightPrimary,
                  NyihaColors.lightPrimaryDark,
                ],
          stops: dark ? const [0.0, 0.18, 0.38, 0.55, 0.78, 1.0] : const [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: NyihaColors.accent(context).withOpacity(0.22),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
