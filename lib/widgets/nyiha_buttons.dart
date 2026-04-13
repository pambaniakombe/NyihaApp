import 'package:flutter/material.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';

class BtnGold extends StatelessWidget {
  const BtnGold({
    super.key,
    required this.label,
    this.onPressed,
    this.small = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool small;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final pad = small
        ? const EdgeInsets.symmetric(vertical: 12, horizontal: 18)
        : const EdgeInsets.symmetric(vertical: 16, horizontal: 28);
    final enabled = onPressed != null;
    final accent = NyihaColors.accent(context);
    final onBtn = NyihaColors.onPrimaryButton(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: enabled ? NyihaColors.primaryButtonGradient(context) : null,
            color: enabled ? null : accent.withOpacity(0.35),
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: accent.withOpacity(0.38),
                      blurRadius: 22,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: pad,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: small ? 18 : 20, color: onBtn),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: nyihaCinzel(
                      context,
                      size: small ? 13 : 15,
                      color: onBtn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BtnOutline extends StatelessWidget {
  const BtnOutline({
    super.key,
    required this.label,
    this.onPressed,
    this.small = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool small;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final pad = small
        ? const EdgeInsets.symmetric(vertical: 12, horizontal: 18)
        : const EdgeInsets.symmetric(vertical: 14, horizontal: 28);
    final accent = NyihaColors.accent(context);
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: BorderSide(color: accent.withOpacity(onPressed == null ? 0.35 : 0.85), width: 1.5),
        padding: pad,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: small ? 17 : 18, color: accent),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: nyihaCinzel(context, size: small ? 13 : 14, color: accent),
            ),
          ),
        ],
      ),
    );
  }
}
