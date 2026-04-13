import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';
import 'duka_seller_chat_sheet.dart';

/// Shows placed duka orders from [AppState.shopOrders].
Future<void> showDukaCartSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _DukaCartBody(),
  );
}

class _DukaCartBody extends StatelessWidget {
  const _DukaCartBody();

  static String _formatTime(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<AppState>().shopOrders;
    final maxH = MediaQuery.of(context).size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? NyihaColors.earth850
            : NyihaColors.lightSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: NyihaColors.accent(context).withOpacity(0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
            child: Row(
              children: [
                Icon(Icons.shopping_bag_rounded, color: NyihaColors.accent(context), size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Oda zako', style: nyihaCinzel(context, size: 22)),
                      Text(
                        orders.isEmpty ? 'Bado hakuna oda' : '${orders.length} oda',
                        style: nyihaNunito(context, size: 13, color: NyihaColors.onSurfaceMuted(context)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Mazungumzo na muuzaji',
                  onPressed: () => showDukaSellerChatSheet(context),
                  icon: Icon(Icons.chat_rounded, color: NyihaColors.accent(context)),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: NyihaColors.onSurfaceMuted(context)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: NyihaColors.accent(context).withOpacity(0.1)),
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 56,
                            color: NyihaColors.onSurfaceMuted(context).withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Hakuna bado. Chagua bidhaa na uweke oda.',
                            textAlign: TextAlign.center,
                            style: nyihaNunito(context, size: 14, color: NyihaColors.onSurfaceMuted(context)),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      return _OrderTile(order: orders[i]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final PlacedShopOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NyihaColors.accent(context).withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NyihaColors.accent(context).withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  order.productName,
                  style: nyihaNunito(context, size: 15, weight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: NyihaColors.accent(context).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status,
                  style: nyihaNunito(context, size: 10, weight: FontWeight.w700, color: NyihaColors.accent(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Mnunuzi: ${order.buyerName}',
            style: nyihaNunito(context, size: 12, weight: FontWeight.w600, color: NyihaColors.accent(context)),
          ),
          const SizedBox(height: 6),
          Text(
            'Saizi ${order.size} · ${order.rangi} · ×${order.idadi}',
            style: nyihaNunito(context, size: 13, color: NyihaColors.onSurfaceMuted(context)),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.priceLabel,
                style: nyihaCinzel(context, size: 14, color: NyihaColors.accent(context)),
              ),
              Text(
                _DukaCartBody._formatTime(order.placedAt),
                style: nyihaNunito(context, size: 11, color: NyihaColors.onSurfaceMuted(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
