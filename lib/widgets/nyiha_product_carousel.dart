import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';
import 'nyiha_product_image.dart';

/// Horizontal carousel of duka products with image, title, price; auto-advances on a timer.
class NyihaProductCarousel extends StatefulWidget {
  const NyihaProductCarousel({
    super.key,
    this.onSlideTap,
  });

  final void Function(MockProduct product)? onSlideTap;

  @override
  State<NyihaProductCarousel> createState() => _NyihaProductCarouselState();
}

class _NyihaProductCarouselState extends State<NyihaProductCarousel> {
  late final PageController _controller;
  Timer? _autoPlayTimer;

  static const _autoPlayInterval = Duration(seconds: 4);
  static const _animateDuration = Duration(milliseconds: 520);

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.88);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleAutoPlay());
  }

  void _scheduleAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(_autoPlayInterval, (_) {
      if (!mounted || !_controller.hasClients) return;
      final n = context.read<AppState>().dukaProducts.length;
      if (n <= 1) return;
      final page = _controller.page?.round() ?? _controller.initialPage;
      final next = (page + 1) % n;
      _controller.animateToPage(
        next,
        duration: _animateDuration,
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = context.watch<AppState>().dukaProducts;
    if (items.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Hakuna bidhaa kwenye duka bado.',
            style: nyihaNunito(context, size: 13, color: NyihaColors.onSurfaceMuted(context)),
          ),
        ),
      );
    }
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _controller,
        padEnds: true,
        itemCount: items.length,
        itemBuilder: (context, i) {
          final p = items[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => widget.onSlideTap?.call(p),
                borderRadius: BorderRadius.circular(22),
                child: _CarouselSlide(product: p),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CarouselSlide extends StatelessWidget {
  const _CarouselSlide({required this.product});

  final MockProduct product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: NyihaProductImage(product: product),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.78),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: nyihaNunito(context, size: 15, weight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.priceLabel,
                    style: nyihaCinzel(
                      context,
                      size: 13,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? NyihaColors.goldLight
                          : const Color(0xFFC8D4FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
