import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/nyiha_colors.dart';
import '../../theme/nyiha_text.dart';
import '../../widgets/duka_cart_sheet.dart';
import '../../widgets/duka_order_sheet.dart';
import '../../widgets/duka_product_card.dart';
import '../../widgets/kente_strip.dart';

class DukaTab extends StatelessWidget {
  const DukaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final orderCount = app.shopOrders.length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            decoration: NyihaDecorations.communityHeader(context),
            padding: const EdgeInsets.fromLTRB(22, 52, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Duka la Nyiha', style: nyihaCinzel(context, size: 26)),
                          const SizedBox(height: 6),
                          Text(
                            'Bidhaa za kipekee za jamii — nguo, vifaa, na zaidi.',
                            style: nyihaNunito(context, size: 14, color: NyihaColors.onSurfaceMuted(context)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _CartIconButton(
                        count: orderCount,
                        onPressed: () => showDukaCartSheet(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: KenteStrip(height: 5)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final p = app.dukaProducts[i];
                return DukaProductCard(
                  product: p,
                  compactOrderLabel: true,
                  onOrder: () => showDukaOrderSheet(context, p),
                );
              },
              childCount: app.dukaProducts.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _CartIconButton extends StatelessWidget {
  const _CartIconButton({required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ax = NyihaColors.accent(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ax.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ax.withOpacity(0.22)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.shopping_bag_outlined, color: ax, size: 26),
              if (count > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ax,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: ax.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 1)),
                      ],
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Center(
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: nyihaNunito(
                          context,
                          size: 10,
                          weight: FontWeight.w800,
                          color: NyihaColors.onPrimaryButton(context),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
