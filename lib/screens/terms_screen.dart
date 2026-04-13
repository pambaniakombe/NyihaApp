import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';
import '../widgets/glass_card.dart';
import '../widgets/kente_strip.dart';
import '../widgets/nyiha_buttons.dart';
import '../widgets/nyiha_toast.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(width: double.infinity, height: double.infinity, decoration: NyihaDecorations.pageGradient(context)),
          Positioned.fill(child: DecoratedBox(decoration: NyihaDecorations.subtleRadialAccent(context))),
          Column(
            children: [
              const KenteStrip(height: 5),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  children: [
                    Text('Masharti & kanuni', style: nyihaCinzel(context, size: 26)),
                    const SizedBox(height: 6),
                    Text(
                      'Soma na kubali kabla ya kuendelea',
                      style: nyihaNunito(context, size: 14, color: NyihaColors.onSurfaceMuted(context)),
                    ),
                    const SizedBox(height: 22),
                    GlassCard(
                      child: SizedBox(
                        height: 320,
                        child: SingleChildScrollView(
                          child: Text(
                            'Kujiunga kunamaanisha umekubali masharti ya jamii. Michango ya kila mwezi ni lazima. Heshima na siri za jamii ni muhimu.',
                            style: nyihaNunito(context, size: 14, height: 1.75, color: NyihaColors.onSurfaceMuted(context)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: accepted,
                          onChanged: (v) => setState(() => accepted = v ?? false),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'Nimesoma na kukubaliana na masharti na kanuni.',
                              style: nyihaNunito(context, size: 14, height: 1.45),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    BtnGold(
                      label: 'Endelea kulipa',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () {
                        if (!accepted) {
                          showNyihaToast(context, 'Tafadhali kukubaliana na masharti kwanza.');
                          return;
                        }
                        context.read<AppState>().setScreen(AppScreen.payment);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
