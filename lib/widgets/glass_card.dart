import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/nyiha_colors.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 18,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: NyihaColors.cardFill(context),
            border: Border.all(color: NyihaColors.cardBorder(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.35 : 0.06),
                blurRadius: dark ? 28 : 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
