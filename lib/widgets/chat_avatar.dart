import 'package:flutter/material.dart';

import '../services/nyiha_api.dart';
import '../theme/nyiha_colors.dart';

/// Network profile image with emoji fallback; used in chat rows.
class ChatAvatar extends StatelessWidget {
  const ChatAvatar({
    super.key,
    this.imageUrl,
    this.fallbackEmoji,
    this.radius = 18,
    this.ringColor,
    this.ringWidth = 1.5,
  });

  final String? imageUrl;
  final String? fallbackEmoji;
  final double radius;
  final Color? ringColor;
  final double ringWidth;

  @override
  Widget build(BuildContext context) {
    final accent = NyihaColors.accent(context);
    final resolved = NyihaApi.resolveAvatarUrl(imageUrl);
    final emoji = fallbackEmoji ?? '👤';
    final ring = ringColor ?? accent;
    final d = radius * 2;

    Widget inner() {
      if (resolved.isEmpty) {
        return Container(
          width: d,
          height: d,
          color: accent.withOpacity(0.14),
          alignment: Alignment.center,
          child: Text(emoji, style: TextStyle(fontSize: radius * 1.05)),
        );
      }
      return Image.network(
        resolved,
        width: d,
        height: d,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: d,
            height: d,
            color: accent.withOpacity(0.08),
            alignment: Alignment.center,
            child: SizedBox(
              width: radius,
              height: radius,
              child: CircularProgressIndicator(strokeWidth: 2, color: accent),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          width: d,
          height: d,
          color: accent.withOpacity(0.12),
          alignment: Alignment.center,
          child: Text(emoji, style: TextStyle(fontSize: radius * 1.05)),
        ),
      );
    }

    return Container(
      width: d + ringWidth * 2,
      height: d + ringWidth * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring.withOpacity(0.45), width: ringWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipOval(child: inner()),
    );
  }
}
