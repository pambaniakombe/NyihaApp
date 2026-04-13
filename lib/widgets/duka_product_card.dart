import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';
import 'nyiha_buttons.dart';
import 'nyiha_product_image.dart';

class DukaProductCard extends StatelessWidget {
  const DukaProductCard({
    super.key,
    required this.product,
    required this.onOrder,
    this.compactOrderLabel = false,
  });

  final MockProduct product;
  final VoidCallback onOrder;
  final bool compactOrderLabel;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: NyihaColors.accent(context).withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NyihaColors.accent(context).withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(dark ? 0.2 : 0.06), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onOrder,
                child: NyihaProductImage(
                  product: product,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(product.name, style: nyihaNunito(context, size: 13, weight: FontWeight.w700, color: NyihaColors.onSurface(context))),
                Text(product.priceLabel, style: nyihaCinzel(context, size: 12, color: NyihaColors.accent(context))),
                const SizedBox(height: 8),
                BtnGold(
                  label: compactOrderLabel ? 'Oda' : 'Weka oda',
                  small: true,
                  icon: Icons.shopping_bag_rounded,
                  onPressed: onOrder,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
