import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/nyiha_colors.dart';

/// Network image for [MockProduct] with loading state and gradient + emoji fallback on error.
class NyihaProductImage extends StatelessWidget {
  const NyihaProductImage({
    super.key,
    required this.product,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final MockProduct product;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget img = Image.network(
      product.imageUrl,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Color(product.color).withOpacity(0.15),
          alignment: Alignment.center,
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: NyihaColors.accent(context).withOpacity(0.75),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _fallback(),
    );
    if (borderRadius != null) {
      img = ClipRRect(borderRadius: borderRadius!, child: img);
    }
    return img;
  }

  Widget _fallback() {
    final c = Color(product.color);
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.withOpacity(0.4), c.withOpacity(0.12)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(product.emoji, style: const TextStyle(fontSize: 48)),
    );
  }
}
