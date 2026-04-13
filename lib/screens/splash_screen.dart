import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  double _progress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 28), (_) {
      if (!mounted) return;
      setState(() {
        _progress = (_progress + 0.018).clamp(0.0, 1.0);
      });
      if (_progress >= 1) {
        _timer?.cancel();
        Future.delayed(const Duration(milliseconds: 280), () {
          if (!mounted) return;
          context.read<AppState>().setScreen(AppScreen.onboarding);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: NyihaColors.splashBg),
          ),
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: NyihaColors.gold.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: NyihaColors.amberMid.withOpacity(0.05),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.035,
              child: CustomPaint(painter: _GeoPainter()),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.88, end: 1),
                  duration: const Duration(milliseconds: 1800),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, child) => Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: NyihaColors.goldButton,
                      boxShadow: [
                        BoxShadow(
                          color: NyihaColors.gold.withOpacity(0.55),
                          blurRadius: 48,
                          spreadRadius: 2,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('🏔️', style: TextStyle(fontSize: 48)),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'NYIHA',
                  style: nyihaCinzel(context, size: 38, weight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  'JAMII · UTAMADUNI · UMOJA',
                  style: nyihaNunito(
                    context,
                    size: 12,
                    letterSpacing: 1.2,
                    color: NyihaColors.cream.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 200,
                height: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: NyihaColors.gold.withOpacity(0.18),
                    color: NyihaColors.goldLight,
                    minHeight: 4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()..color = NyihaColors.gold.withOpacity(0.35);
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(220, 0)
      ..lineTo(0, 220)
      ..close();
    canvas.drawPath(path, gold);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
