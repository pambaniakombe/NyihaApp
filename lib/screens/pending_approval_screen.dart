import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';
import '../widgets/glass_card.dart';
import '../widgets/kente_strip.dart';
import '../widgets/nyiha_buttons.dart';
import '../widgets/nyiha_toast.dart';

/// Shown while [NyihaUser.status] is `Pending` or `Rejected` after registration + fee.
class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final rejected = app.user.status.trim().toLowerCase() == 'rejected';
    final ax = NyihaColors.accent(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: NyihaDecorations.pageGradient(context),
          ),
          Positioned.fill(child: DecoratedBox(decoration: NyihaDecorations.subtleRadialAccent(context))),
          Column(
            children: [
              const KenteStrip(height: 5),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
                  child: Column(
                    children: [
                      Icon(
                        rejected ? Icons.cancel_outlined : Icons.hourglass_top_rounded,
                        size: 72,
                        color: rejected ? Colors.redAccent.withOpacity(0.85) : ax.withOpacity(0.9),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        rejected ? 'Ombi halikukubaliwa' : 'Subiri uidhinishaji',
                        textAlign: TextAlign.center,
                        style: nyihaCinzel(context, size: 24),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        rejected
                            ? 'Ombi lako la uanachama limekataliwa. Wasiliana na jamii kwa nambari za msaada hapa chini.'
                            : 'Umeshatuma fomu na ada. Msimamizi atahakiki malipo na kuidhinisha akaunti yako. Hii inaweza kuchukua muda kidogo.',
                        textAlign: TextAlign.center,
                        style: nyihaNunito(context, size: 14, height: 1.45, color: NyihaColors.onSurfaceMuted(context)),
                      ),
                      const SizedBox(height: 28),
                      GlassCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.support_agent_rounded, color: ax, size: 26),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Huduma kwa wateja',
                                    style: nyihaCinzel(context, size: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Ikiwa inachukua muda mrefu, piga simu au tumia WhatsApp:',
                              style: nyihaNunito(context, size: 12, color: NyihaColors.onSurfaceMuted(context)),
                            ),
                            const SizedBox(height: 14),
                            _Line(icon: Icons.phone_rounded, label: 'Simu', value: app.customerCarePhone),
                            const SizedBox(height: 10),
                            _Line(icon: Icons.chat_rounded, label: 'WhatsApp', value: app.customerCareWhatsApp),
                            const SizedBox(height: 10),
                            Text(
                              app.customerCareHoursLabel,
                              style: nyihaNunito(context, size: 11, color: NyihaColors.onSurfaceMuted(context)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (!rejected) ...[
                        Text(
                          'Utaarifiwa unapokubaliwa. Bonyeza "Angalia tena" baada ya msimamizi kuidhinisha.',
                          textAlign: TextAlign.center,
                          style: nyihaNunito(context, size: 12, color: NyihaColors.onSurfaceMuted(context)),
                        ),
                        const SizedBox(height: 20),
                        BtnGold(
                          label: app.isMemberApproved ? 'Ingia kwenye programu' : 'Angalia tena',
                          icon: Icons.refresh_rounded,
                          onPressed: () {
                            if (app.isMemberApproved) {
                              app.setScreen(AppScreen.main);
                            } else {
                              showNyihaToast(context, 'Bado inasubiri idhini ya msimamizi. Jaribu tena baadaye.');
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      BtnOutline(
                        label: 'Toka',
                        icon: Icons.logout_rounded,
                        onPressed: () => app.setScreen(AppScreen.login),
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
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ax = NyihaColors.accent(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: ax.withOpacity(0.85)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: nyihaNunito(context, size: 11, color: NyihaColors.onSurfaceMuted(context))),
              SelectableText(value, style: nyihaNunito(context, size: 16, weight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }
}
