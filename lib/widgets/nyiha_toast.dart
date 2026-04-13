import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';

OverlayEntry? _toastEntry;

void showNyihaToast(BuildContext context, String message, {Duration duration = const Duration(milliseconds: 2800)}) {
  _toastEntry?.remove();
  final overlay = Overlay.of(context);
  final dark = Theme.of(context).brightness == Brightness.dark;
  _toastEntry = OverlayEntry(
    builder: (ctx) => Positioned(
      bottom: 96,
      left: 20,
      right: 20,
      child: IgnorePointer(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (_, v, child) => Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset(0, (1 - v) * 16),
                child: child,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  decoration: BoxDecoration(
                    color: dark
                        ? NyihaColors.earth850.withOpacity(0.92)
                        : NyihaColors.lightSurface.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: NyihaColors.accent(ctx).withOpacity(0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: nyihaNunito(
                      ctx,
                      size: 13,
                      color: NyihaColors.onSurface(ctx),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  overlay.insert(_toastEntry!);
  Future.delayed(duration, () {
    _toastEntry?.remove();
    _toastEntry = null;
  });
}
