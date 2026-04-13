import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';
import '../widgets/duka_order_sheet.dart';
import '../widgets/duka_product_card.dart';

/// Bottom sheet listing duka products (optional; main browsing is [DukaTab]).
Future<void> showShopSheet(BuildContext context) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: dark ? NyihaColors.earth850 : NyihaColors.lightSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, scroll) {
        final products = ctx.watch<AppState>().dukaProducts;
        return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: NyihaColors.accent(context).withOpacity(0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Duka la Nyiha', textAlign: TextAlign.center, style: nyihaCinzel(ctx, size: 22)),
            const SizedBox(height: 6),
            Text(
              'Bidhaa za kipekee za jamii',
              textAlign: TextAlign.center,
              style: nyihaNunito(ctx, size: 13, color: NyihaColors.onSurfaceMuted(ctx)),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: GridView.builder(
                controller: scroll,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemCount: products.length,
                itemBuilder: (_, i) {
                  final p = products[i];
                  return DukaProductCard(
                    product: p,
                    onOrder: () {
                      Navigator.pop(ctx);
                      Future.microtask(() => showDukaOrderSheet(context, p));
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<AppState>().setMainTab(2);
              },
              icon: Icon(Icons.storefront_rounded, color: NyihaColors.accent(context)),
              label: Text('Fungua duka kamili', style: nyihaNunito(ctx, size: 13, color: NyihaColors.accent(context))),
            ),
          ],
        ),
        );
      },
    ),
  );
}
