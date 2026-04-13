import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../providers/app_state.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';
import '../widgets/kente_strip.dart';
import '../widgets/nyiha_buttons.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, _) {
        final slide = onboardSlides[app.onboardStep];
        final color = slide['color'] as Color;
        final imageAsset = slide['imageAsset'] as String?;
        final last = app.onboardStep == onboardSlides.length - 1;
        return Scaffold(
          body: Stack(
            children: [
              Container(width: double.infinity, height: double.infinity, decoration: NyihaDecorations.pageGradient(context)),
              Positioned.fill(child: DecoratedBox(decoration: NyihaDecorations.subtleRadialAccent(context))),
              Column(
                children: [
                  const KenteStrip(height: 5),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 36, 28, 112),
                      child: Column(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 380),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: Column(
                              key: ValueKey(app.onboardStep),
                              children: [
                                const SizedBox(height: 12),
                                Container(
                                  width: 108,
                                  height: 108,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        color.withOpacity(0.35),
                                        color.withOpacity(0.08),
                                      ],
                                    ),
                                    border: Border.all(color: color.withOpacity(0.45)),
                                    boxShadow: [
                                      BoxShadow(color: color.withOpacity(0.25), blurRadius: 32, offset: const Offset(0, 12)),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: imageAsset != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(22),
                                          child: Image.asset(
                                            imageAsset,
                                            width: 86,
                                            height: 86,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Text('${slide['icon']}', style: const TextStyle(fontSize: 54)),
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  '${slide['title']}',
                                  textAlign: TextAlign.center,
                                  style: nyihaCinzel(context, size: 26, color: color),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  '${slide['sub']}',
                                  textAlign: TextAlign.center,
                                  style: nyihaNunito(
                                    context,
                                    size: 15,
                                    height: 1.75,
                                    color: NyihaColors.onSurfaceMuted(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(onboardSlides.length, (i) {
                              final active = i == app.onboardStep;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeOutCubic,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: active ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: active ? NyihaColors.gold : NyihaColors.gold.withOpacity(0.22),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 36),
                          Row(
                            children: [
                              Expanded(
                                child: BtnOutline(
                                  label: 'Ruka',
                                  small: true,
                                  onPressed: () => app.setScreen(AppScreen.login),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 2,
                                child: BtnGold(
                                  label: last ? 'Anza sasa' : 'Endelea',
                                  small: true,
                                  icon: last ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                                  onPressed: () {
                                    if (last) {
                                      app.setScreen(AppScreen.register);
                                    } else {
                                      app.setOnboardStep(app.onboardStep + 1);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
