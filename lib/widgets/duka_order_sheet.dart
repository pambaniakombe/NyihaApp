import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';
import 'nyiha_buttons.dart';
import 'nyiha_product_image.dart';

const _sizes = ['S', 'M', 'L', 'XL', 'XXL'];
const _rangis = [
  'Nyeusi',
  'Nyeupe',
  'Buluu',
  'Nyekundu',
  'Kijani',
  'Njano',
  'Kahawia',
  'Waridi',
];

/// Bottom sheet (50px top radius) to collect saizi, rangi, idadi before placing order.
Future<void> showDukaOrderSheet(BuildContext context, MockProduct product) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _DukaOrderSheetBody(product: product, rootContext: context),
  );
}

class _DukaOrderSheetBody extends StatefulWidget {
  const _DukaOrderSheetBody({required this.product, required this.rootContext});

  final MockProduct product;
  final BuildContext rootContext;

  @override
  State<_DukaOrderSheetBody> createState() => _DukaOrderSheetBodyState();
}

class _DukaOrderSheetBodyState extends State<_DukaOrderSheetBody> {
  String? _size;
  String? _rangi;
  int _idadi = 1;

  void _submit() {
    if (_size == null || _rangi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chagua saizi na rangi.', style: nyihaNunito(context, size: 14))),
      );
      return;
    }
    if (_idadi < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Idadi lazima iwe angalau 1.', style: nyihaNunito(context, size: 14))),
      );
      return;
    }
    context.read<AppState>().placeShopOrder(
          product: widget.product,
          size: _size!,
          rangi: _rangi!,
          idadi: _idadi,
        );
    Navigator.of(context).pop();
    Future.microtask(() {
      if (!widget.rootContext.mounted) return;
      showDialog<void>(
        context: widget.rootContext,
        builder: (dCtx) => AlertDialog(
          title: Text('Oda imewasilishwa', style: nyihaCinzel(dCtx, size: 18)),
          content: Text(
            'Oda yako imetumwa kwa muuzaji. Inasubiri malipo. Ukimaliza kulipa, utarifiwa na muuzaji atakapothibitisha au kukufikia.',
            style: nyihaNunito(dCtx, size: 14, height: 1.5),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dCtx).pop(),
              child: const Text('Sawa'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? NyihaColors.earth850
              : NyihaColors.lightSurface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: NyihaColors.accent(context).withOpacity(0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Weka oda', style: nyihaCinzel(context, size: 22)),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 88,
                      height: 88,
                      child: NyihaProductImage(product: p),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: nyihaNunito(context, size: 16, weight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(p.priceLabel, style: nyihaCinzel(context, size: 14, color: NyihaColors.accent(context))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text('SAIZI', style: nyihaFieldLabel(context)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _sizes.map((s) {
                  final sel = _size == s;
                  return ChoiceChip(
                    label: Text(s),
                    selected: sel,
                    onSelected: (_) => setState(() => _size = s),
                    selectedColor: NyihaColors.accent(context).withOpacity(0.22),
                    labelStyle: nyihaNunito(
                      context,
                      size: 13,
                      weight: FontWeight.w600,
                      color: sel ? NyihaColors.accent(context) : NyihaColors.onSurface(context),
                    ),
                    side: BorderSide(color: NyihaColors.accent(context).withOpacity(sel ? 0.85 : 0.25)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Text('RANGI', style: nyihaFieldLabel(context)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _rangi,
                decoration: const InputDecoration(
                  hintText: 'Chagua rangi...',
                ),
                dropdownColor: Theme.of(context).brightness == Brightness.dark
                    ? NyihaColors.earth850
                    : NyihaColors.lightSurface,
                hint: Text('Chagua rangi...', style: TextStyle(color: NyihaColors.accent(context).withOpacity(0.5))),
                items: _rangis
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(r, style: TextStyle(color: NyihaColors.onSurface(context))),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _rangi = v),
              ),
              const SizedBox(height: 18),
              Text('IDADI', style: nyihaFieldLabel(context)),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: NyihaColors.accent(context).withOpacity(0.15),
                      foregroundColor: NyihaColors.accent(context),
                    ),
                    onPressed: _idadi > 1 ? () => setState(() => _idadi--) : null,
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  Expanded(
                    child: Text(
                      '$_idadi',
                      textAlign: TextAlign.center,
                      style: nyihaCinzel(context, size: 22),
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: NyihaColors.accent(context).withOpacity(0.15),
                      foregroundColor: NyihaColors.accent(context),
                    ),
                    onPressed: _idadi < 99 ? () => setState(() => _idadi++) : null,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              BtnGold(
                label: 'Weka oda',
                icon: Icons.send_rounded,
                onPressed: _submit,
              ),
              const SizedBox(height: 10),
              Text(
                'Oda itatumwa kwa muuzaji. Malipo yanaposadikiwa utapokea taarifa.',
                textAlign: TextAlign.center,
                style: nyihaNunito(context, size: 11, color: NyihaColors.onSurfaceMuted(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
